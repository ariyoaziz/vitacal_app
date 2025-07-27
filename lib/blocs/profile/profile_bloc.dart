// lib/blocs/profile/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/profile_service.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/profile_model.dart';

import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';
import 'package:vitacal_app/services/auth_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;
  final AuthService authService; // Tambahkan AuthService di sini
  ProfileModel? _currentProfileData;

  ProfileModel? get currentProfileData => _currentProfileData;

  ProfileBloc({required this.profileService, required this.authService})
      : super(ProfileInitial()) {
    // Sesuaikan konstruktor
    on<LoadProfileData>(_onLoadProfileData);
    on<ResetProfileData>(_onResetProfileData);
    on<UpdateBeratBadan>(_onUpdateBeratBadan);
    on<UpdateTinggiBadan>(_onUpdateTinggiBadan);
    on<UpdateJenisKelamin>(_onUpdateJenisKelamin);
    on<UpdateAktivitas>(_onUpdateAktivitas);
    on<UpdateTujuan>(_onUpdateTujuan);
    on<DeleteProfile>(_onDeleteProfile);
  }

  Future<void> _onLoadProfileData(
      LoadProfileData event, Emitter<ProfileState> emit) async {
    // Jika data sudah ada, langsung tampilkan
    if (_currentProfileData != null) {
      emit(ProfileLoaded(_currentProfileData!));
      print('DEBUG PROFILE BLOC: Menampilkan data profil yang sudah ada.');
      return; // Keluar agar tidak fetch ulang
    }

    emit(ProfileLoading());
    print('DEBUG PROFILE BLOC: Memulai loading data profil (pertama kali).');

    try {
      final ProfileModel newProfileData = await profileService.getProfileData();

      _currentProfileData = newProfileData;
      emit(ProfileLoaded(_currentProfileData!));
      print('DEBUG PROFILE BLOC: Data profil berhasil dimuat dari API.');
    } on AuthException catch (e) {
      print(
          'DEBUG PROFILE BLOC: Gagal otentikasi saat load profil: ${e.message}');
      emit(ProfileError(e.message));
    } catch (e) {
      print('DEBUG PROFILE BLOC: Exception tidak terduga saat load profil: $e');
      emit(ProfileError(
          'Terjadi kesalahan saat memuat data profil. Silakan coba lagi.'));
    }
  }

  // Metode Update X - Ini yang utama yang perlu disesuaikan!
  Future<void> _onUpdateBeratBadan(
      UpdateBeratBadan event, Emitter<ProfileState> emit) async {
    if (_currentProfileData == null) {
      emit(ProfileError(
          'Tidak dapat memperbarui berat badan: data profil tidak ditemukan.'));
      return;
    }
    try {
      await profileService.updateBeratBadan(event.beratBadan);
      final ProfileModel newProfileData = await profileService.getProfileData();

      // Selalu update _currentProfileData dengan data terbaru
      _currentProfileData = newProfileData;

      // Kemudian selalu emit ProfileLoaded DULU dengan data terbaru
      // Agar UI memiliki data untuk dibangun
      emit(ProfileLoaded(_currentProfileData!));
      print(
          'DEBUG PROFILE BLOC: Data profil setelah update berat badan dan dimuat ulang: $_currentProfileData');

      // Setelah itu, baru emit ProfileSuccess untuk SnackBar
      emit(ProfileSuccess('Berat badan berhasil diperbarui.'));
      print(
          'DEBUG PROFILE BLOC: Berat badan berhasil diperbarui dan feedback sukses diberikan.');
    } on AuthException catch (e) {
      // Jika error, pastikan _currentProfileData (data terakhir yang berhasil) tetap dipertahankan dan di-emit
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError(e.message));
      print(
          'DEBUG PROFILE BLOC: AuthException saat update berat badan: ${e.message}');
    } catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError('Gagal memperbarui berat badan: ${e.toString()}'));
      print(
          'DEBUG PROFILE BLOC: Error tak terduga saat update berat badan: ${e.toString()}');
    }
  }

  Future<void> _onUpdateTinggiBadan(
      UpdateTinggiBadan event, Emitter<ProfileState> emit) async {
    if (_currentProfileData == null) {
      emit(ProfileError(
          'Tidak dapat memperbarui tinggi badan: data profil tidak ditemukan.'));
      return;
    }
    try {
      await profileService.updateTinggiBadan(event.tinggiBadan);
      final ProfileModel newProfileData = await profileService.getProfileData();

      if (_currentProfileData != newProfileData) {
        _currentProfileData = newProfileData;
        emit(ProfileLoaded(_currentProfileData!));
        print(
            'DEBUG PROFILE BLOC: Data profil diperbarui setelah update tinggi badan.');
      } else {
        emit(ProfileLoaded(_currentProfileData!));
        print(
            'DEBUG PROFILE BLOC: Data profil tidak berubah setelah update tinggi badan, namun feedback sukses akan diberikan.');
      }

      emit(ProfileSuccess('Tinggi badan berhasil diperbarui.'));
      print(
          'DEBUG PROFILE BLOC: Tinggi badan berhasil diperbarui dan feedback sukses diberikan.');
    } on AuthException catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError(e.message));
    } catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError('Gagal memperbarui tinggi badan: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateJenisKelamin(
      UpdateJenisKelamin event, Emitter<ProfileState> emit) async {
    if (_currentProfileData == null) {
      emit(ProfileError(
          'Tidak dapat memperbarui jenis kelamin: data profil tidak ditemukan.'));
      return;
    }
    try {
      await profileService.updateJenisKelamin(event.jenisKelamin);
      await _onLoadProfileData(const LoadProfileData(), emit);
      emit(ProfileSuccess('Jenis kelamin berhasil diperbarui.'));
      print(
          'DEBUG PROFILE BLOC: Jenis kelamin berhasil diperbarui dan dimuat ulang.');
    } on AuthException catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError(e.message));
    } catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError('Gagal memperbarui jenis kelamin: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAktivitas(
      UpdateAktivitas event, Emitter<ProfileState> emit) async {
    if (_currentProfileData == null) {
      emit(ProfileError(
          'Tidak dapat memperbarui aktivitas: data profil tidak ditemukan.'));
      return;
    }
    try {
      await profileService.updateAktivitas(event.aktivitas);
      await _onLoadProfileData(const LoadProfileData(), emit);
      emit(ProfileSuccess('Tingkat aktivitas berhasil diperbarui.'));
      print(
          'DEBUG PROFILE BLOC: Aktivitas berhasil diperbarui dan dimuat ulang.');
    } on AuthException catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError(e.message));
    } catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError('Gagal memperbarui aktivitas: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTujuan(
      UpdateTujuan event, Emitter<ProfileState> emit) async {
    if (_currentProfileData == null) {
      emit(ProfileError(
          'Tidak dapat memperbarui tujuan: data profil tidak ditemukan.'));
      return;
    }
    try {
      await profileService.updateTujuan(event.tujuan);
      await _onLoadProfileData(const LoadProfileData(), emit);
      emit(ProfileSuccess('Tujuan berhasil diperbarui.'));
      print('DEBUG PROFILE BLOC: Tujuan berhasil diperbarui dan dimuat ulang.');
    } on AuthException catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError(e.message));
    } catch (e) {
      if (_currentProfileData != null)
        // ignore: curly_braces_in_flow_control_structures
        emit(ProfileLoaded(_currentProfileData!));
      emit(ProfileError('Gagal memperbarui tujuan: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProfile(
      DeleteProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await profileService.deleteProfile();
      await authService.deleteJwtToken(); // Hapus token dari SharedPreferences

      _currentProfileData = null;
      emit(ProfileInitial());
      emit(ProfileSuccess('Akun Anda berhasil dihapus.'));
      print('DEBUG PROFILE BLOC: Akun berhasil dihapus.');
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError('Gagal menghapus akun: ${e.toString()}'));
    }
  }

  Future<void> _onResetProfileData(
      ResetProfileData event, Emitter<ProfileState> emit) async {
    await authService
        .deleteJwtToken(); // Hapus token dari SharedPreferences saat logout
    _currentProfileData = null;
    emit(ProfileInitial());
    print('DEBUG PROFILE BLOC: Data profil direset (logout).');
  }
}
