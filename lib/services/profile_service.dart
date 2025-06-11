import 'package:vitacal_app/models/profile_model.dart'; // Import ProfileModel
import 'package:vitacal_app/services/userdetail_service.dart'; // Import UserDetailService
import 'package:vitacal_app/exceptions/auth_exception.dart'; // Import AuthException

/// Service untuk mengambil data profil pengguna.
/// Bertanggung jawab untuk mendapatkan data ProfileModel lengkap.
class ProfileService {
  final UserDetailService _userDetailService;

  ProfileService({UserDetailService? userDetailService})
      : _userDetailService = userDetailService ?? UserDetailService();

  /// Mengambil data profil lengkap dari backend.
  /// Memanggil endpoint `/profile` di Flask yang mengembalikan struktur gabungan.
  Future<ProfileModel> getProfileData() async {
    try {
      // Panggil method getProfileDataRaw() dari UserDetailService
      final Map<String, dynamic> rawResponse =
          await _userDetailService.getProfileDataRaw();
      // Kemudian parse Map mentah ini ke ProfileModel
      return ProfileModel.fromJson(rawResponse);
    } catch (e) {
      throw AuthException("Gagal mengambil data profil: ${e.toString()}");
    }
  }
}
