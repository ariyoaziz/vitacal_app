// lib/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/models/user_model.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    print(
        'AuthBloc: Konstruktor dijalankan. Mulai mendaftarkan event handlers...');

    on<RegisterUserEvent>((event, emit) async {
      print('AuthBloc: Menerima RegisterUserEvent');
      emit(AuthLoading());
      try {
        final otpResponse = await authService.registerUser(
          username: event.username,
          email: event.email,
          phone: event.phone,
          password: event.password,
        );
        print(
            'AuthBloc (Register): otpResponse.user (setelah parsing): ${otpResponse.user}');
        print(
            'AuthBloc (Register): otpResponse.user.userId (setelah parsing): ${otpResponse.user.userId.runtimeType} - "${otpResponse.user.userId}"');

        emit(AuthRegisterSuccess(otpResponse,
            userId: otpResponse.user.userId, // <--- User.userId sudah int
            phoneNumber: event.phone));
      } on AuthException catch (e) {
        print('AuthBloc: BERHASIL MENANGKAP AuthException: "${e.message}"');
        emit(AuthError(e.message));
      } catch (e) {
        print('AuthBloc: ERROR TAK TERDUGA (Register - Catch Umum)!');
        print('Tipe exception yang sebenarnya: ${e.runtimeType}');
        print('Pesan exception: $e');
        emit(AuthError('Terjadi masalah tak terduga. Mohon coba lagi nanti.'));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      print('AuthBloc: Menerima VerifyOtpEvent');
      emit(AuthLoading());
      try {
        final isVerified = await authService.verifyOtp(
          event.otpCode,
          event.phoneNumber,
        );

        if (isVerified) {
          emit(AuthOtpVerified(User(
              userId: event
                  .userId, // <--- event.userId sudah int (dari VerifyOtpEvent)
              username: 'Pengguna',
              email: '${event.phoneNumber}@example.com',
              phone: event.phoneNumber,
              verified: true,
              createdAt: '',
              updatedAt: '')));
        } else {
          emit(const AuthError('Verifikasi OTP gagal. Kode tidak sesuai.'));
        }
      } on AuthException catch (e) {
        print('AuthBloc: BERHASIL MENANGKAP AuthException: "${e.message}"');
        emit(AuthError(e.message));
      } catch (e) {
        print('AuthBloc: ERROR TAK TERDUGA (Verify OTP - Catch Umum)!');
        print('Tipe exception yang sebenarnya: ${e.runtimeType}');
        print('Pesan exception: $e');
        emit(AuthError(
            'Terjadi masalah tak terduga saat verifikasi OTP. Mohon coba lagi nanti.'));
      }
    });

    print('AuthBloc: Mendaftarkan handler untuk LoginUserEvent...');
    on<LoginUserEvent>((event, emit) async {
      print('AuthBloc: Menerima LoginUserEvent');
      emit(AuthLoading());
      try {
        final loginResponse = await authService.loginUser(
          identifier: event.identifier,
          password: event.password,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', loginResponse.accessToken);
        await prefs.setString('refresh_token', loginResponse.refreshToken);
        await prefs.setInt(
            'user_id', loginResponse.user.userId); // userId sudah int

        print('AuthBloc: Login berhasil. Token disimpan.');
        emit(AuthLoginSuccess(loginResponse));
        emit(AuthAuthenticated(loginResponse.user));
      } on AuthException catch (e) {
        print(
            'AuthBloc: BERHASIL MENANGKAP AuthException (Login): "${e.message}"');
        emit(AuthError(e.message));
      } catch (e) {
        print('AuthBloc: ERROR TAK TERDUGA (Login - Catch Umum)!');
        print('Tipe exception yang sebenarnya: ${e.runtimeType}');
        print('Pesan exception: $e');
        emit(AuthError(
            'Terjadi masalah tak terduga saat login. Mohon coba lagi nanti.'));
      }
    });
    print('AuthBloc: Handler LoginUserEvent selesai didaftarkan.');

    on<LogoutUserEvent>((event, emit) async {
      print('AuthBloc: Menerima LogoutUserEvent');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');

      print('AuthBloc: Logout berhasil. Token dihapus.');
      emit(AuthUnauthenticated());
    });
  }
}
