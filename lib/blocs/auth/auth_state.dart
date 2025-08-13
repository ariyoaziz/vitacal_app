import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/login_respon_model.dart';
import '../../models/otp_model.dart';
import '../../models/user_model.dart'; // Pastikan User model diimpor

// Abstract base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  // Menggunakan List<Object?> untuk konsistensi, memungkinkan properti nullable
  List<Object?> get props => [];
}

// Initial state before any authentication action
class AuthInitial extends AuthState {}

// Loading state for any ongoing authentication process
class AuthLoading extends AuthState {}

// State for successful registration, before OTP verification
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
        phoneNumber,
      ];
}

// State for successful OTP verification (without auto-login yet)
class AuthOtpVerified extends AuthState {
  final User user;

  const AuthOtpVerified(this.user);

  @override
  List<Object?> get props => [user];
}

// Error state for authentication failures
class AuthError extends AuthState {
  final String message;
  final int? userId; // Properti nullable
  final String? phoneNumber; // Properti nullable

  const AuthError(this.message, {this.userId, this.phoneNumber});

  @override
  // Sertakan properti nullable di props list. Equatable akan menangani null dengan benar.
  List<Object?> get props => [message, userId, phoneNumber];
}

// State for successful OTP verification AND automatic login
class AuthVerifiedAndLoggedIn extends AuthState {
  final User user;
  const AuthVerifiedAndLoggedIn(this.user);

  @override
  // Pastikan konsisten dengan yang lain, meskipun 'user' seharusnya tidak null di sini.
  List<Object?> get props => [user];
}

// State for successful manual login, membawa seluruh respons login
class AuthLoginSuccess extends AuthState {
  final LoginResponseModel loginResponse;
  const AuthLoginSuccess(this.loginResponse);

  @override
  // Pastikan konsisten dengan yang lain.
  List<Object?> get props => [loginResponse];
}

// State for when the user is authenticated (logged in)
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// State for when the user is unauthenticated (logged out)
class AuthUnauthenticated extends AuthState {}

// States for Password Reset Flow

// State when OTP for password reset has been sent
class AuthPasswordResetOtpSent extends AuthState {
  final String phoneNumber; // Simpan nomor telepon untuk diteruskan
  const AuthPasswordResetOtpSent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

// State when password reset OTP has been successfully verified
// --- PERBAIKAN DI SINI ---
// State when password reset OTP has been successfully verified
class AuthPasswordResetOtpVerified extends AuthState {
  final String phoneNumber;
  final String otpCode;
  final int? userId; // <<< Tambahkan ini untuk menerima userId

  const AuthPasswordResetOtpVerified(
      {required this.phoneNumber,
      required this.otpCode,
      this.userId}); // <<< Tambahkan di constructor

  @override
  List<Object?> get props =>
      [phoneNumber, otpCode, userId]; // <<< Tambahkan di props
}

// State when password has been successfully reset
class AuthPasswordResetSuccess extends AuthState {
  final String message;
  const AuthPasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
