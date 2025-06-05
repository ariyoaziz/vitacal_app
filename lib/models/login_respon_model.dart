// lib/models/login_response_model.dart

import 'package:vitacal_app/models/user_model.dart'; // Impor User model

class LoginResponseModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final User user; // Data user yang login

  LoginResponseModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
