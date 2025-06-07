// lib/services/calorie_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mendapatkan JWT token

import 'package:vitacal_app/models/kalori_model.dart'; // Menggunakan kalori_model.dart
import 'package:vitacal_app/exceptions/api_exception.dart'; // Menggunakan api_exception.dart

class CalorieService {
  // PENTING: Ganti dengan IP atau domain backend Flask Anda yang sebenarnya
  // Untuk Android Emulator: 'http://10.0.2.2:5000'
  // Untuk iOS Simulator: 'http://127.0.0.1:5000'
  // Untuk Perangkat Fisik: 'http://YOUR_LOCAL_IP:5000'
  final String _baseUrl =
      'http://192.168.241.211:5000'; // Menggunakan IP dari contoh AuthService Anda

  // Helper generik untuk membuat permintaan API yang terautentikasi
  Future<Map<String, dynamic>?> _sendAuthenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('jwt_token'); // Dapatkan JWT token yang tersimpan

    // --- DIAGNOSTIK BARU: LOG NILAI TOKEN ---
    print(
        'CalorieService: Token yang diambil dari SharedPreferences: $token (untuk endpoint $endpoint)');
    // ----------------------------------------

    if (token == null) {
      print(
          'CalorieService: Error - JWT token not found for authenticated request to $endpoint.');
      throw ApiException('Anda belum login. Silakan login kembali.');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // Lampirkan JWT token
    };

    http.Response response;

    try {
      print('CalorieService: Mengirim permintaan $method ke $url');
      print('CalorieService: Headers: $headers');
      if (body != null) {
        print('CalorieService: Body: ${jsonEncode(body)}');
      }

      switch (method) {
        case 'POST':
          response =
              await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        case 'GET':
        default:
          response = await http.get(url, headers: headers);
          break;
      }

      print(
          'CalorieService: Status Respons untuk $endpoint: ${response.statusCode}');
      print('CalorieService: Body Respons untuk $endpoint: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan tidak diketahui dari server.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
          print(
              'CalorieService: Error mendekode JSON untuk $endpoint: $jsonError');
        }
        print(
            'CalorieService: Error API untuk $endpoint: $errorMessage (Status: ${response.statusCode})');
        throw ApiException(errorMessage,
            statusCode: response.statusCode); // Tambahkan status code
      }
    } on http.ClientException catch (e) {
      print('CalorieService: Error jaringan untuk $endpoint: ${e.message}');
      throw ApiException(
          'Gagal terhubung ke server. Pastikan koneksi internet Anda aktif. (${e.message})');
    } catch (e) {
      print('CalorieService: Error tidak terduga untuk $endpoint: $e');
      throw ApiException('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Mengambil data rekomendasi kalori dari API Flask.
  Future<KaloriModel> fetchCalorieRecommendation() async {
    try {
      final responseData =
          await _sendAuthenticatedRequest('hitung-kalori', method: 'GET');
      if (responseData != null && responseData['data'] != null) {
        print('CalorieService: Berhasil mengambil data kalori.');
        return KaloriModel.fromJson(
            responseData['data']); // Menggunakan KaloriModel
      } else {
        print(
            'CalorieService: Tidak ada data ditemukan dalam respons rekomendasi kalori.');
        throw ApiException(
            'Data profil belum lengkap atau rekomendasi kalori tidak ditemukan.');
      }
    } catch (e) {
      print('CalorieService: Error di fetchCalorieRecommendation: $e');
      rethrow; // Melemparkan kembali ApiException dari _sendAuthenticatedRequest
    }
  }

  /// Menghapus data rekomendasi kalori untuk pengguna yang sedang login.
  Future<String> deleteCalorieRecommendation() async {
    try {
      final responseData =
          await _sendAuthenticatedRequest('delete-kalori', method: 'DELETE');
      if (responseData != null && responseData['message'] != null) {
        print('CalorieService: Berhasil menghapus rekomendasi kalori.');
        return responseData['message'] as String;
      } else {
        print(
            'CalorieService: Tidak ada pesan sukses ditemukan dalam respons penghapusan rekomendasi kalori.');
        throw ApiException('Gagal menghapus rekomendasi kalori.');
      }
    } catch (e) {
      print('CalorieService: Error di deleteCalorieRecommendation: $e');
      rethrow; // Melemparkan kembali ApiException dari _sendAuthenticatedRequest
    }
  }
}
