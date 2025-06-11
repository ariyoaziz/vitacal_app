import 'package:vitacal_app/models/profile_model.dart'; // Import ProfileModel
import 'package:vitacal_app/services/userdetail_service.dart'; // Import UserDetailService (asumsi ini yang melakukan HTTP request)
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
      // Asumsi getProfileDataRaw() mengembalikan Map<String, dynamic> dari respons JSON
      final Map<String, dynamic> rawResponse =
          await _userDetailService.getProfileDataRaw();

      // DEBUGGING: Untuk melihat respons mentah sebelum parsing
      print(
          'DEBUG PROFILE_SERVICE: Raw response from getProfileDataRaw: $rawResponse');

      // Periksa apakah respons memiliki kunci 'user' yang diharapkan dari backend /profile
      if (rawResponse.containsKey('user') && rawResponse['user'] != null) {
        // Kemudian parse Map mentah ini ke ProfileModel
        return ProfileModel.fromJson(rawResponse);
      } else {
        // Jika struktur respons tidak sesuai harapan (tidak ada kunci 'user')
        throw AuthException('Struktur data profil tidak valid dari server.');
      }
      // ignore: unused_catch_clause
    } on AuthException catch (e) {
      // Melemparkan kembali AuthException yang berasal dari _userDetailService
      // Ini penting agar BLoC dapat menangkap AuthException yang spesifik.
      rethrow;
    } catch (e) {
      // Menangkap kesalahan lain yang tidak terduga
      print(
          'ERROR di ProfileService.getProfileData: ${e.toString()}'); // Log error untuk debugging
      throw AuthException(
          "Terjadi kesalahan tidak terduga saat mengambil data profil: ${e.toString()}");
    }
  }
}
