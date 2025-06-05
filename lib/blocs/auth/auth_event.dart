// lib/blocs/auth/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RegisterUserEvent extends AuthEvent {
  final String username;
  final String email;
  final String phone;
  final String password;

  const RegisterUserEvent({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object> get props => [username, email, phone, password];
}

class VerifyOtpEvent extends AuthEvent {
  final int userId; // <--- PASTIKAN INI INT
  final String otpCode;
  final String phoneNumber;

  const VerifyOtpEvent({
    required this.userId,
    required this.otpCode,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [userId, otpCode, phoneNumber];
}

class LoginUserEvent extends AuthEvent {
  final String identifier;
  final String password;

  const LoginUserEvent({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object> get props => [identifier, password];
}

class LogoutUserEvent extends AuthEvent {}
