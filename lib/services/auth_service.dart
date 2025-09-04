// lib/services/auth_service.dart

// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitacal_app/models/otp_model.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/user_model.dart';
import 'package:vitacal_app/services/constants.dart';

class AuthService {
  final String _baseUrl = AppConstants.baseUrl;

  // ==== Keys (satu-satunya sumber kebenaran) ====
  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';
  static const _kUserIdKey = 'user_id';
  // legacy key yang dulu dipakai:
  static const _kLegacyJwtKey = 'jwt_token';

  Future<SharedPreferences> _getPrefs() => SharedPreferences.getInstance();

  // ===== Session helpers =====
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    int? userId,
    User? user, // opsional: sekalian simpan data user
  }) async {
    final prefs = await _getPrefs();
    await prefs.setString(_kAccessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_kRefreshTokenKey, refreshToken);
    }
    if (userId != null) {
      await prefs.setInt(_kUserIdKey, userId);
    }
    if (user != null) {
      await saveUserData(user);
    }
    // bersihkan key lama kalau masih ada
    await prefs.remove(_kLegacyJwtKey);
    print('DEBUG AUTH: saveSession() done');
  }

  /// Backward-compat: kalau masih ada sisa `jwt_token`, migrasikan ke `access_token`.
  Future<String?> getAuthToken() async {
    final prefs = await _getPrefs();
    String? token = prefs.getString(_kAccessTokenKey);
    if (token == null) {
      final legacy = prefs.getString(_kLegacyJwtKey);
      if (legacy != null) {
        await prefs.setString(_kAccessTokenKey, legacy);
        await prefs.remove(_kLegacyJwtKey);
        token = legacy;
        print('DEBUG AUTH: migrated legacy jwt_token -> access_token');
      }
    }
    return token;
  }

  /// Hapus seluruh jejak sesi (dipanggil saat Logout).
  Future<void> clearSession() async {
    final prefs = await _getPrefs();
    await prefs.remove(_kAccessTokenKey);
    await prefs.remove(_kRefreshTokenKey);
    await prefs.remove(_kUserIdKey);
    // data user yg kamu simpan:
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('verified');
    // juga bersihkan legacy key
    await prefs.remove(_kLegacyJwtKey);
    print('DEBUG AUTH: clearSession() done (tokens & user data removed)');
  }

  // ====== Backward-compat wrappers (boleh tetap dipakai di tempat lama) ======
  Future<void> saveAuthToken(String token) => saveSession(accessToken: token);

  Future<void> deleteAuthToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(_kAccessTokenKey);
    await prefs.remove(_kLegacyJwtKey);
    print('DEBUG AUTH: deleteAuthToken() removed access_token & jwt_token');
  }

  // ====== User data ======
  Future<void> saveUserData(User user) async {
    final prefs = await _getPrefs();
    await prefs.setInt('user_id', user.userId);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('phone', user.phone);
    await prefs.setBool('verified', user.verified ?? false);
    print(
        'DEBUG AUTH: User data (userId: ${user.userId}) saved to SharedPreferences.');
  }

  Future<int?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getInt('user_id');
  }

  Future<void> deleteUserData() async {
    final prefs = await _getPrefs();
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('verified');
    print('DEBUG AUTH: User data removed from SharedPreferences.');
  }

  // ====== Token verification ======
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
            'AuthService: Token invalid. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print("AuthService Error saat verifikasi token: $e");
      return false;
    }
  }

  // ====== Register / Verify OTP / Login / Reset Password ======
  Future<OtpResponse> registerUser({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/users');
    try {
      print('AuthService: Mengirim permintaan registrasi ke: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
        return OtpResponse.fromJson(responseData);
      } else {
        String errorMessage;
        int? userIdFromError;
        String? phoneNumberFromError;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? 'Terjadi kesalahan dari server.';
          userIdFromError = errorData['user_id'] as int?;
          phoneNumberFromError = errorData['phone'] as String?;
        } catch (_) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage,
            userId: userIdFromError, phoneNumber: phoneNumberFromError);
      }
    } on http.ClientException catch (e) {
      throw AuthException('Gagal terhubung ke server. (${e.message})');
    } catch (e) {
      throw AuthException('Terjadi masalah tak terduga saat registrasi: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String otpCode, String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/users/verify-otp');
    try {
      print('AuthService: Mengirim verifikasi OTP ke: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'otp': otpCode,
          'phone': phoneNumber,
        }),
      );

      print('AuthService: Status verifikasi OTP: ${response.statusCode}');
      print('AuthService: Body verifikasi OTP: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String? accessToken = responseData['access_token'];
        if (accessToken != null) {
          User? loggedInUser;
          int? uid;
          if (responseData.containsKey('user')) {
            loggedInUser = User.fromJson(responseData['user']);
            uid = loggedInUser.userId;
          }
          await saveSession(
              accessToken: accessToken, userId: uid, user: loggedInUser);
        } else {
          throw AuthException(
              'Verifikasi OTP berhasil, namun token akses tidak ditemukan.');
        }
        return responseData;
      } else {
        String errorMessage;
        int? userIdFromError;
        String? phoneNumberFromError;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? 'Terjadi kesalahan dari server.';
          userIdFromError = errorData['user_id'] as int?;
          phoneNumberFromError = errorData['phone'] as String?;
        } catch (_) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage,
            userId: userIdFromError, phoneNumber: phoneNumberFromError);
      }
    } on http.ClientException catch (e) {
      throw AuthException('Gagal terhubung ke server. (${e.message})');
    } catch (e) {
      throw AuthException(
          'Terjadi masalah tak terduga saat verifikasi OTP: $e');
    }
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse('$_baseUrl/users/login');
    try {
      print('AuthService: Mengirim login ke: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'identifier': identifier,
          'password': password,
        }),
      );

      print('AuthService: Status login: ${response.statusCode}');
      print('AuthService: Body login: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String? accessToken = responseData['access_token'];
        if (accessToken != null) {
          User? loggedInUser;
          int? uid;
          if (responseData.containsKey('user')) {
            loggedInUser = User.fromJson(responseData['user']);
            uid = loggedInUser.userId;
          }
          await saveSession(
              accessToken: accessToken, userId: uid, user: loggedInUser);
        } else {
          throw AuthException(
              'Login berhasil, namun token akses tidak ditemukan.');
        }
        return responseData;
      } else {
        String errorMessage;
        int? userIdFromError;
        String? phoneNumberFromError;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? 'Terjadi kesalahan dari server.';
          userIdFromError = errorData['user_id'] as int?;
          phoneNumberFromError = errorData['phone'] as String?;
        } catch (_) {
          errorMessage =
              'Respons server tidak valid atau kosong (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage,
            userId: userIdFromError, phoneNumber: phoneNumberFromError);
      }
    } on http.ClientException catch (e) {
      throw AuthException('Gagal terhubung ke server. (${e.message})');
    } catch (e) {
      throw AuthException('An unexpected error occurred during login: $e');
    }
  }

  Future<bool> requestPasswordReset({required String phoneNumber}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/forgot-password/request'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{'phone': phoneNumber}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('AuthService: Reset request OK: ${responseData['message']}');
        return true;
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? 'An error occurred from the server.';
        } catch (_) {
          errorMessage =
              'Invalid or empty server response (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      throw AuthException('Gagal terhubung ke server. (${e.message})',
          phoneNumber: phoneNumber);
    } catch (e) {
      throw AuthException(
          'An unexpected error occurred during password reset request: $e');
    }
  }

  Future<Map<String, dynamic>> verifyResetPasswordOtp({
    required String otpCode,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/users/forgot-password/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body:
            jsonEncode(<String, dynamic>{'otp': otpCode, 'phone': phoneNumber}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Unknown error from server.';
        } catch (_) {
          errorMessage =
              'Invalid or empty server response (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      throw AuthException('Gagal terhubung ke server. (${e.message})',
          phoneNumber: phoneNumber);
    } catch (e) {
      throw AuthException(
          'An unexpected error occurred during password reset OTP verification: $e');
    }
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/users/forgot-password/reset');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'phone': phoneNumber,
          'otp': otpCode,
          'new_password': newPassword,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('AuthService: Password reset OK: ${responseData['message']}');
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              'An error occurred while setting the new password.';
        } catch (_) {
          errorMessage =
              'Invalid server response during password reset (Status: ${response.statusCode}).';
        }
        throw AuthException(errorMessage, phoneNumber: phoneNumber);
      }
    } on http.ClientException catch (e) {
      throw AuthException('Gagal terhubung ke server. (${e.message})',
          phoneNumber: phoneNumber);
    } catch (e) {
      throw AuthException(
          'An unexpected error occurred during password reset: $e');
    }
  }
}
