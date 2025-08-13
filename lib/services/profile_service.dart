// lib/services/profile_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http; // Butuh ini untuk http.get
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/profile_model.dart'; // Pastikan model ini ada
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/services/auth_service.dart'; // Butuh ini untuk _authService
import 'package:vitacal_app/services/constants.dart'; // Butuh ini untuk AppConstants.baseUrl
import 'package:vitacal_app/models/enums.dart'; // Tetap butuh ini untuk toApiString()

class ProfileService {
  final UserDetailService _userDetailService;
  final AuthService _authService; // Service untuk otentikasi
  final String _baseUrl = AppConstants.baseUrl; // Base URL dari konstanta

  ProfileService({
    required UserDetailService userDetailService,
    required AuthService authService,
  })  : _userDetailService = userDetailService,
        _authService = authService; // Inisialisasi service di constructor

  /// Helper untuk mendapatkan header otentikasi dengan token JWT.
  Future<Map<String, String>> _getAuthHeaders() async {
    // --- PERBAIKAN: Ganti getJwtToken() menjadi getAuthToken() ---
    final token = await _authService.getAuthToken();
    // --- AKHIR PERBAIKAN ---

    if (token == null) {
      throw AuthException(
          'Token autentikasi tidak ditemukan. Harap login kembali.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // Format header otorisasi JWT
    };
  }

  /// Metode untuk mengambil data profil lengkap dari backend.
  /// Ini akan memanggil endpoint /profile di backend.
  Future<ProfileModel> getProfileData() async {
    final url = Uri.parse(
        '$_baseUrl/profile'); // Memanggil endpoint /profile di backend
    try {
      final headers = await _getAuthHeaders(); // Menggunakan header otentikasi
      print('DEBUG PROFILE_SERVICE: Mengirim permintaan GET /profile ke: $url');
      print(
          'DEBUG PROFILE_SERVICE: Headers permintaan: $headers'); // Log header untuk debugging

      final response = await http.get(url, headers: headers);

      print(
          'DEBUG PROFILE_SERVICE: Status respons GET /profile: ${response.statusCode}');
      print(
          'DEBUG PROFILE_SERVICE: Body respons GET /profile: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'DEBUG PROFILE_SERVICE: Raw response from backend GET /profile: $responseData');
        // Mengurai respons lengkap ke ProfileModel.
        // Pastikan ProfileModel.fromJson bisa menangani semua data yang dikembalikan backend /profile
        return ProfileModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // Tangani Unauthorized secara spesifik
        throw AuthException(json.decode(response.body)['message'] ??
            'Unauthorized. Sesi habis atau token tidak valid.');
      } else if (response.statusCode == 404) {
        // Tangani Not Found secara spesifik (profil tidak ada di backend)
        throw AuthException(json.decode(response.body)['message'] ??
            'Data profil tidak ditemukan.');
      } else {
        // Tangani error HTTP lainnya
        final errorMessage = json.decode(response.body)['message'] ??
            'Gagal memuat data profil.';
        print(
            'ProfileService Error (getProfileData): ${response.statusCode} - $errorMessage');
        throw AuthException(
            errorMessage); // Melempar AuthException untuk penanganan di Bloc
      }
    } on AuthException {
      rethrow; // Melempar kembali AuthException yang sudah spesifik
    } on http.ClientException catch (e) {
      // Tangani error koneksi jaringan
      print(
          'ERROR di ProfileService.getProfileData (ClientException): ${e.toString()}');
      throw AuthException(
          "Gagal terhubung ke server saat mengambil data profil: ${e.message}");
    } catch (e) {
      // Tangani error tak terduga lainnya
      print(
          'ERROR di ProfileService.getProfileData (Unexpected): ${e.toString()}');
      throw AuthException(
          "Terjadi kesalahan tidak terduga saat mengambil data profil: ${e.toString()}");
    }
  }

  /// Memperbarui detail pengguna melalui UserDetailService, lalu mengambil data profil terbaru.
  Future<ProfileModel> updateUserDetail(Map<String, dynamic> updates) async {
    try {
      // Panggil updateUserDetail dari _userDetailService (yang mengembalikan UserDetailModel)
      await _userDetailService.updateUserDetail(updates);

      // Setelah UserDetail diperbarui, kita perlu mengambil ProfileModel LENGKAP terbaru
      // untuk memastikan data BMI/RekomendasiKalori juga terbaru
      print(
          'DEBUG PROFILE_SERVICE: UserDetail berhasil diperbarui. Mengambil ProfileModel terbaru...');
      return await getProfileData(); // Panggil getProfileData() di ProfileService ini
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'ERROR di ProfileService.updateUserDetail (ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui detail pengguna: ${e.message}');
    } catch (e) {
      print(
          'ERROR di ProfileService.updateUserDetail (Unexpected): ${e.toString()}');
      throw AuthException('Gagal memperbarui detail pengguna: ${e.toString()}');
    }
  }

  /// Memperbarui berat badan pengguna.
  Future<void> updateBeratBadan(double beratBadan) async {
    try {
      await updateUserDetail({'berat_badan': beratBadan});
      print(
          'DEBUG PROFILE_SERVICE: Berat badan berhasil diperbarui ke $beratBadan');
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'ERROR di ProfileService.updateBeratBadan (ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui berat badan: ${e.message}');
    } catch (e) {
      print(
          'ERROR di ProfileService.updateBeratBadan (Unexpected): ${e.toString()}');
      throw AuthException('Gagal memperbarui berat badan: ${e.toString()}');
    }
  }

  /// Memperbarui tinggi badan pengguna.
  Future<void> updateTinggiBadan(double tinggiBadan) async {
    try {
      await updateUserDetail({'tinggi_badan': tinggiBadan});
      print(
          'DEBUG PROFILE_SERVICE: Tinggi badan berhasil diperbarui ke $tinggiBadan');
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'ERROR di ProfileService.updateTinggiBadan (ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui tinggi badan: ${e.message}');
    } catch (e) {
      print(
          'ERROR di ProfileService.updateTinggiBadan (Unexpected): ${e.toString()}');
      throw AuthException('Gagal memperbarui tinggi badan: ${e.toString()}');
    }
  }

  /// Memperbarui jenis kelamin pengguna.
  Future<void> updateJenisKelamin(JenisKelamin jenisKelamin) async {
    try {
      await updateUserDetail({'jenis_kelamin': jenisKelamin.toApiString()});
      print(
          'DEBUG PROFILE_SERVICE: Jenis kelamin berhasil diperbarui ke ${jenisKelamin.toApiString()}');
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'ERROR di ProfileService.updateJenisKelamin (ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui jenis kelamin: ${e.message}');
    } catch (e) {
      print(
          'ERROR di ProfileService.updateJenisKelamin (Unexpected): ${e.toString()}');
      throw AuthException('Gagal memperbarui jenis kelamin: ${e.toString()}');
    }
  }

  /// Memperbarui tingkat aktivitas pengguna.
  Future<void> updateAktivitas(Aktivitas aktivitas) async {
    try {
      await updateUserDetail({'aktivitas': aktivitas.toApiString()});
      print(
          'DEBUG PROFILE_SERVICE: Aktivitas berhasil diperbarui ke ${aktivitas.toApiString()}');
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'ERROR di ProfileService.updateAktivitas (ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui aktivitas: ${e.message}');
    } catch (e) {
      print(
          'ERROR di ProfileService.updateAktivitas (Unexpected): ${e.toString()}');
      throw AuthException('Gagal memperbarui aktivitas: ${e.toString()}');
    }
  }

  /// Memperbarui tujuan pengguna.
  Future<void> updateTujuan(Tujuan? tujuan) async {
    try {
      await updateUserDetail({'tujuan': tujuan?.toApiString()});
      print(
          'DEBUG PROFILE_SERVICE: Tujuan berhasil diperbarui ke ${tujuan?.toApiString() ?? 'null'}');
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'ERROR di ProfileService.updateTujuan (ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui tujuan: ${e.message}');
    } catch (e) {
      print(
          'ERROR di ProfileService.updateTujuan (Unexpected): ${e.toString()}');
      throw AuthException('Gagal memperbarui tujuan: ${e.toString()}');
    }
  }

  Future<void> deleteProfile() async {
    final url = Uri.parse(
        '$_baseUrl/users'); // URL ini harus cocok dengan rute di Flask
    try {
      final headers = await _getAuthHeaders();
      final response =
          await http.delete(url, headers: headers); // Menggunakan metode DELETE

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('UserDetailService: Profil berhasil dihapus.');
        return;
      } else if (response.statusCode == 401) {
        throw AuthException(json.decode(response.body)['message'] ??
            'Unauthorized. Sesi habis atau token tidak valid.');
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Gagal menghapus profil.';
        print(
            'UserDetailService Error (deleteUserDetail): ${response.statusCode} - $errorMessage');
        throw AuthException(errorMessage); // Melempar AuthException
      }
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'UserDetailService Error (deleteUserDetail - ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat menghapus profil: ${e.message}');
    } catch (e) {
      print(
          'UserDetailService Error (deleteUserDetail - Unexpected): ${e.toString()}');
      throw Exception(
          'Error tak terduga saat menghapus profil: ${e.toString()}');
    }
  }

  /// Memperbarui kontak (email / phone) user.
  /// Kirim hanya field yang diisi (opsional keduanya).
  Future<void> updateContact({String? email, String? phone}) async {
    // Validasi minimal: harus ada salah satu yang dikirim
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      throw AuthException('Tidak ada perubahan: email/nomor harus diisi.');
    }

    final url = Uri.parse('$_baseUrl/profile/contact');
    // NOTE: ganti path ini sesuai backend kamu jika beda (mis: '/users/contact' atau '/profile')

    try {
      final headers = await _getAuthHeaders();

      // Hanya kirim kunci yang ada nilainya
      final Map<String, dynamic> payload = {};
      if (email != null && email.isNotEmpty) payload['email'] = email;
      if (phone != null && phone.isNotEmpty) payload['phone'] = phone;

      final resp = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      // Debug log (opsional)
      // print('DEBUG PROFILE_SERVICE: PATCH $url => ${resp.statusCode} ${resp.body}');

      if (resp.statusCode == 200) {
        // sukses; tidak perlu return apa-apa
        return;
      } else if (resp.statusCode == 401) {
        throw AuthException(jsonDecode(resp.body)['message'] ??
            'Unauthorized. Sesi habis atau token tidak valid.');
      } else {
        final msg = () {
          try {
            return jsonDecode(resp.body)['message'] as String?;
          } catch (_) {
            return null;
          }
        }();
        throw AuthException(msg ?? 'Gagal memperbarui kontak.');
      }
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui kontak: ${e.message}');
    } catch (e) {
      throw AuthException('Gagal memperbarui kontak: $e');
    }
  }
}
