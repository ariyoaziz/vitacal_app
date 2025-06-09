import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/models/enums.dart'; // Pastikan ini diimpor untuk akses toDisplayString()

import 'userdetail_event.dart';
import 'userdetail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserDetailService userDetailService;

  UserDetailBloc({required this.userDetailService})
      : super(UserDetailInitial()) {
    on<LoadUserDetail>(_onLoadUserDetail);
    on<AddUserDetail>(_onAddUserDetail);
    on<UpdateUserDetail>(_onUpdateUserDetail);
    on<DeleteUserDetail>(_onDeleteUserDetail);
  }

  Future<void> _onLoadUserDetail(
      LoadUserDetail event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      final userDetail = await userDetailService.getUserDetail();
      print(
          'DEBUG: UserDetailBloc - Data dimuat dari API: Berat=${userDetail.beratBadan} kg, Tinggi=${userDetail.tinggiBadan} cm, Tujuan=${userDetail.tujuan?.toDisplayString() ?? "N/A"}');
      emit(UserDetailLoaded(
          userDetail)); // Selalu memancarkan UserDetailLoaded setelah load
    } on AuthException catch (e) {
      print(
          'UserDetailBloc: Menangkap AuthException (LoadUserDetail): "${e.message}"');
      emit(UserDetailError(e.message));
    } catch (e) {
      print(
          'UserDetailBloc: Error tak terduga (LoadUserDetail): ${e.runtimeType} - $e');
      emit(UserDetailError(
          'Terjadi masalah tak terduga saat memuat data. Mohon coba lagi nanti.'));
    }
  }

  Future<void> _onAddUserDetail(
      AddUserDetail event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      final newUserDetail = await userDetailService.addUserDetail(
        userId: event.userId,
        nama: event.nama,
        umur: event.umur,
        jenisKelamin: event.jenisKelamin,
        beratBadan: event.beratBadan,
        tinggiBadan: event.tinggiBadan,
        aktivitas: event.aktivitas,
        tujuan: event.tujuan,
      );
      print(
          'DEBUG: UserDetailBloc - Data ditambahkan: Berat=${newUserDetail.beratBadan} kg, Tinggi=${newUserDetail.tinggiBadan} cm, Tujuan=${newUserDetail.tujuan?.toDisplayString() ?? "N/A"}');
      emit(UserDetailAddSuccess(
          newUserDetail)); // Memancarkan UserDetailAddSuccess
      emit(UserDetailLoaded(
          newUserDetail)); // <<< TAMBAH: Juga memancarkan UserDetailLoaded untuk update UI >>>
    } on AuthException catch (e) {
      print(
          'UserDetailBloc: Menangkap AuthException (AddUserDetail): "${e.message}"');
      emit(UserDetailError(e.message));
    } catch (e) {
      print(
          'UserDetailBloc: Error tak terduga (AddUserDetail): ${e.runtimeType} - $e');
      emit(UserDetailError(
          'Terjadi masalah tak terduga saat menambah data. Mohon coba lagi nanti.'));
    }
  }

  Future<void> _onUpdateUserDetail(
      UpdateUserDetail event, Emitter<UserDetailState> emit) async {
    print(
        'DEBUG: UserDetailBloc - Menerima event UpdateUserDetail dengan updates: ${event.updates}');

    // --- PERBAIKAN: Ambil oldUserDetail dari state manapun yang mengandungnya ---
    UserDetailModel? oldUserDetail;
    if (state is UserDetailLoaded) {
      oldUserDetail = (state as UserDetailLoaded).userDetail;
    } else if (state is UserDetailAddSuccess) {
      oldUserDetail = (state as UserDetailAddSuccess).userDetail;
    } else if (state is UserDetailUpdateSuccess) {
      oldUserDetail = (state as UserDetailUpdateSuccess).userDetail;
    }
    // --- AKHIR PERBAIKAN ---

    // Emit loading untuk memberikan feedback UI
    emit(UserDetailLoading());

    try {
      final updatedUserDetail =
          await userDetailService.updateUserDetail(event.updates);

      print(
          'DEBUG: UserDetailBloc - Data berhasil diperbarui dari API: Berat=${updatedUserDetail.beratBadan} kg, Tinggi=${updatedUserDetail.tinggiBadan} cm, Tujuan=${updatedUserDetail.tujuan?.toDisplayString() ?? "N/A"}');

      emit(UserDetailUpdateSuccess(
          updatedUserDetail)); // Emit state sukses update
      emit(UserDetailLoaded(
          updatedUserDetail)); // Emit state loaded untuk update UI secara konsisten
    } on AuthException catch (e) {
      print(
          'UserDetailBloc: Menangkap AuthException (UpdateUserDetail): "${e.message}"');
      emit(UserDetailError(e.message));
      // Jika ada data lama, kembalikan ke state loaded dengan data lama
      if (oldUserDetail != null) {
        emit(UserDetailLoaded(oldUserDetail));
      } else {
        emit(
            UserDetailInitial()); // Jika tidak ada data lama, kembali ke initial
      }
    } catch (e) {
      print(
          'UserDetailBloc: Error tak terduga (UpdateUserDetail): ${e.runtimeType} - $e');
      emit(UserDetailError(
          'Terjadi masalah tak terduga saat memperbarui data. Mohon coba lagi nanti.'));
      // Jika ada data lama, kembalikan ke state loaded dengan data lama
      if (oldUserDetail != null) {
        emit(UserDetailLoaded(oldUserDetail));
      } else {
        emit(
            UserDetailInitial()); // Jika tidak ada data lama, kembali ke initial
      }
    }
  }

  Future<void> _onDeleteUserDetail(
      DeleteUserDetail event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      await userDetailService.deleteUserDetail();
      print('DEBUG: UserDetailBloc - Data berhasil dihapus.');
      emit(UserDetailInitial());
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
