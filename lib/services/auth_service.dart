// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:vitacal_app/models/otp_model.dart'; // Asumsi ini otp_model.dart Anda
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/login_respon_model.dart'; // Asumsi ini login_response_model.dart Anda

class AuthService {
  final String _baseUrl = 'http://192.168.241.211:5000';
  Future<OtpResponse> registerUser({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/users'); // Endpoint registrasi

    try {
      print('AuthService: Mengirim permintaan registrasi ke: $url');
      print('AuthService: Body permintaan: ${jsonEncode(<String, String>{
            'username': username,
            'email': email,
            'phone': phone,
            'password': password,
          })}');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      print('AuthService: Status respons registrasi: ${response.statusCode}');
      print('AuthService: Body respons registrasi: ${response.body}');

      // Tangani respons berdasarkan status code
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('AuthService: Registrasi berhasil: $responseData');
        return OtpResponse.fromJson(responseData);
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
              'AuthService: Error decode JSON respons registrasi: $jsonError');
        }

        print(
            'AuthService: Registrasi gagal (Status: ${response.statusCode}): $errorMessage');
        print(
            'AuthService: Melempar AuthException dari blok ELSE (status non-201): "$errorMessage"');
        throw AuthException(
            errorMessage); // Ini yang harusnya ditangkap AuthBloc
      }
    } on http.ClientException catch (e) {
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet dan server aktif. (${e.message})'); // Pesan user-friendly
    }
  }

  // Metode untuk verifikasi OTP
  Future<bool> verifyOtp(String otpCode, String phoneNumber) async {
    final url =
        Uri.parse('$_baseUrl/users/verify-otp'); // Endpoint verifikasi OTP

    try {
      print('AuthService: Mengirim permintaan verifikasi OTP ke: $url');
      print('AuthService: Body permintaan: ${jsonEncode(<String, dynamic>{
            'otp': otpCode,
            'phone': phoneNumber,
          })}');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'otp': otpCode,
          'phone': phoneNumber,
        }),
      );

      print(
          'AuthService: Status respons verifikasi OTP: ${response.statusCode}');
      print('AuthService: Body respons verifikasi OTP: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('AuthService: Verifikasi OTP berhasil: $responseData');
        // Sesuaikan kondisi ini agar cocok dengan pesan sukses dari Flask Anda
        return responseData['message'] == 'Verifikasi berhasil';
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
              'AuthService: Error decode JSON respons verifikasi OTP: $jsonError');
        }

        print(
            'AuthService: Verifikasi OTP gagal (Status: ${response.statusCode}): $errorMessage');
        throw AuthException(errorMessage);
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: Error koneksi jaringan saat verifikasi OTP: ${e.message}');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet dan server aktif. (${e.message})');
    }
  }

  Future<LoginResponseModel> loginUser({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/users/login');

    try {
      print('AuthService: Mengirim permintaan login ke: $url');
      print('AuthService: Body permintaan: ${jsonEncode(<String, String>{
            'identifier': identifier,
            'password': password,
          })}');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'identifier': identifier,
          'password': password,
        }),
      );

      print('AuthService: Status respons login: ${response.statusCode}');
      print('AuthService: Body respons login: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('AuthService: Login berhasil: $responseData');
        return LoginResponseModel.fromJson(responseData);
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan yang tidak diketahui dari server.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
          print('AuthService: Error decode JSON respons login: $jsonError');
        }

        print(
            'AuthService: Login gagal (Status: ${response.statusCode}): $errorMessage');
        // --- DIAGNOSTIK BARU DI SINI ---
        print(
            'AuthService: Melempar AuthException dari blok ELSE (login status non-200): "$errorMessage"');
        throw AuthException(errorMessage);
      }
    } on http.ClientException catch (e) {
      print('AuthService: Error koneksi jaringan saat login: ${e.message}');
      // --- DIAGNOSTIK BARU DI SINI ---
      print(
          'AuthService: Melempar AuthException dari blok CLIENT_EXCEPTION (login): "${e.message}"');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet dan server aktif. (${e.message})');
    }
    // --- HAPUS BLOK CATCH UMUM DI SINI ---
    // Pastikan tidak ada blok `catch (e)` terakhir di loginUser
  }
}
