// lib/services/user_detail_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vitacal_app/exceptions/auth_exception.dart'; // Re-use AuthException
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/models/enums.dart'; // Impor Enum

class UserDetailService {
  final String _baseUrl =
      'http://192.168.241.211:5000'; // Pastikan IP ini sesuai

  Future<UserDetailModel> addUserDetail({
    required int userId,
    required String nama,
    required int umur,
    required JenisKelamin jenisKelamin,
    required double beratBadan,
    required double tinggiBadan,
    required Aktivitas aktivitas,
    Tujuan? tujuan, // Opsional
  }) async {
    // Asumsi endpoint adalah /user-details
    // Jika endpoint Anda adalah /users/<user_id>/details, sesuaikan URL-nya
    final url = Uri.parse('$_baseUrl/user-detail');

    try {
      final Map<String, dynamic> body = {
        'user_id': userId,
        'nama': nama,
        'umur': umur,
        'jenis_kelamin':
            jenisKelamin.toApiString(), // Konversi Enum ke string API
        'berat_badan': beratBadan,
        'tinggi_badan': tinggiBadan,
        'aktivitas': aktivitas.toApiString(), // Konversi Enum ke string API
        'tujuan': tujuan?.toApiString(), // Konversi Enum opsional
      };

      // Hapus tujuan jika null agar tidak dikirim ke API
      if (tujuan == null) {
        body.remove('tujuan');
      }

      print(
          'UserDetailService: Mengirim permintaan tambah user detail ke: $url');
      print('UserDetailService: Body permintaan: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      print(
          'UserDetailService: Status respons tambah user detail: ${response.statusCode}');
      print(
          'UserDetailService: Body respons tambah user detail: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'UserDetailService: Penambahan user detail berhasil: $responseData');
        return UserDetailModel.fromJson(responseData[
            'user_detail']); // Sesuaikan dengan struktur respons Flask Anda
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan yang tidak diketahui dari server.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
          print(
              'UserDetailService: Error decode JSON respons user detail: $jsonError');
        }
        print(
            'UserDetailService: Penambahan user detail gagal (Status: ${response.statusCode}): $errorMessage');
        throw AuthException(errorMessage); // Lempar AuthException
      }
    } on http.ClientException catch (e) {
      print(
          'UserDetailService: Error koneksi jaringan saat tambah user detail: ${e.message}');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan koneksi internet Anda stabil. (${e.message})');
    } catch (e) {
      print(
          'UserDetailService: Error tak terduga saat tambah user detail (catch umum): $e');
      throw AuthException(
          'Terjadi masalah tak terduga saat tambah user detail. Mohon coba lagi nanti.');
    }
  }
}
