import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitacal_app/models/kalori_model.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/services/constants.dart'; // <<< Gunakan AuthException

class CalorieService {
  final String _baseUrl = AppConstants.baseUrl;

  // Helper untuk mendapatkan User ID dari SharedPreferences
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // Asumsi user ID disimpan sebagai int
  }

  // Helper generik untuk membuat permintaan API yang terautentikasi
  // Mengembalikan Map<String, dynamic> dari respons JSON
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
      switch (method) {
        case 'POST':
          response =
              await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response =
              await http.put(url, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        case 'GET':
        default:
          response = await http.get(url, headers: headers);
          break;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Cek jika body respons kosong atau bukan JSON sebelum decode
        if (response.body.isEmpty) {
          return {}; // Mengembalikan map kosong jika body kosong
        }
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan tidak diketahui dari server.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage); // <<< Gunakan AuthException
      }
    } on http.ClientException catch (e) {
      throw AuthException(
          'Gagal terhubung ke server. Pastikan koneksi internet Anda aktif. (${e.message})');
    } catch (e) {
      throw AuthException('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  /// Mengambil data rekomendasi kalori dari API Flask.
  Future<KaloriModel> fetchCalorieRecommendation() async {
    try {
      final responseData =
          await _sendAuthenticatedRequest('hitung-kalori', method: 'GET');
      // Periksa 'data' di dalam responseData, bukan responseData itu sendiri yang null
      if (responseData['data'] != null) {
        return KaloriModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
      } else {
        throw AuthException(
            'Data profil belum lengkap atau rekomendasi kalori tidak ditemukan.');
      }
    } catch (e) {
      // AuthException sudah cukup spesifik, tidak perlu rethrow
      rethrow; // Melemparkan kembali exception yang ada
    }
  }

  /// Menghapus data rekomendasi kalori untuk pengguna yang sedang login.
  Future<String> deleteCalorieRecommendation() async {
    try {
      final responseData =
          await _sendAuthenticatedRequest('delete-kalori', method: 'DELETE');
      if (responseData['message'] != null) {
        return responseData['message'] as String;
      } else {
        throw AuthException(
            'Tidak ada pesan sukses ditemukan dalam respons penghapusan rekomendasi kalori.');
      }
    } catch (e) {
      rethrow; // Melemparkan kembali exception yang ada
    }
  }

  // --- NEW METHOD: Get Daily Calorie Summary for Analytics Page ---
  Future<Map<String, dynamic>> getDailyCalorieSummary() async {
    final userId = await _getUserIdFromPrefs();
    if (userId == null) {
      throw AuthException('User ID tidak ditemukan. Mohon login ulang.');
    }
    // Asumsi endpoint backend untuk ringkasan kalori adalah /calories/summary/<user_id>
    final responseData = await _sendAuthenticatedRequest(
        'calories/summary/$userId',
        method: 'GET');
    // Jika responsnya adalah Map langsung, Anda bisa mengembalikan langsung
    return responseData;
  }

  // --- NEW METHOD: Get Weight History for Analytics Page ---
  Future<List<Map<String, dynamic>>> getWeightHistory() async {
    final userId = await _getUserIdFromPrefs();
    if (userId == null) {
      throw AuthException('User ID tidak ditemukan. Mohon login ulang.');
    }
    // Asumsi endpoint backend untuk riwayat berat adalah /weight-history/<user_id>
    final responseData = await _sendAuthenticatedRequest(
        'weight-history/$userId',
        method: 'GET');
    // Asumsi respons adalah Map dengan kunci 'history' yang berisi List
    if (responseData['history'] is List) {
      return List<Map<String, dynamic>>.from(responseData['history'] as List);
    }
    return []; // Mengembalikan list kosong jika tidak ada data history
  }
}
