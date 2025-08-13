// lib/services/auth_service.dart

// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitacal_app/models/otp_model.dart'; // Pastikan model ini ada
import 'package:vitacal_app/exceptions/auth_exception.dart'; // Pastikan ini ada
import 'package:vitacal_app/models/user_model.dart'; // Pastikan User model ini ada dan pathnya benar
import 'package:vitacal_app/services/constants.dart'; // Untuk AppConstants.baseUrl

class AuthService {
  final String _baseUrl = AppConstants.baseUrl;

  // Helper internal untuk mendapatkan SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // --- Metode Publik untuk Mengelola Token JWT dan Data Pengguna ---

  /// Menyimpan token JWT ke SharedPreferences.
  Future<void> saveAuthToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString('jwt_token', token);
    print('DEBUG AUTH: JWT Token saved to SharedPreferences.');
  }

  /// Mengambil token JWT dari SharedPreferences.
  Future<String?> getAuthToken() async {
    final prefs = await _getPrefs();
    return prefs.getString('jwt_token');
  }

  /// Menghapus token JWT dari SharedPreferences.
  Future<void> deleteAuthToken() async {
    final prefs = await _getPrefs();
    await prefs.remove('jwt_token');
    print('DEBUG AUTH: JWT Token removed from SharedPreferences.');
  }

  /// Menyimpan data pengguna (seperti userId, username, email, phone) ke SharedPreferences.
  /// Membutuhkan kelas `User` yang benar di `user_model.dart`.
  Future<void> saveUserData(User user) async {
    final prefs = await _getPrefs();
    await prefs.setInt('user_id', user.userId);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('phone', user.phone);
    await prefs.setBool('verified',
        user.verified ?? false); // Pastikan user.verified adalah bool?
    print(
        'DEBUG AUTH: User data (userId: ${user.userId}) saved to SharedPreferences.');
  }

  /// Mengambil userId dari SharedPreferences.
  Future<int?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getInt('user_id');
  }

  /// Menghapus data pengguna dari SharedPreferences.
  Future<void> deleteUserData() async {
    final prefs = await _getPrefs();
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('verified');
    print('DEBUG AUTH: User data removed from SharedPreferences.');
  }

  /// Memverifikasi token JWT saat ini dengan backend.
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
            'AuthService: Token tidak valid. Status code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print("AuthService Error saat verifikasi token: $e");
      return false;
    }
  }

  // --- Metode Alur Autentikasi Utama ---

  /// Mendaftarkan pengguna baru dan meminta OTP.
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
          print(
              'AuthService: Error decode JSON respons registrasi: $jsonError');
        }

        print(
            'AuthService: Registrasi gagal (Status: ${response.statusCode}): $errorMessage');
        throw AuthException(
          errorMessage,
          userId: userIdFromError,
          phoneNumber: phoneNumberFromError,
        );
      }
    } on http.ClientException catch (e) {
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet dan server aktif. (${e.message})');
    } catch (e) {
      throw AuthException('Terjadi masalah tak terduga saat registrasi: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String otpCode, String phoneNumber) async {
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

        final String? accessToken = responseData['access_token'];
        if (accessToken != null) {
          await saveAuthToken(accessToken);
          if (responseData.containsKey('user')) {
            final User loggedInUser = User.fromJson(responseData['user']);
            await saveUserData(loggedInUser);
          } else {
            print(
                'AuthService: WARNING - Token diterima, tapi data user tidak ditemukan di respons verify-otp.');
          }
        } else {
          throw AuthException(
              'Verifikasi OTP berhasil, namun token akses tidak ditemukan. Mohon coba lagi.');
        }

        return responseData;
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
          print(
              'AuthService: Error decode JSON respons verifikasi OTP: $jsonError');
        }

        print(
            'AuthService: Verifikasi OTP gagal (Status: ${response.statusCode}): $errorMessage');
        throw AuthException(
          errorMessage,
          userId: userIdFromError,
          phoneNumber: phoneNumberFromError,
        );
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: Error koneksi jaringan saat verifikasi OTP: ${e.message}');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet dan server aktif. (${e.message})');
    } catch (e) {
      throw AuthException(
          'Terjadi masalah tak terduga saat verifikasi OTP: $e');
    }
  }

  /// Melakukan login pengguna secara manual menggunakan identifier dan password.
  Future<Map<String, dynamic>> login(
    String identifier,
    String password,
  ) async {
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
          await saveAuthToken(accessToken);
          if (responseData.containsKey('user')) {
            final User loggedInUser = User.fromJson(responseData['user']);
            await saveUserData(loggedInUser);
          }
        } else {
          throw AuthException(
              'Login berhasil, namun token akses tidak ditemukan. Mohon coba lagi.');
        }

        return responseData;
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
    } catch (e) {
      throw AuthException('An unexpected error occurred during login: $e');
    }
  }

  /// Requests an OTP for password reset.
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
              errorData['message'] ?? 'An error occurred from the server.';
        } catch (jsonError) {
          errorMessage =
              'Invalid or empty server response (Status: ${response.statusCode}).';
        }
        print(
            'AuthService: DEBUG - Throwing AuthException with message: "$errorMessage"');
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: DEBUG - Caught http.ClientException. Original message: "${e.message}"');
      throw AuthException(
        'Gagal terhubung ke server. Pastikan Anda terhubung ke internet. (${e.message})',
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      throw AuthException(
          'An unexpected error occurred during password reset request: $e');
    }
  }

  /// Verifies the OTP for password reset.
  Future<Map<String, dynamic>> verifyResetPasswordOtp(
      {required String otpCode, required String phoneNumber}) async {
    final url = Uri.parse('$_baseUrl/users/forgot-password/verify-otp');
    try {
      print(
          'AuthService: Sending password reset OTP verification request to: $url');
      print('AuthService: Request body: ${jsonEncode(<String, dynamic>{
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
          'AuthService: Password reset OTP verification response status: ${response.statusCode}');
      print('AuthService: Body respons verifikasi OTP reset: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'AuthService: Password reset OTP verification successful: ${responseData['message']}');
        // Perbaikan: Kembalikan Map<String, dynamic> untuk mendapatkan user_id/phone
        return responseData;
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Unknown error from server.';
        } catch (jsonError) {
          errorMessage =
              'Invalid or empty server response (Status: ${response.statusCode}).';
          print(
              'AuthService: Error decoding password reset OTP verification JSON response: $jsonError');
        }
        print(
            'AuthService: Password reset OTP verification failed: $errorMessage');
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: Network connection error during password reset OTP verification: ${e.message}');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet. (${e.message})',
          phoneNumber: phoneNumber);
    } catch (e) {
      throw AuthException(
          'An unexpected error occurred during password reset OTP verification: $e');
    }
  }

  /// Resets the user's password.
  Future<void> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/users/forgot-password/reset');
    try {
      print('AuthService: Sending password reset request to: $url');
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
          'AuthService: Password reset response status: ${response.statusCode}');
      print('AuthService: Body respons reset password: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'AuthService: Password reset successful: ${responseData['message']}');
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'An error occurred while setting the new password.';
        } catch (jsonError) {
          errorMessage =
              'Invalid server response during password reset (Status: ${response.statusCode}).';
          print(
              'AuthService: Error decoding password reset JSON response: $jsonError');
        }
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      print(
          'AuthService: Network connection error during password reset: ${e.message}');
      throw AuthException(
          'Gagal terhubung ke server. Pastikan Anda terhubung ke internet. (${e.message})',
          phoneNumber: phoneNumber);
    } catch (e) {
      throw AuthException(
          'An unexpected error occurred during password reset: $e');
    }
  }
}
