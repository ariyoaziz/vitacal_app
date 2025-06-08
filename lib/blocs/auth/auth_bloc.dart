// lib/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/models/user_model.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart'; // Pastikan ini diimpor
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
            userId: otpResponse.user.userId, phoneNumber: event.phone));
      } on AuthException catch (e) {
        print('AuthBloc: BERHASIL MENANGKAP AuthException: "${e.message}"');
        emit(AuthError(e.message,
            userId: e.userId,
            phoneNumber: e.phoneNumber)); // Meneruskan data dari AuthException
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
              userId: event.userId,
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
        emit(AuthError(e.message,
            userId: e.userId,
            phoneNumber: e.phoneNumber)); // Meneruskan data dari AuthException
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
        // --- PENTING: Meneruskan userId dan phoneNumber dari AuthException ke AuthError state ---
        emit(
            AuthError(e.message, userId: e.userId, phoneNumber: e.phoneNumber));
        // -------------------------------------------------------------------------------------
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
    on<RequestPasswordResetEvent>((event, emit) async {
      print('AuthBloc: Menerima RequestPasswordResetEvent');
      emit(AuthLoading());
      try {
        // Jika requestPasswordReset berhasil, maka OTP dikirim dan navigasi
        await authService.requestPasswordReset(phoneNumber: event.phoneNumber);
        emit(AuthPasswordResetOtpSent(phoneNumber: event.phoneNumber));
      } on AuthException catch (e) {
        // --- Cukup tangkap AuthException dan emit pesan yang sudah bersih ---
        print(
            'AuthBloc: Menangkap AuthException. Pesan yang akan ditampilkan: "${e.message}"');
        emit(AuthError(e.message, phoneNumber: e.phoneNumber));
      } catch (e, stackTrace) {
        // --- Ini hanya untuk error yang BUKAN AuthException ---
        print(
            'AuthBloc: ERROR TAK TERDUGA (Request Password Reset - Catch Umum)!');
        print('    Tipe exception yang sebenarnya: ${e.runtimeType}');
        print('    Pesan exception: $e');
        print('    Stack Trace: $stackTrace');
        emit(AuthError(
            'Terjadi masalah tak terduga saat meminta reset password.'));
      }
    });

    // lib/blocs/auth/auth_bloc.dart
    on<VerifyResetOtpEvent>((event, emit) async {
      print('AuthBloc: Menerima VerifyResetOtpEvent');
      emit(AuthLoading());
      try {
        final isVerified = await authService.verifyResetPasswordOtp(
          // <--- PANGGIL METODE BARU
          otpCode: event.otpCode,
          phoneNumber: event.phoneNumber,
        );

        if (isVerified) {
          emit(AuthPasswordResetOtpVerified(
              phoneNumber: event.phoneNumber, otpCode: event.otpCode));
        } else {
          emit(const AuthError(
              'Verifikasi OTP reset gagal. Kode tidak sesuai.'));
        }
      } on AuthException catch (e) {
        print(
            'AuthBloc: BERHASIL MENANGKAP AuthException (Verify Reset OTP)!: "${e.message}"');
        emit(AuthError(e.message, phoneNumber: e.phoneNumber));
      } catch (e) {
        print('AuthBloc: ERROR TAK TERDUGA (Verify Reset OTP - Catch Umum)!');
        print('Tipe exception yang sebenarnya: ${e.runtimeType}');
        print('Pesan exception: $e');
        emit(AuthError(
            'Terjadi masalah tak terduga saat verifikasi OTP reset.'));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.resetPassword(
          phoneNumber: event.phoneNumber,
          otpCode: event.otpCode,
          newPassword: event.newPassword,
        );
        emit(const AuthPasswordResetSuccess('Password berhasil diubah!'));
      } on AuthException catch (e) {
        emit(AuthError(e.message, phoneNumber: e.phoneNumber));
      } catch (e) {
        emit(AuthError('Terjadi masalah tak terduga saat reset password.'));
      }
    });
  }
}
