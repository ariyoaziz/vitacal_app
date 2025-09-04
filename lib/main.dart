// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';

// Screens
import 'package:vitacal_app/screen/onboarding/splash_screen.dart';

// Services
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/services/kalori_service.dart';
import 'package:vitacal_app/services/profile_service.dart';
import 'package:vitacal_app/services/riwayat_user_service.dart';

// Blocs
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';

import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_state.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';

import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/kalori/kalori_event.dart';

import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';

import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_bloc.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_event.dart';

List<CameraDescription> cameras = [];
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException {
    // no-op
  } catch (_) {
    // no-op
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (_) => AuthService()),
        RepositoryProvider<UserDetailService>(
          create: (ctx) =>
              UserDetailService(authService: ctx.read<AuthService>()),
        ),
        // NOTE: Jika CalorieService kamu butuh AuthService, ubah ke:
        // create: (ctx) => CalorieService(authService: ctx.read<AuthService>()),
        RepositoryProvider<CalorieService>(create: (_) => CalorieService()),
        RepositoryProvider<ProfileService>(
          create: (ctx) => ProfileService(
            userDetailService: ctx.read<UserDetailService>(),
            authService: ctx.read<AuthService>(),
          ),
        ),
        RepositoryProvider<RiwayatUserService>(
          create: (ctx) => RiwayatUserService(
            authService: ctx.read<AuthService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (ctx) => AuthBloc(authService: ctx.read<AuthService>()),
          ),
          BlocProvider<UserDetailBloc>(
            create: (ctx) => UserDetailBloc(
              userDetailService: ctx.read<UserDetailService>(),
              authService: ctx.read<AuthService>(),
            ),
          ),
          BlocProvider<RiwayatUserBloc>(
            create: (ctx) => RiwayatUserBloc(
              service: ctx.read<RiwayatUserService>(),
            ),
          ),
          BlocProvider<KaloriBloc>(
            create: (ctx) => KaloriBloc(
              calorieService: ctx.read<CalorieService>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (ctx) => ProfileBloc(
              profileService: ctx.read<ProfileService>(),
              authService: ctx.read<AuthService>(),
            ),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            // ==== AUTH LISTENERS ====
            // Saat berhasil login / token tervalidasi → muat semua data utama
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (prev, curr) => curr is AuthAuthenticated,
              listener: (ctx, state) {
                ctx.read<ProfileBloc>().add(const LoadProfileData());
                ctx.read<KaloriBloc>().add(const FetchKaloriData());
                ctx.read<UserDetailBloc>().add(LoadUserDetail());
                ctx.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
              },
            ),
            // Saat logout / token invalid → bersih-bersih & kembali ke Splash
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (prev, curr) => curr is AuthUnauthenticated,
              listener: (ctx, state) {
                ctx.read<RiwayatUserBloc>().add(const ClearRiwayat());
                appNavigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              },
            ),

            // ==== PROFILE DETAIL LISTENERS ====
            // Kalau user detail berhasil di-update → segarkan profil, kalori, & riwayat
            BlocListener<UserDetailBloc, UserDetailState>(
              listenWhen: (prev, curr) => curr is UserDetailUpdateSuccess,
              listener: (ctx, state) {
                ctx.read<ProfileBloc>().add(const LoadProfileData());
                ctx.read<KaloriBloc>().add(const FetchKaloriData());
                ctx.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
              },
            ),

            // Opsional: bila ada proses update di Profile screen yang emit ProfileSuccess,
            // segarkan data juga (tapi hindari loop dengan tidak bereaksi pada ProfileLoaded).
            BlocListener<ProfileBloc, ProfileState>(
              listenWhen: (prev, curr) =>
                  curr is ProfileSuccess || curr is ProfileNoChange,
              listener: (ctx, state) {
                ctx.read<ProfileBloc>().add(const LoadProfileData());
                ctx.read<KaloriBloc>().add(const FetchKaloriData());
                ctx.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
              },
            ),
          ],
          child: MaterialApp(
            title: 'VitaCal App',
            debugShowCheckedModeBanner: false,
            navigatorKey: appNavigatorKey,
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
