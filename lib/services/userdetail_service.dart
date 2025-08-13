// lib/services/userdetail_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/models/enums.dart'; // Untuk toApiString()
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/services/constants.dart';
// Jika ProfileModel tidak digunakan langsung di sini, bisa dihapus
// import 'package:vitacal_app/models/profile_model.dart';

class UserDetailService {
  final String _baseUrl = AppConstants.baseUrl;
  final AuthService _authService; // Instance AuthService untuk otentikasi

  UserDetailService({required AuthService authService})
      : _authService =
            authService; // Inisialisasi AuthService melalui constructor

  /// Helper untuk mendapatkan header otentikasi dengan token JWT.
  Future<Map<String, String>> _getAuthHeaders() async {
    // --- PERBAIKAN: Ganti getJwtToken() menjadi getAuthToken() ---
    final token = await _authService
        .getAuthToken(); // Panggil metode yang benar di AuthService
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

  /// Mengambil data detail pengguna dari backend.
  /// Memanggil endpoint GET /user-detail.
  Future<UserDetailModel> getUserDetail() async {
    final url = Uri.parse('$_baseUrl/user-detail');
    try {
      final headers = await _getAuthHeaders(); // Menggunakan header otentikasi
      print(
          'DEBUG USERDETAIL_SERVICE: Mengirim permintaan GET /user-detail ke: $url');
      print('DEBUG USERDETAIL_SERVICE: Headers permintaan: $headers');

      final response = await http.get(url, headers: headers);

      print(
          'DEBUG USERDETAIL_SERVICE: Status respons GET /user-detail: ${response.statusCode}');
      print(
          'DEBUG USERDETAIL_SERVICE: Body respons GET /user-detail: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'DEBUG USERDETAIL_SERVICE: Raw response from backend GET /user-detail: $responseData');
        // Asumsi respons memiliki kunci 'user_detail' yang berisi data UserDetailModel
        if (responseData.containsKey('user_detail')) {
          return UserDetailModel.fromJson(responseData['user_detail']);
        } else {
          throw AuthException(
              'Respons sukses 200, tetapi data "user_detail" tidak ditemukan.');
        }
      } else if (response.statusCode == 401) {
        // Tangani Unauthorized secara spesifik
        throw AuthException(json.decode(response.body)['message'] ??
            'Unauthorized. Sesi habis atau token tidak valid.');
      } else if (response.statusCode == 404) {
        // Tangani Not Found secara spesifik (profil tidak ada di backend)
        throw AuthException(json.decode(response.body)['message'] ??
            'Data detail pengguna tidak ditemukan.');
      } else {
        // Tangani error HTTP lainnya (misal 400, 422, 500)
        final errorMessage = json.decode(response.body)['message'] ??
            'Gagal memuat detail pengguna.';
        print(
            'UserDetailService Error (getUserDetail): ${response.statusCode} - $errorMessage');
        throw AuthException(
            errorMessage); // Melempar AuthException untuk penanganan di Bloc
      }
    } on AuthException {
      rethrow; // Melempar kembali AuthException yang sudah spesifik
    } on http.ClientException catch (e) {
      // Tangani error koneksi jaringan
      print(
          'UserDetailService Error (getUserDetail - ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memuat detail pengguna: ${e.message}');
    } catch (e) {
      // Tangani error tak terduga lainnya
      print(
          'UserDetailService Error (getUserDetail - Unexpected): ${e.toString()}');
      throw Exception(
          'Error tak terduga saat memuat detail pengguna: ${e.toString()}');
    }
  }

  Future<UserDetailModel> addUserDetail({
    required int userId, // <--- Add this parameter
    required String nama,
    required int umur,
    required JenisKelamin jenisKelamin,
    required double beratBadan,
    required double tinggiBadan,
    required Aktivitas aktivitas,
    Tujuan? tujuan, // Optional
  }) async {
    final url = Uri.parse('$_baseUrl/user-detail');
    try {
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'nama': nama,
        'umur': umur,
        'jenis_kelamin': jenisKelamin.toApiString(),
        'berat_badan': beratBadan,
        'tinggi_badan': tinggiBadan,
        'aktivitas': aktivitas.toApiString(),
        'tujuan': tujuan?.toApiString(),
      });
      print('UserDetailService: Body permintaan addUserDetail: $body');
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'DEBUG USERDETAIL_SERVICE: Raw response from backend POST /user-detail (add): $responseData');
        if (responseData.containsKey('user_detail')) {
          return UserDetailModel.fromJson(responseData['user_detail']);
        } else {
          throw AuthException(
              'Respons sukses 200/201, tetapi data "user_detail" tidak ditemukan.');
        }
      } else if (response.statusCode == 401) {
        throw AuthException(json.decode(response.body)['message'] ??
            'Unauthorized. Sesi habis atau token tidak valid.');
      } else if (response.statusCode == 409) {
        throw AuthException(json.decode(response.body)['message'] ??
            'Data detail pengguna sudah ada. Gunakan update.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Gagal menambah detail pengguna.';
        print(
            'UserDetailService Error (addUserDetail): ${response.statusCode} - $errorMessage');
        throw AuthException(errorMessage);
      }
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'UserDetailService Error (addUserDetail - ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat menambah detail pengguna: ${e.message}');
    } catch (e) {
      print(
          'UserDetailService Error (addUserDetail - Unexpected): ${e.toString()}');
      throw Exception(
          'Error tak terduga saat menambah detail pengguna: ${e.toString()}');
    }
  }

  Future<UserDetailModel> updateUserDetail(Map<String, dynamic> updates) async {
    final url = Uri.parse('$_baseUrl/user-detail'); // URL yang sama
    try {
      final headers = await _getAuthHeaders();
      print(
          'DEBUG USERDETAIL_SERVICE: Mengirim permintaan PUT /user-detail ke: $url');
      print(
          'DEBUG USERDETAIL_SERVICE: Body permintaan: ${jsonEncode(updates)}');

      // --- PERBAIKAN PENTING: Gunakan http.put BUKAN http.post ---
      final response =
          await http.put(url, headers: headers, body: jsonEncode(updates));
      // --- AKHIR PERBAIKAN ---

      print(
          'DEBUG USERDETAIL_SERVICE: Status respons PUT /user-detail (update): ${response.statusCode}');
      print(
          'DEBUG USERDETAIL_SERVICE: Body respons PUT /user-detail (update): ${response.body}');

      if (response.statusCode == 200) {
        // Update biasanya mengembalikan 200 OK
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('user_detail')) {
          return UserDetailModel.fromJson(responseData['user_detail']);
        } else {
          throw AuthException(
              'Respons sukses 200, tetapi data "user_detail" tidak ditemukan.');
        }
      } else if (response.statusCode == 401) {
        throw AuthException(json.decode(response.body)['message'] ??
            'Unauthorized. Sesi habis atau token tidak valid.');
      } else if (response.statusCode == 404) {
        // Jika update dengan ID yang tidak ada
        throw AuthException(json.decode(response.body)['message'] ??
            'Detail pengguna tidak ditemukan.');
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Gagal memperbarui detail pengguna.';
        print(
            'UserDetailService Error (updateUserDetail): ${response.statusCode} - $errorMessage');
        throw AuthException(errorMessage);
      }
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      print(
          'UserDetailService Error (updateUserDetail - ClientException): ${e.toString()}');
      throw AuthException(
          'Gagal terhubung ke server saat memperbarui detail pengguna: ${e.message}');
    } catch (e) {
      print(
          'UserDetailService Error (updateUserDetail - Unexpected): ${e.toString()}');
      throw Exception(
          'Error tak terduga saat memperbarui detail pengguna: ${e.toString()}');
    }
  }

  Future<void> deleteUserDetail() async {
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

  // <<< Metode dummy data (getDummyWeightHistory, getDummyCalorieData) >>>
  // Ini diasumsikan untuk tujuan pengujian atau placeholder UI.
  // Jika ini bukan bagian dari UserDetailService yang sebenarnya, Anda bisa memindahkannya.
  Future<List<Map<String, dynamic>>> getDummyWeightHistory() async {
    return [
      {"date": "2024-01-01", "weight": 57.5},
      {"date": "2024-01-08", "weight": 58.0},
      {"date": "2024-01-15", "weight": 58.2},
      {"date": "2024-01-22", "weight": 57.9},
      {"date": "2024-01-29", "weight": 58.5},
      {"date": "2024-02-05", "weight": 58.3},
      {"date": "2024-02-12", "weight": 58.7},
      {"date": "2024-02-19", "weight": 58.9},
      {"date": "2024-02-26", "weight": 59.2},
      {"date": "2024-03-04", "weight": 59.0},
      {"date": "2024-03-11", "weight": 59.5},
      {"date": "2024-03-18", "weight": 59.3},
    ];
  }

  Future<List<Map<String, dynamic>>> getDummyCalorieData() async {
    return [
      {"date": "2024-06-01", "calories": 2000},
      {"date": "2024-06-02", "calories": 1800},
      {"date": "2024-06-03", "calories": 2200},
      {"date": "2024-06-04", "calories": 2100},
      {"date": "2024-06-05", "calories": 1950},
      {"date": "2024-06-06", "calories": 2300},
      {"date": "2024-06-07", "calories": 1750},
      {"date": "2024-06-08", "calories": 2050},
      {"date": "2024-06-09", "calories": 1900},
      {"date": "2024-06-10", "calories": 2150},
      {"date": "2024-06-11", "calories": 2000},
      {"date": "2024-06-12", "calories": 1850},
    ];
  }
}
