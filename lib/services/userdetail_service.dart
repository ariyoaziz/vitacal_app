// lib/services/userdetail_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/models/enums.dart';
import 'package:vitacal_app/services/constants.dart';

/// Service untuk berinteraksi dengan API terkait detail pengguna.
class UserDetailService {
  final String _baseUrl = AppConstants.baseUrl;

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, dynamic>> _sendAuthenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final token = await _getJwtToken();

    if (token == null) {
      throw AuthException('Anda belum login. Silakan login kembali.');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    http.Response response;

    try {
      switch (method.toUpperCase()) {
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
      throw AuthException(
          'Gagal terhubung ke server. Pastikan koneksi internet Anda stabil. (${e.message})');
    } catch (e) {
      throw AuthException('Terjadi masalah tak terduga: ${e.toString()}');
    }
  }

  Future<UserDetailModel> getUserDetail() async {
    final responseData =
        await _sendAuthenticatedRequest('user-detail', method: 'GET');
    return UserDetailModel.fromJson(responseData['user_detail']);
  }

  Future<UserDetailModel> updateUserDetail(Map<String, dynamic> updates) async {
    final responseData = await _sendAuthenticatedRequest(
      'user-detail',
      method: 'PUT',
      body: updates,
    );
    return UserDetailModel.fromJson(responseData['user_detail']);
  }

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

    try {
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

  Future<void> deleteUserDetail() async {
    await _sendAuthenticatedRequest('user-detail', method: 'DELETE');
  }

  // --- Metode Statis untuk Data Dummy Grafik ---
  static List<Map<String, dynamic>> getDummyWeightHistory() {
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

  static List<Map<String, dynamic>> getDummyCalorieData() {
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
