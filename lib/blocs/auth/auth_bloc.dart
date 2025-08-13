// lib/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/models/user_model.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart'; // Pastikan ini diimpor
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacal_app/models/login_respon_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  // ignore: unused_field
  String? _tempPhoneNumber;
  // ignore: unused_field
  String? _tempPassword;

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

// In lib/blocs/auth/auth_bloc.dart

    on<VerifyOtpEvent>((event, emit) async {
      print('AuthBloc: Menerima VerifyOtpEvent');
      emit(AuthLoading()); // Emit loading state
      try {
        // Call authService.verifyOtp. This method is now responsible
        // for making the API call AND saving the token/user data if successful.
        final verifyOtpResponse = await authService.verifyOtp(
          event.otpCode,
          event.phoneNumber,
        );

        // --- FIX: Check for both possible success messages from backend ---
        final String? message = verifyOtpResponse['message'];
        if (message == 'Verifikasi berhasil' ||
            message == 'Verifikasi berhasil. Anda sudah terverifikasi.') {
          // Token and user data should already be saved by authService.verifyOtp()

          // Extract user data from the response to emit in the state.
          // We assume 'user' key exists in the success response.
          if (verifyOtpResponse.containsKey('user')) {
            final loggedInUser = User.fromJson(verifyOtpResponse['user']);
            emit(AuthVerifiedAndLoggedIn(
                loggedInUser)); // Emit success state with user data
            print(
                'AuthBloc: Verifikasi OTP dan auto-login berhasil. Memancarkan AuthVerifiedAndLoggedIn.');
          } else {
            // Handle case where message is 'Verifikasi berhasil' but 'user' data is missing.
            print(
                'AuthBloc: WARNING - OTP verified, but user data missing in response. Emitting error.');
            emit(AuthError(
                'Verifikasi berhasil, namun data profil tidak lengkap. Silakan login kembali.'));
          }
        } else {
          // This branch indicates a 200 OK, but with a message not signifying success.
          // This scenario is rare if the backend follows standard HTTP practices.
          // It's safer to assume a non-200 status code for actual failures.
          emit(AuthError(message ??
              'Verifikasi OTP gagal. Kode tidak sesuai atau respons tidak valid.'));
        }
      } on AuthException catch (e) {
        // Catch specific AuthException thrown by AuthService for API-related errors
        print('AuthBloc: CAUGHT AuthException: "${e.message}"');
        emit(
            AuthError(e.message, userId: e.userId, phoneNumber: e.phoneNumber));
      } catch (e) {
        // Catch any other unexpected errors (e.g., network issues not caught by http.ClientException in AuthService)
        print('AuthBloc: UNEXPECTED ERROR (Verify OTP - General Catch)!');
        print('Actual exception type: ${e.runtimeType}');
        print('Exception message: $e');
        emit(AuthError(
            'Terjadi masalah tak terduga saat verifikasi OTP. Mohon coba lagi nanti.'));
      }
    });
    on<LogoutUserEvent>((event, emit) async {
      print('AuthBloc: Menerima LogoutUserEvent');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');

      print('AuthBloc: Logout berhasil. Token dihapus.');
      emit(AuthUnauthenticated());
    });
    // --- Handler for LoginUserEvent (manual login) ---
    on<LoginUserEvent>((event, emit) async {
      print('AuthBloc: Menerima LoginUserEvent');
      emit(AuthLoading());
      try {
        final Map<String, dynamic> loginResponseData = await authService.login(
          event.identifier,
          event.password,
        );

        final LoginResponseModel loginResponse =
            LoginResponseModel.fromJson(loginResponseData);
        final User user = loginResponse.user;

        emit(AuthLoginSuccess(loginResponse));
        emit(AuthAuthenticated(user));
        print('AuthBloc: Login manual berhasil untuk User: ${user.username}.');
      } on AuthException catch (e) {
        print('AuthBloc: CAUGHT AuthException (Login): "${e.message}"');
        emit(
            AuthError(e.message, userId: e.userId, phoneNumber: e.phoneNumber));
      } catch (e) {
        print('AuthBloc: UNEXPECTED ERROR (Login - General Catch)!');
        print('Tipe exception yang sebenarnya: ${e.runtimeType}');
        print('Pesan exception: $e');
        emit(AuthError(
            'Terjadi masalah tak terduga saat login. Mohon coba lagi nanti.'));
      }
    });
    on<RequestPasswordResetEvent>((event, emit) async {
      // *** ADD THIS PRINT - IF YOU SEE IT, THE HANDLER IS REGISTERED! ***
      print(
          'DEBUG AUTHBLOC: >>> RequestPasswordResetEvent handler IS EXECUTED <<<');

      emit(AuthLoading());
      try {
        await authService.requestPasswordReset(phoneNumber: event.phoneNumber);
        emit(AuthPasswordResetOtpSent(phoneNumber: event.phoneNumber));
        print(
            'DEBUG AUTHBLOC: RequestPasswordResetEvent: OTP Sent successfully.');
      } on AuthException catch (e) {
        print(
            'DEBUG AUTHBLOC: RequestPasswordResetEvent: AuthException: ${e.message}');
        emit(AuthError(e.message, phoneNumber: e.phoneNumber));
      } catch (e, stackTrace) {
        print(
            'DEBUG AUTHBLOC: RequestPasswordResetEvent: Unexpected error: $e\n$stackTrace');
        emit(AuthError(
            'Terjadi masalah tak terduga saat meminta reset password.'));
      }
    });

    print('DEBUG AUTHBLOC: All event handlers initialized.');

    on<VerifyResetOtpEvent>((event, emit) async {
      print('AuthBloc: Menerima VerifyResetOtpEvent');
      emit(AuthLoading()); // Emit loading state
      try {
        // authService.verifyResetPasswordOtp sekarang mengembalikan Map<String, dynamic>
        final Map<String, dynamic> responseData =
            await authService.verifyResetPasswordOtp(
          otpCode: event.otpCode,
          phoneNumber: event.phoneNumber,
        );

        // Periksa pesan sukses dari respons backend
        if (responseData.containsKey('message') &&
            responseData['message'] == 'Verifikasi OTP reset berhasil.') {
          // Ambil user_id dan phone dari responseData untuk diteruskan ke state
          final int? userIdFromResponse = responseData['user_id'] as int?;
          final String? phoneFromResponse = responseData['phone'] as String?;

          emit(AuthPasswordResetOtpVerified(
              phoneNumber: phoneFromResponse ??
                  event
                      .phoneNumber, // Gunakan dari response atau fallback ke event
              otpCode: event.otpCode, // OTP Code yang diverifikasi
              userId: userIdFromResponse // Teruskan userId juga
              ));
        } else {
          // Jika status 200 OK tapi pesan bukan sukses yang diharapkan
          emit(AuthError(
              responseData['message'] ??
                  'Verifikasi OTP reset gagal. Kode tidak sesuai atau respons tidak valid.',
              phoneNumber: event.phoneNumber));
        }
      } on AuthException catch (e) {
        // Menangkap AuthException yang dilempar dari AuthService
        print(
            'AuthBloc: CAUGHT AuthException (Verify Reset OTP): "${e.message}"');
        emit(AuthError(e.message, phoneNumber: e.phoneNumber));
      } catch (e) {
        // Menangkap error lain yang tidak terduga
        print(
            'AuthBloc: UNEXPECTED ERROR (Verify Reset OTP): ${e.runtimeType} - $e');
        emit(AuthError('Terjadi masalah tak terduga saat verifikasi OTP reset.',
            phoneNumber: event.phoneNumber));
      }
    });

    // --- Handler untuk ResetPasswordEvent ---
    on<ResetPasswordEvent>((event, emit) async {
      emit(AuthLoading()); // Emit loading state
      try {
        await authService.resetPassword(
          phoneNumber: event.phoneNumber,
          otpCode: event.otpCode,
          newPassword: event.newPassword,
        );
        emit(const AuthPasswordResetSuccess('Password berhasil diubah!'));
      } on AuthException catch (e) {
        // Menangkap AuthException yang dilempar dari AuthService
        emit(AuthError(e.message, phoneNumber: e.phoneNumber));
      } catch (e) {
        // Menangkap error lain yang tidak terduga
        emit(AuthError('Terjadi masalah tak terduga saat reset password.'));
      }
    });
  }
}
