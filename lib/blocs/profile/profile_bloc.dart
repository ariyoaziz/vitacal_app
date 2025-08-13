// lib/blocs/profile/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/profile_service.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/profile_model.dart';

// Import enums.dart untuk mengakses toApiString()
import 'package:vitacal_app/models/enums.dart';

import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';
import 'package:vitacal_app/services/auth_service.dart'; // Pastikan AuthService diimpor

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;
  final AuthService authService; // Instance AuthService
  ProfileModel? _currentProfileData; // Data profil yang sedang dimuat

  // Getter untuk mengakses data profil dari luar BLoC
  ProfileModel? get currentProfileData => _currentProfileData;

  ProfileBloc({required this.profileService, required this.authService})
      : super(ProfileInitial()) {
    on<LoadProfileData>(_onLoadProfileData);
    on<ResetProfileData>(_onResetProfileData);
    on<UpdateBeratBadan>(_onUpdateBeratBadan);
    on<UpdateTinggiBadan>(_onUpdateTinggiBadan);
    on<UpdateJenisKelamin>(_onUpdateJenisKelamin);
    on<UpdateAktivitas>(_onUpdateAktivitas);
    on<UpdateTujuan>(_onUpdateTujuan);
    on<DeleteProfile>(_onDeleteProfile);
    on<UpdateContactInfo>(_onUpdateContactInfo);
  }

  /// Handler untuk event LoadProfileData: Memuat data profil dari service.
  Future<void> _onLoadProfileData(
      LoadProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading()); // Emit state loading
    print('DEBUG PROFILE BLOC: Memulai loading data profil.');

    try {
      final ProfileModel newProfileData = await profileService
          .getProfileData(); // Panggil service untuk ambil data
      _currentProfileData = newProfileData; // Simpan data yang dimuat
      emit(
          ProfileLoaded(_currentProfileData!)); // Emit state loaded dengan data
      print('DEBUG PROFILE BLOC: Data profil berhasil dimuat dari API.');
    } on AuthException catch (e) {
      // Menangkap AuthException (misalnya 401 Unauthorized, 404 Not Found)
      print('DEBUG PROFILE BLOC: AuthException saat load profil: ${e.message}');
      // --- PERBAIKAN: Ganti deleteJwtToken() menjadi deleteAuthToken() ---
      await authService
          .deleteAuthToken(); // Hapus token karena otentikasi gagal
      await authService.deleteUserData(); // Hapus juga data user di lokal
      // --- AKHIR PERBAIKAN ---
      _currentProfileData = null; // Reset data profil lokal
      emit(ProfileInitial()); // Kembali ke state awal
      emit(ProfileError(e.message)); // Emit state error
    } catch (e) {
      // Menangkap exception tidak terduga lainnya
      print(
          'DEBUG PROFILE BLOC: Exception tidak terduga saat load profil: ${e.runtimeType} - $e');
      emit(ProfileError(
          'Terjadi masalah tak terduga saat memuat data profil. Silakan coba lagi.'));
    }
  }

  /// Helper untuk menangani proses update profil umum.
  Future<void> _handleProfileUpdate(Map<String, dynamic> updates,
      String successMessage, Emitter<ProfileState> emit) async {
    if (_currentProfileData == null) {
      emit(ProfileError(
          'Tidak dapat memperbarui: data profil tidak ditemukan.'));
      return;
    }
    emit(ProfileLoading()); // Emit loading saat update
    print('DEBUG PROFILE BLOC: Memulai update dengan data: $updates');

    try {
      final ProfileModel updatedProfileData = await profileService
          .updateUserDetail(updates); // Panggil service update
      _currentProfileData =
          updatedProfileData; // Simpan data yang sudah diperbarui

      emit(ProfileSuccess(successMessage)); // Emit state sukses
      emit(ProfileLoaded(
          _currentProfileData!)); // Emit state loaded dengan data baru
      print('DEBUG PROFILE BLOC: Update berhasil: $successMessage');
    } on AuthException catch (e) {
      print('DEBUG PROFILE BLOC: AuthException saat update: ${e.message}');
      if (_currentProfileData != null) {
        emit(ProfileLoaded(
            _currentProfileData!)); // Kembali ke data lama jika update gagal
      }
      emit(ProfileError(e.message)); // Emit state error
    } catch (e) {
      print(
          'DEBUG PROFILE BLOC: Error tak terduga saat update: ${e.runtimeType} - $e');
      if (_currentProfileData != null) {
        emit(ProfileLoaded(_currentProfileData!)); // Kembali ke data lama
      }
      emit(ProfileError(
          'Gagal memperbarui: ${e.toString()}')); // Emit error tidak terduga
    }
  }

  /// Handler untuk event UpdateBeratBadan.
  Future<void> _onUpdateBeratBadan(
      UpdateBeratBadan event, Emitter<ProfileState> emit) async {
    await _handleProfileUpdate({'berat_badan': event.beratBadan},
        'Berat badan berhasil diperbarui.', emit);
  }

  /// Handler untuk event UpdateTinggiBadan.
  Future<void> _onUpdateTinggiBadan(
      UpdateTinggiBadan event, Emitter<ProfileState> emit) async {
    await _handleProfileUpdate({'tinggi_badan': event.tinggiBadan},
        'Tinggi badan berhasil diperbarui.', emit);
  }

  /// Handler untuk event UpdateJenisKelamin.
  Future<void> _onUpdateJenisKelamin(
      UpdateJenisKelamin event, Emitter<ProfileState> emit) async {
    // Pastikan jenisKelamin.toApiString() tersedia dan benar
    await _handleProfileUpdate(
        {'jenis_kelamin': event.jenisKelamin.toApiString()},
        'Jenis kelamin berhasil diperbarui.',
        emit);
  }

  /// Handler untuk event UpdateAktivitas.
  Future<void> _onUpdateAktivitas(
      UpdateAktivitas event, Emitter<ProfileState> emit) async {
    // Pastikan aktivitas.toApiString() tersedia dan benar
    await _handleProfileUpdate({'aktivitas': event.aktivitas.toApiString()},
        'Tingkat aktivitas berhasil diperbarui.', emit);
  }

  /// Handler untuk event UpdateTujuan.
  Future<void> _onUpdateTujuan(
      UpdateTujuan event, Emitter<ProfileState> emit) async {
    // Pastikan tujuan.toApiString() tersedia dan benar (handle nullable)
    await _handleProfileUpdate({'tujuan': event.tujuan.toApiString()},
        'Tujuan berhasil diperbarui.', emit);
  }

  /// Handler untuk event DeleteProfile: Menghapus profil pengguna.
  Future<void> _onDeleteProfile(
      DeleteProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading()); // Emit loading saat hapus
    try {
      await profileService.deleteProfile(); // Panggil service hapus profil
      // --- PERBAIKAN: Ganti deleteJwtToken() menjadi deleteAuthToken() ---
      await authService
          .deleteAuthToken(); // Hapus token lokal setelah profil dihapus
      await authService.deleteUserData(); // Hapus juga data user lokal
      // --- AKHIR PERBAIKAN ---
      _currentProfileData = null; // Reset data profil lokal
      emit(ProfileSuccess(
          'Akun Anda berhasil dihapus.')); // Emit state sukses hapus
      emit(ProfileInitial()); // Kembali ke state awal
      print('DEBUG PROFILE BLOC: Akun berhasil dihapus.');
    } on AuthException catch (e) {
      emit(ProfileError(e.message)); // Emit error jika otentikasi gagal
    } catch (e) {
      emit(ProfileError(
          'Gagal menghapus akun: ${e.toString()}')); // Emit error tidak terduga
    }
  }

  /// Handler untuk event ResetProfileData: Mereset data profil (misalnya saat logout).
  Future<void> _onResetProfileData(
      ResetProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading()); // Emit loading
    // --- PERBAIKAN: Ganti deleteJwtToken() menjadi deleteAuthToken() ---
    await authService.deleteAuthToken(); // Hapus token lokal
    await authService.deleteUserData(); // Hapus juga data user lokal
    // --- AKHIR PERBAIKAN ---
    _currentProfileData = null; // Reset data profil lokal
    emit(ProfileSuccess('Anda telah berhasil keluar.')); // Emit state sukses
    emit(ProfileInitial()); // Kembali ke state awal
    print('DEBUG PROFILE BLOC: Data profil direset (logout).');
  }

  Future<void> _onUpdateContactInfo(
      UpdateContactInfo event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await profileService.updateContact(
        email: event.email,
        phone: event.phone,
      );
      // Refresh profil dari API (pakai getProfileData, supaya konsisten)
      final refreshed = await profileService.getProfileData();
      _currentProfileData = refreshed;

      emit(ProfileLoaded(refreshed));
      emit(ProfileSuccess('Kontak berhasil diperbarui'));
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError('Gagal memperbarui kontak: $e'));
    }
  }
}
