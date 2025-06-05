// lib/blocs/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/login_respon_model.dart';
import '../../models/otp_model.dart';
import '../../models/user_model.dart'; // Pastikan User model diimpor

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegisterSuccess extends AuthState {
  final OtpResponse otpResponse;
  final int userId; // <--- PASTIKAN INI INT
  final String phoneNumber;

  const AuthRegisterSuccess(this.otpResponse,
      {required this.userId, required this.phoneNumber});

  @override
  List<Object> get props => [otpResponse, userId, phoneNumber];
}

class AuthOtpVerified extends AuthState {
  final User user;

  const AuthOtpVerified(this.user);

  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthLoginSuccess extends AuthState {
  final LoginResponseModel loginResponse;

  const AuthLoginSuccess(this.loginResponse);

  @override
  List<Object> get props => [loginResponse];
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}
