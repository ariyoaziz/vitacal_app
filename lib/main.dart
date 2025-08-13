// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:vitacal_app/screen/onboarding/splash_screen.dart';

// Services
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/services/kalori_service.dart';
import 'package:vitacal_app/services/profile_service.dart';
import 'package:vitacal_app/services/riwayat_user_service.dart';

// Blocs
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_state.dart';
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_bloc.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_event.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
    // print('DEBUG MAIN: Kamera yang tersedia: ${cameras.length}');
  } on CameraException {
    // print('ERROR MAIN: ${e.code} - ${e.description}');
  } catch (e) {
    // print('ERROR MAIN: $e');
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
            )
              // Muat detail user sekali di awal
              ..add(LoadUserDetail()),
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
          BlocProvider<RiwayatUserBloc>(
            create: (ctx) => RiwayatUserBloc(
              service: ctx.read<RiwayatUserService>(),
            )
              // Muat riwayat (kalori & berat) sekali di awal
              ..add(const LoadRiwayat(days: 7)),
          ),
        ],
        // Dengarkan perubahan UserDetail; kalau sukses/loaded => reload riwayat
        child: MultiBlocListener(
          listeners: [
            BlocListener<UserDetailBloc, UserDetailState>(
              listener: (ctx, state) {
                if (state is UserDetailUpdateSuccess ||
                    state is UserDetailLoaded) {
                  ctx.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
                }
              },
            ),
          ],
          child: const MaterialApp(
            title: 'VitaCal App',
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          ),
        ),
      ),
    );
  }
}
