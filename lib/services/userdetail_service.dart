// lib/services/userdetail_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart'; // Re-use AuthException
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/models/enums.dart'; // Impor Enum
import 'package:vitacal_app/services/constatans.dart'; // Import AppConstants

class UserDetailService {
  final String _baseUrl = AppConstants.baseUrl;

  // Assume this method exists to get user ID from SharedPreferences
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // Assuming user ID is stored as int
  }

  // Helper for authenticated requests (similar to CalorieService)
  Future<Map<String, dynamic>> _sendAuthenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw AuthException('Anda belum login. Silakan login kembali.');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    http.Response response;

    try {
      if (method == 'POST') {
        response =
            await http.post(url, headers: headers, body: jsonEncode(body));
      } else if (method == 'PUT') {
        // Added PUT method
        response =
            await http.put(url, headers: headers, body: jsonEncode(body));
      } else {
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan yang tidak diketahui dari server.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw AuthException('Gagal terhubung ke server. (${e.message})');
    } catch (e) {
      throw AuthException('Terjadi masalah tak terduga: ${e.toString()}');
    }
  }

  // --- NEW METHOD: Get User Detail ---
  Future<UserDetailModel> getUserDetail() async {
    final userId = await _getUserIdFromPrefs();
    if (userId == null) {
      throw AuthException('User ID tidak ditemukan. Mohon login ulang.');
    }
    // Assuming backend endpoint is something like /user-detail/<user_id>
    final responseData =
        await _sendAuthenticatedRequest('user-detail/$userId', method: 'GET');
    // Adjust key 'user_detail' based on your actual Flask response structure
    return UserDetailModel.fromJson(responseData['user_detail']);
  }

  // --- NEW METHOD: Update User Detail Weight ---
  Future<UserDetailModel> updateUserDetailWeight({
    required double newWeight,
    required double
        currentHeight, // Assuming height is needed for BMI recalc in backend
  }) async {
    final userId = await _getUserIdFromPrefs();
    if (userId == null) {
      throw AuthException('User ID tidak ditemukan. Mohon login ulang.');
    }

    // Assuming backend endpoint for updating user detail is /user-detail/<user_id> (PUT method)
    // And it expects 'berat_badan' and 'tinggi_badan' (for BMI recalc)
    final Map<String, dynamic> body = {
      'berat_badan': newWeight,
      'tinggi_badan':
          currentHeight, // Send height back to backend for BMI recalculation
    };
    final responseData = await _sendAuthenticatedRequest('user-detail/$userId',
        method: 'PUT', body: body);
    return UserDetailModel.fromJson(
        responseData['user_detail']); // Adjust key if needed
  }

  // --- NEW METHOD: Update User Detail Target Weight ---
  Future<UserDetailModel> updateUserDetailTargetWeight({
    required double newTargetWeight,
  }) async {
    final userId = await _getUserIdFromPrefs();
    if (userId == null) {
      throw AuthException('User ID tidak ditemukan. Mohon login ulang.');
    }

    // Assuming backend endpoint for updating user detail is /user-detail/<user_id> (PUT method)
    // And it expects 'target_berat_badan'
    final Map<String, dynamic> body = {
      'target_berat_badan':
          newTargetWeight, // Ensure this matches your backend field name
    };
    final responseData = await _sendAuthenticatedRequest('user-detail/$userId',
        method: 'PUT', body: body);
    return UserDetailModel.fromJson(responseData['user_detail']);
  }

  // Keep your existing addUserDetail method if it's still needed
  Future<UserDetailModel> addUserDetail({
    required int userId,
    required String nama,
    required int umur,
    required JenisKelamin jenisKelamin,
    required double beratBadan,
    required double tinggiBadan,
    required Aktivitas aktivitas,
    Tujuan? tujuan,
  }) async {
    final url = Uri.parse('$_baseUrl/user-detail');

    try {
      final Map<String, dynamic> body = {
        'user_id': userId,
        'nama': nama,
        'umur': umur,
        'jenis_kelamin': jenisKelamin.toApiString(),
        'berat_badan': beratBadan,
        'tinggi_badan': tinggiBadan,
        'aktivitas': aktivitas.toApiString(),
        'tujuan': tujuan?.toApiString(),
      };

      if (tujuan == null) {
        body.remove('tujuan');
      }

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UserDetailModel.fromJson(responseData['user_detail']);
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan yang tidak diketahui dari server.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw AuthException(
          'Gagal terhubung ke server. Pastikan koneksi internet Anda stabil. (${e.message})');
    } catch (e) {
      throw AuthException(
          'Terjadi masalah tak terduga saat tambah user detail. Mohon coba lagi nanti.');
    }
  }
}
