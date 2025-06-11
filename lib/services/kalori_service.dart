import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitacal_app/models/kalori_model.dart';
// Import model baru
import 'package:vitacal_app/exceptions/auth_exception.dart'; // Gunakan AuthException Anda
import 'package:vitacal_app/services/constants.dart'; // Pastikan AppConstants ada

class CalorieService {
  final String _baseUrl = AppConstants.baseUrl;

  Future<Map<String, dynamic>> _sendAuthenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      // Periksa juga jika token kosong
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

      print('DEBUG API: URL: $url');
      print('DEBUG API: Method: $method');
      print('DEBUG API: Status Code: ${response.statusCode}');
      print('DEBUG API: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          // Beberapa DELETE atau PUT mungkin mengembalikan body kosong
          return {}; // Mengembalikan map kosong jika body kosong
        }
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage;
        try {
          // Coba parse body respons untuk pesan kesalahan
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              errorData[
                  'msg'] ?? // Terkadang Flask-JWT-Extended menggunakan 'msg'
              'Terjadi kesalahan tidak diketahui dari server (Status: ${response.statusCode}).';
        } catch (jsonError) {
          // Jika body respons tidak valid JSON, gunakan pesan umum
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        // Jika status code adalah 401 atau 403, bisa jadi masalah otentikasi
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw AuthException(
              'Sesi Anda telah berakhir atau tidak valid. Silakan login kembali.');
        }
        throw AuthException(errorMessage);
      }
    } on http.ClientException catch (e) {
      // Kesalahan jaringan
      throw AuthException(
          'Gagal terhubung ke server. Pastikan koneksi internet Anda aktif. (${e.message})');
    } catch (e) {
      // Kesalahan lain yang tidak terduga
      print(
          'ERROR di _sendAuthenticatedRequest: ${e.toString()}'); // Log error untuk debugging
      throw AuthException('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  /// Mengambil data rekomendasi kalori dari API Flask.
  /// Asumsi: endpoint 'hitung-kalori' mengembalikan langsung objek KaloriModel.
  /// Jika backend mengembalikan objek yang bersarang (misal: {'data': {...}}),
  /// Anda perlu menyesuaikan sesuai respons backend Anda.
  Future<KaloriModel> fetchCalorieRecommendation() async {
    try {
      final responseData =
          await _sendAuthenticatedRequest('hitung-kalori', method: 'GET');
      // Berdasarkan log, respons API hitung-kalori bersarang di bawah kunci 'data'
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        return KaloriModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
      } else {
        throw AuthException(
            'Data rekomendasi kalori tidak ditemukan atau struktur respons tidak valid.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Menghapus data rekomendasi kalori untuk pengguna yang sedang login.
  Future<String> deleteCalorieRecommendation() async {
    try {
      final responseData =
          await _sendAuthenticatedRequest('delete-kalori', method: 'DELETE');
      if (responseData.containsKey('message') &&
          responseData['message'] != null) {
        return responseData['message'] as String;
      } else {
        // Jika backend sukses tapi tidak mengembalikan pesan, berikan pesan default
        return 'Data rekomendasi kalori berhasil dihapus.';
      }
    } catch (e) {
      rethrow;
    }
  }
}
