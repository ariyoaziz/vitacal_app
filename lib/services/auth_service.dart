// lib/services/auth_service.dart

// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import ini

import 'package:vitacal_app/models/otp_model.dart'; // Pastikan model ini ada
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/login_respon_model.dart'; // Pastikan model ini ada
import 'package:vitacal_app/services/constants.dart'; // Untuk AppConstants.baseUrl

class AuthService {
  final String _baseUrl = AppConstants.baseUrl;

  // >>>>>> BARU: Simpan token JWT <<<<<<
  Future<void> _saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    print('DEBUG AUTH: JWT Token saved to SharedPreferences.');
  }

  Future<bool> verifyTokenWithBackend(String token) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/users/verify-token');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['valid'] == true;
      } else {
        print(
            'Token tidak valid. Status code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print("AuthService Error saat verifikasi token: $e");
      return false;
    }
  }

  // >>>>>> BARU: Hapus token JWT <<<<<<
  Future<void> deleteJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    print('DEBUG AUTH: JWT Token removed from SharedPreferences.');
  }

  // >>>>>> BARU: Dapatkan token JWT <<<<<<
  Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<OtpResponse> registerUser({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/users');

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
        throw AuthException(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet dan server aktif. (${e.message})');
    }
  }

  Future<bool> verifyOtp(String otpCode, String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/users/verify-otp');

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

        final String? accessToken = responseData['access_token'];
        if (accessToken != null) {
          await _saveJwtToken(
              accessToken); // <<< SIMPAN TOKEN SAAT LOGIN BERHASIL
          print('AuthService: JWT token disimpan: $accessToken');
        } else {
          throw AuthException(
              'Login berhasil, namun token akses tidak ditemukan. Mohon coba lagi.');
        }

        return LoginResponseModel.fromJson(responseData);
      } else {
        String errorMessage;
        int? userIdFromError;
        String? phoneNumberFromError;

        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan yang tidak diketahui dari server.';
          userIdFromError = errorData['user_id'] as int?;
          phoneNumberFromError = errorData['phone'] as String?;
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
          print('AuthService: Error decode JSON respons login: $jsonError');
        }

        print(
            'AuthService: Login gagal (Status: ${response.statusCode}): $errorMessage');
        throw AuthException(
          errorMessage,
          userId: userIdFromError,
          phoneNumber: phoneNumberFromError,
        );
      }
    } on http.ClientException catch (e) {
      print('AuthService: Error koneksi jaringan saat login: ${e.message}');
      throw AuthException(
        'Gagal terhubung ke server. Pastikan Anda terhubung ke internet dan server aktif. (${e.message})',
      );
    }
  }

  Future<bool> requestPasswordReset({required String phoneNumber}) async {
    try {
      print(
          'AuthService: DEBUG - Memulai permintaan reset password ke: $_baseUrl/users/forgot-password/request');
      final response = await http.post(
        Uri.parse('$_baseUrl/users/forgot-password/request'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phone': phoneNumber,
        }),
      );
      print('AuthService: DEBUG - Status respons: ${response.statusCode}');
      print('AuthService: DEBUG - Body respons: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'AuthService: DEBUG - Permintaan reset berhasil. Pesan: ${responseData['message']}');
        return true;
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? 'Terjadi kesalahan dari server.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        print(
            'AuthService: DEBUG - Melempar AuthException dengan pesan ini: "$errorMessage"');
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: DEBUG - Menangkap http.ClientException. Pesan asli: "${e.message}"');
      throw AuthException(
        'Gagal terhubung ke server. Pastikan Anda terhubung ke internet. (${e.message})',
        phoneNumber: phoneNumber,
      );
    }
  }

  Future<bool> verifyResetPasswordOtp(
      {required String otpCode, required String phoneNumber}) async {
    final url = Uri.parse('$_baseUrl/users/forgot-password/verify-otp');
    try {
      print(
          'AuthService: Mengirim permintaan verifikasi OTP reset password ke: $url');
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
          'AuthService: Status respons verifikasi OTP reset: ${response.statusCode}');
      print('AuthService: Body respons verifikasi OTP reset: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'AuthService: Verifikasi OTP reset berhasil: ${responseData['message']}');
        return responseData['message'] == 'Verifikasi OTP reset berhasil.';
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
              'AuthService: Error decode JSON respons verifikasi OTP reset: $jsonError');
        }
        print('AuthService: Verifikasi OTP reset gagal: $errorMessage');
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: Error koneksi jaringan saat verifikasi OTP reset: ${e.message}');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet. (${e.message})',
          phoneNumber: phoneNumber);
    }
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/users/forgot-password/reset');
    try {
      print('AuthService: Mengirim permintaan reset password ke: $url');
      print('AuthService: Body permintaan: ${jsonEncode(<String, dynamic>{
            'phone': phoneNumber,
            'otp': otpCode,
            'new_password': newPassword,
          })}');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'phone': phoneNumber,
          'otp': otpCode,
          'new_password': newPassword,
        }),
      );

      print(
          'AuthService: Status respons reset password: ${response.statusCode}');
      print('AuthService: Body respons reset password: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'AuthService: Reset password berhasil: ${responseData['message']}');
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'Terjadi kesalahan saat mengatur password baru.';
        } catch (jsonError) {
          errorMessage =
              'Respons server tidak valid saat reset password (Status: ${response.statusCode}).';
          print('AuthService: Error decode JSON reset password: $jsonError');
        }
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: Error koneksi jaringan saat reset password: ${e.message}');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet. (${e.message})',
          phoneNumber: phoneNumber);
    }
  }
}
