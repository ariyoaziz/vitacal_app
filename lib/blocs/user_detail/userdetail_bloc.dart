import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/models/enums.dart'; // Pastikan ini diimpor untuk akses toDisplayString()

import 'userdetail_event.dart';
import 'userdetail_state.dart';

// Pastikan definisi UserDetailEvent dan UserDetailState Anda sudah lengkap
// (termasuk UserDetailNotComplete).

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserDetailService userDetailService;
  final AuthService authService;

  UserDetailBloc({
    required this.userDetailService,
    required this.authService,
  }) : super(UserDetailInitial()) {
    on<LoadUserDetail>(_onLoadUserDetail);
    on<AddUserDetail>(_onAddUserDetail);
    on<UpdateUserDetail>(_onUpdateUserDetail);
    on<DeleteUserDetail>(_onDeleteUserDetail);
  }

  // --- Handler untuk LoadUserDetail (PENTING untuk 404/Profil Belum Lengkap) ---
  Future<void> _onLoadUserDetail(
      LoadUserDetail event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      // Panggil service untuk mendapatkan detail pengguna
      final userDetail = await userDetailService.getUserDetail();
      print(
          'DEBUG: UserDetailBloc - Data dimuat dari API: Berat=${userDetail.beratBadan} kg, Tinggi=${userDetail.tinggiBadan} cm, Tujuan=${userDetail.tujuan?.toDisplayString() ?? "N/A"}');
      emit(UserDetailLoaded(userDetail)); // Jika berhasil dimuat
    } on AuthException catch (e) {
      print(
          'UserDetailBloc: Menangkap AuthException (LoadUserDetail): "${e.message}"');

      // --- PERBAIKAN UTAMA DI SINI: Penanganan spesifik berdasarkan pesan error ---
      if (e.message.contains('Data detail pengguna tidak ditemukan.') ||
          e.message.contains('404')) {
        // Ini berarti backend mengembalikan 404 karena profil belum ada
        print(
            'UserDetailBloc: Profil pengguna belum lengkap (404). Memancarkan UserDetailNotComplete.');
        final int? currentUserId = await authService.getUserId();
        if (currentUserId != null) {
          emit(UserDetailNotComplete(
              userId: currentUserId)); // Memancarkan state khusus
          // PENTING: JANGAN HAPUS TOKEN DI SINI. Sesi masih valid.
        } else {
          // Fallback: Jika userId pun hilang, ini masalah serius, maka logout
          emit(UserDetailError(
              'Sesi tidak valid, mohon login kembali. User ID tidak ditemukan.'));
          await authService.deleteAuthToken(); // Hapus token
          await authService.deleteUserData();
        }
      } else if (e.message.contains('Unauthorized') ||
          e.message.contains('401') ||
          e.message.contains('Sesi Anda telah berakhir')) {
        // Token tidak valid atau sesi habis (error 401 dari backend)
        print(
            'UserDetailBloc: Sesi tidak valid (401). Memerlukan login ulang.');
        emit(UserDetailError('Sesi Anda telah berakhir. Mohon login kembali.'));
        await authService.deleteAuthToken(); // Hapus token
        await authService.deleteUserData();
      } else {
        // Error otentikasi lainnya dari service (misal 422 asli, 500)
        // PENTING: JANGAN HAPUS TOKEN UNTUK KESALAHAN JENIS INI. Token mungkin masih valid.
        emit(UserDetailError(e.message));
      }
    } catch (e) {
      // Error lain yang tidak terduga (misal masalah parsing di Flutter setelah respons 200)
      print(
          'UserDetailBloc: Error tak terduga (LoadUserDetail): ${e.runtimeType} - $e');
      emit(UserDetailError(
          'Terjadi masalah tak terduga saat memuat data. Mohon coba lagi nanti.'));
      // PENTING: JANGAN HAPUS TOKEN UNTUK KESALAHAN JENIS INI. Token mungkin masih valid.
    }
  }

  Future<void> _onAddUserDetail(
      AddUserDetail event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      final int? currentUserId = await authService.getUserId();
      if (currentUserId == null) {
        emit(UserDetailError('User ID tidak ditemukan. Harap login kembali.'));
        await authService.deleteAuthToken();
        await authService.deleteUserData();
        return;
      }

      final newUserDetail = await userDetailService.addUserDetail(
        userId: currentUserId, // <--- Add this line
        nama: event.nama,
        umur: event.umur,
        jenisKelamin: event.jenisKelamin,
        beratBadan: event.beratBadan,
        tinggiBadan: event.tinggiBadan,
        aktivitas: event.aktivitas,
        tujuan: event.tujuan,
        // fotoProfil: event.fotoProfilBase64,
      );
      print(
          'DEBUG: UserDetailBloc - Data ditambahkan: Berat=${newUserDetail.beratBadan} kg, Tinggi=${newUserDetail.tinggiBadan} cm, Tujuan=${newUserDetail.tujuan?.toDisplayString() ?? "N/A"}');
      emit(UserDetailAddSuccess(newUserDetail));
      emit(UserDetailLoaded(newUserDetail));
    } on AuthException catch (e) {
      print(
          'UserDetailBloc: Menangkap AuthException (AddUserDetail): "${e.message}"');
      emit(UserDetailError(e.message));
      if (e.message.contains('Unauthorized') || e.message.contains('401')) {
        await authService.deleteAuthToken();
        await authService.deleteUserData();
      }
    } catch (e) {
      print(
          'UserDetailBloc: Error tak terduga (AddUserDetail): ${e.runtimeType} - $e');
      emit(UserDetailError(
          'Terjadi masalah tak terduga saat menambah data. Mohon coba lagi nanti.'));
    }
  }

  Future<void> _onUpdateUserDetail(
    UpdateUserDetail event,
    Emitter<UserDetailState> emit,
  ) async {
    // --- helpers ---
    String redact(Map<String, dynamic> m) {
      final copy = Map<String, dynamic>.from(m);
      copy.remove('foto_profil_base64'); // hindari log besar
      return copy.toString();
    }

    // Normalisasi nilai untuk perbandingan/log (aman untuk null & enum).
    String norm(dynamic v) {
      if (v == null) return 'null';
      if (v is Enum) return v.name;
      return v.toString();
    }

    bool anyChanged(UserDetailModel cur, Map<String, dynamic> u) {
      if (u.isEmpty) return false;

      bool changed(String key, dynamic currentVal) {
        if (!u.containsKey(key)) return false;
        final newVal = u[key];
        if (newVal == null) return false;
        return norm(currentVal) != norm(newVal);
      }

      return changed('berat_badan', cur.beratBadan) ||
          changed('tinggi_badan', cur.tinggiBadan) ||
          changed('tujuan', cur.tujuan) ||
          changed('aktivitas', cur.aktivitas);
    }
    // ----------------

    print(
        'DEBUG: UserDetailBloc - Menerima UpdateUserDetail dengan updates: ${redact(event.updates)}');

    final oldUserDetail = state is UserDetailLoaded
        ? (state as UserDetailLoaded).userDetail
        : null;

    // Buang nilai null agar PUT bersih
    final updates = Map<String, dynamic>.from(event.updates)
      ..removeWhere((k, v) => v == null);

    if (updates.isEmpty) {
      emit(UserDetailError('Tidak ada perubahan untuk disimpan.'));
      if (oldUserDetail != null) emit(UserDetailLoaded(oldUserDetail));
      return;
    }

    if (oldUserDetail != null && !anyChanged(oldUserDetail, updates)) {
      print('DEBUG: UserDetailBloc - Nilai sama seperti sebelumnya, skip PUT.');
      emit(UserDetailLoaded(oldUserDetail));
      return;
    }

    emit(UserDetailLoading());

    try {
      final updatedUserDetail =
          await userDetailService.updateUserDetail(updates);

      // Logging tujuan aman (nullable + enum/non-enum)
      String tujuanLog() {
        final t =
            updatedUserDetail.tujuan; // tipe kemungkinan: Enum? / nullable
        if (t == null) return 'N/A';
        return t.name;
      }

      print(
        'DEBUG: UserDetailBloc - Updated dari API: '
        'Berat=${updatedUserDetail.beratBadan} kg, '
        'Tinggi=${updatedUserDetail.tinggiBadan} cm, '
        'Tujuan=${tujuanLog()}',
      );

      // Emit satu state sukses; UI bisa listen event ini atau reload di tempat lain
      emit(UserDetailUpdateSuccess(updatedUserDetail));
    } on AuthException catch (e) {
      print('UserDetailBloc: AuthException (UpdateUserDetail): "${e.message}"');
      emit(UserDetailError(e.message));

      if (e.message.contains('Unauthorized') || e.message.contains('401')) {
        await authService.deleteAuthToken();
        await authService.deleteUserData();
        emit(UserDetailInitial());
      } else {
        if (oldUserDetail != null) {
          emit(UserDetailLoaded(oldUserDetail));
        } else {
          emit(UserDetailInitial());
        }
      }
    } catch (e) {
      print('UserDetailBloc: Error tak terduga (${e.runtimeType}) - $e');
      emit(UserDetailError(
        'Terjadi masalah tak terduga saat memperbarui data. Mohon coba lagi nanti.',
      ));
      if (oldUserDetail != null) {
        emit(UserDetailLoaded(oldUserDetail));
      } else {
        emit(UserDetailInitial());
      }
    }
  }

  // --- Handler untuk DeleteUserDetail ---
  Future<void> _onDeleteUserDetail(
      DeleteUserDetail event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      await userDetailService
          .deleteUserDetail(); // Asumsi service tidak butuh userId di sini
      print('DEBUG: UserDetailBloc - Data berhasil dihapus.');

      // Setelah detail pengguna dihapus, hapus sesi login karena profil utama sudah tidak ada.
      await authService.deleteAuthToken();
      await authService.deleteUserData();

      emit(UserDetailInitial()); // Kembali ke state awal
      emit(UserDetailDeleteSuccess('Detail pengguna berhasil dihapus.'));
    } on AuthException catch (e) {
      print(
          'UserDetailBloc: Menangkap AuthException (DeleteUserDetail): "${e.message}"');
      emit(UserDetailError(e.message));
    } catch (e) {
      print(
          'UserDetailBloc: Error tak terduga (DeleteUserDetail): ${e.runtimeType} - $e');
      emit(UserDetailError(
          'Terjadi masalah tak terduga saat menghapus data. Mohon coba lagi nanti.'));
    }
  }
}
