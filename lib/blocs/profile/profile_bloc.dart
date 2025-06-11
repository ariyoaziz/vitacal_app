import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/profile_service.dart'; // Import ProfileService yang baru
import 'profile_event.dart'; // Import event profil
import 'profile_state.dart'; // Import state profil
// Import ProfileModel yang baru

/// BLoC yang bertanggung jawab untuk mengelola state tampilan data profil pengguna.
/// Fokus hanya pada operasi GET (membaca/menampilkan data).
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;

  ProfileBloc({required this.profileService}) : super(ProfileInitial()) {
    on<LoadProfileData>(_onLoadProfileData);
  }

  /// Handler untuk event [LoadProfileData].
  /// Memuat data profil dari backend melalui ProfileService.
  Future<void> _onLoadProfileData(
      LoadProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading()); // Memancarkan state loading
    try {
      final profileData = await profileService.getProfileData();
      print('DEBUG: ProfileBloc - Data profil dimuat: ${profileData.nama}, ${profileData.email}, Berat: ${profileData.beratBadan}');
      emit(ProfileLoaded(profileData)); // Memancarkan state sukses dengan data
    } catch (e) {
      print('DEBUG: ProfileBloc - Error memuat profil: ${e.toString()}');
      emit(ProfileError(e.toString())); // Memancarkan state error jika gagal
    }
  }
}
