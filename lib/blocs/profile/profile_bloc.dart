import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/profile_service.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/profile_model.dart';
import 'package:vitacal_app/models/enums.dart';

import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';
import 'package:vitacal_app/services/auth_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;
  final AuthService authService;

  ProfileModel? _currentProfileData;
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

  // ---------- Load ----------
  Future<void> _onLoadProfileData(
      LoadProfileData event, Emitter<ProfileState> emit) async {
    final hasData = state is ProfileLoaded && _currentProfileData != null;
    if (!hasData) emit(ProfileLoading());
    print('DEBUG PROFILE BLOC: Memulai loading data profil.');

    try {
      final ProfileModel newProfileData = await profileService.getProfileData();
      _currentProfileData = newProfileData;
      emit(ProfileLoaded(_currentProfileData!));
      print('DEBUG PROFILE BLOC: Data profil berhasil dimuat dari API.');
    } on AuthException catch (e) {
      print('DEBUG PROFILE BLOC: AuthException saat load profil: ${e.message}');
      await authService.deleteAuthToken();
      await authService.deleteUserData();
      _currentProfileData = null;
      emit(ProfileError(e.message));
    } catch (e) {
      print('DEBUG PROFILE BLOC: Exception tak terduga saat load profil: $e');
      emit(ProfileError(
          'Terjadi masalah tak terduga saat memuat data profil. Silakan coba lagi.'));
    }
  }

  // ---------- Helper Update (gunakan re-fetch setelah update) ----------
  Future<void> _handleProfileUpdate(
    Map<String, dynamic> updates,
    String successMessage,
    Emitter<ProfileState> emit,
  ) async {
    if (_currentProfileData == null) {
      emit(ProfileError('Tidak dapat memperbarui: data profil tidak ditemukan.'));
      return;
    }

    // Boleh tampilkan loading singkat saat update
    emit(ProfileLoading());
    print('DEBUG PROFILE BLOC: Memulai update dengan data: $updates');

    try {
      // 1) Update detail ke server
      await profileService.updateUserDetail(updates);

      // 2) Re-fetch penuh agar rekomendasi_kalori_data pasti terbaru
      final ProfileModel refreshed = await profileService.getProfileData();
      _currentProfileData = refreshed;

      // 3) Emit success -> loaded (Loaded terakhir agar halaman yang listen Loaded selalu terpicu)
      emit(ProfileSuccess(successMessage));
      emit(ProfileLoaded(_currentProfileData!));
      print('DEBUG PROFILE BLOC: Update berhasil: $successMessage');
    } on AuthException catch (e) {
      print('DEBUG PROFILE BLOC: AuthException saat update: ${e.message}');
      if (_currentProfileData != null) {
        // Kembalikan ke data lama agar UI tidak blank
        emit(ProfileLoaded(_currentProfileData!));
      }
      emit(ProfileError(e.message));
    } catch (e) {
      print('DEBUG PROFILE BLOC: Error tak terduga saat update: $e');
      if (_currentProfileData != null) {
        emit(ProfileLoaded(_currentProfileData!));
      }
      emit(ProfileError('Gagal memperbarui: $e'));
    }
  }

  // ---------- Update Fields ----------
  Future<void> _onUpdateBeratBadan(
      UpdateBeratBadan event, Emitter<ProfileState> emit) async {
    await _handleProfileUpdate(
      {'berat_badan': event.beratBadan},
      'Berat badan berhasil diperbarui.',
      emit,
    );
  }

  Future<void> _onUpdateTinggiBadan(
      UpdateTinggiBadan event, Emitter<ProfileState> emit) async {
    await _handleProfileUpdate(
      {'tinggi_badan': event.tinggiBadan},
      'Tinggi badan berhasil diperbarui.',
      emit,
    );
  }

  Future<void> _onUpdateJenisKelamin(
      UpdateJenisKelamin event, Emitter<ProfileState> emit) async {
    await _handleProfileUpdate(
      {'jenis_kelamin': event.jenisKelamin.toApiString()},
      'Jenis kelamin berhasil diperbarui.',
      emit,
    );
  }

  Future<void> _onUpdateAktivitas(
      UpdateAktivitas event, Emitter<ProfileState> emit) async {
    await _handleProfileUpdate(
      {'aktivitas': event.aktivitas.toApiString()},
      'Tingkat aktivitas berhasil diperbarui.',
      emit,
    );
  }

  Future<void> _onUpdateTujuan(
      UpdateTujuan event, Emitter<ProfileState> emit) async {
    await _handleProfileUpdate(
      {'tujuan': event.tujuan.toApiString()},
      'Tujuan berhasil diperbarui.',
      emit,
    );
  }

  // ---------- Update contact (diseragamkan urutan emit) ----------
  Future<void> _onUpdateContactInfo(
      UpdateContactInfo event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await profileService.updateContact(
        email: event.email,
        phone: event.phone,
      );

      final refreshed = await profileService.getProfileData();
      _currentProfileData = refreshed;

      emit(const ProfileSuccess('Kontak berhasil diperbarui'));
      emit(ProfileLoaded(refreshed)); // Loaded terakhir
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError('Gagal memperbarui kontak: $e'));
    }
  }

  // ---------- Delete ----------
  Future<void> _onDeleteProfile(
      DeleteProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await profileService.deleteProfile();
      await authService.deleteAuthToken();
      await authService.deleteUserData();
      _currentProfileData = null;

      emit(const ProfileSuccess('Akun Anda berhasil dihapus.'));
      emit(ProfileInitial());
      print('DEBUG PROFILE BLOC: Akun berhasil dihapus.');
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError('Gagal menghapus akun: $e'));
    }
  }

  // ---------- Reset (Logout) ----------
  Future<void> _onResetProfileData(
      ResetProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    await authService.deleteAuthToken();
    await authService.deleteUserData();
    _currentProfileData = null;

    emit(const ProfileSuccess('Anda telah berhasil keluar.'));
    emit(ProfileInitial());
    print('DEBUG PROFILE BLOC: Data profil direset (logout).');
  }
}
