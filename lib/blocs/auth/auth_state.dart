// lib/blocs/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/login_respon_model.dart';
import '../../models/otp_model.dart';
import '../../models/user_model.dart'; // Pastikan User model diimpor

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => []; // <--- UBAH DI SINI: tambahkan '?'
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegisterSuccess extends AuthState {
  final OtpResponse otpResponse;
  final int userId;
  final String phoneNumber;

  const AuthRegisterSuccess(this.otpResponse,
      {required this.userId, required this.phoneNumber});

  @override
  List<Object?> get props => [
        otpResponse,
        userId,
        phoneNumber
      ]; // <--- UBAH DI SINI juga (Opsional, tapi konsisten)
}

class AuthOtpVerified extends AuthState {
  final User user;

  const AuthOtpVerified(this.user);

  @override
  List<Object?> get props =>
      [user]; // <--- UBAH DI SINI juga (Opsional, tapi konsisten)
}

class AuthError extends AuthState {
  final String message;
  final int? userId; // Properti nullable
  final String? phoneNumber; // Properti nullable

  const AuthError(this.message, {this.userId, this.phoneNumber});

  @override
  List<Object?> get props =>
      [message, userId, phoneNumber]; // <--- UBAH DI SINI
}

class AuthLoginSuccess extends AuthState {
  final LoginResponseModel loginResponse;

  const AuthLoginSuccess(this.loginResponse);

  @override
  List<Object?> get props =>
      [loginResponse]; // <--- UBAH DI SINI juga (Opsional, tapi konsisten)
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props =>
      [user]; // <--- UBAH DI SINI juga (Opsional, tapi konsisten)
}

class AuthUnauthenticated extends AuthState {}
