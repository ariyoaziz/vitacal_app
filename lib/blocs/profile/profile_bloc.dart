// lib/blocs/profile/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/profile_service.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/profile_model.dart';
// import 'package:vitacal_app/models/user_detail_model.dart'; // <<< HAPUS IMPORT INI (unused_import)

import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;
  ProfileModel? _currentProfileData;

  ProfileBloc({required this.profileService}) : super(ProfileInitial()) {
    // <<< HAPUS 'const' DI SINI
    on<LoadProfileData>(_onLoadProfileData);
    on<ResetProfileData>(_onResetProfileData);
  }

  Future<void> _onLoadProfileData(
      LoadProfileData event, Emitter<ProfileState> emit) async {
    // 1. Jika ada data lama, tampilkan dulu untuk responsifitas (UI tidak kosong/loading spinner terus-menerus)
    if (_currentProfileData != null) {
      emit(ProfileLoaded(_currentProfileData!));
      print('DEBUG PROFILE BLOC: Menampilkan data profil yang sudah ada.');
    } else {
      // Jika belum ada data sama sekali, tampilkan loading spinner
      emit(ProfileLoading()); // <<< HAPUS 'const' DI SINI
      print('DEBUG PROFILE BLOC: Memulai loading data profil (pertama kali).');
    }

    try {
      final ProfileModel newProfileData = await profileService.getProfileData();

      // DEBUGGING: Untuk melihat perbandingan
      print('DEBUG PROFILE BLOC: Data profil lama: $_currentProfileData');
      print('DEBUG PROFILE BLOC: Data profil baru dari API: $newProfileData');

      // 2. Bandingkan data baru dengan data yang sudah ada
      if (_currentProfileData != newProfileData) {
        _currentProfileData = newProfileData;
        emit(ProfileLoaded(_currentProfileData!));
        print(
            'DEBUG PROFILE BLOC: Data profil diperbarui karena ada perubahan dari API.');
      } else {
        print(
            'DEBUG PROFILE BLOC: Data profil tidak berubah, tidak ada pembaruan UI.');
      }
    } on AuthException catch (e) {
      if (_currentProfileData != null) {
        emit(ProfileLoaded(_currentProfileData!));
        emit(ProfileError(e.message));
        print(
            'DEBUG PROFILE BLOC: AuthException saat memuat profil: ${e.message}');
      } else {
        emit(ProfileError(e.message));
        print(
            'DEBUG PROFILE BLOC: Error pertama kali memuat profil (AuthException): ${e.message}');
      }
    } catch (e) {
      if (_currentProfileData != null) {
        emit(ProfileLoaded(_currentProfileData!));
        emit(ProfileError(
            'Terjadi kesalahan tidak terduga saat memuat profil: ${e.toString()}'));
        print(
            'DEBUG PROFILE BLOC: Error tak terduga saat memuat profil: ${e.toString()}');
      } else {
        emit(ProfileError(
            'Terjadi kesalahan tidak terduga saat memuat profil: ${e.toString()}'));
        print(
            'DEBUG PROFILE BLOC: Error pertama kali memuat profil (tak terduga): ${e.toString()}');
      }
    }
  }

  void _onResetProfileData(ResetProfileData event, Emitter<ProfileState> emit) {
    _currentProfileData = null;
    emit(ProfileInitial());
    print('DEBUG PROFILE BLOC: Data profil direset.');
  }
}
