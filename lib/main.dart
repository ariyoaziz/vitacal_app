// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:vitacal_app/screen/onboarding/splash_screen.dart';

import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/services/kalori_service.dart';
import 'package:vitacal_app/services/profile_service.dart';

import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_bloc.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Mendapatkan daftar kamera yang tersedia dan menyimpannya ke variabel global 'cameras'
    cameras = await availableCameras();
    print('DEBUG MAIN: Kamera yang tersedia: ${cameras.length}');
  } on CameraException catch (e) {
    // Tangani error jika gagal mendapatkan daftar kamera (misal, izin ditolak)
    print(
        'ERROR MAIN: Gagal mendapatkan daftar kamera: ${e.code}. Deskripsi: ${e.description}');
    // Anda bisa memberikan feedback ke user atau menonaktifkan fitur kamera jika tidak ada kamera.
  } catch (e) {
    // Tangani error tak terduga lainnya
    print(
        'ERROR MAIN: Terjadi kesalahan tidak terduga saat mendapatkan kamera: $e');
  }
  // >>>>>> AKHIR BAGIAN KRUSIAL <<<<<<

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<UserDetailService>(
          create: (context) => UserDetailService(),
        ),
        RepositoryProvider<CalorieService>(
          create: (context) => CalorieService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: RepositoryProvider.of<AuthService>(context),
            ),
          ),
          BlocProvider<UserDetailBloc>(
            create: (context) => UserDetailBloc(
              userDetailService:
                  RepositoryProvider.of<UserDetailService>(context),
            ),
          ),
          BlocProvider<KaloriBloc>(
            create: (context) => KaloriBloc(
              calorieService: RepositoryProvider.of<CalorieService>(context),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              profileService: ProfileService(
                userDetailService:
                    RepositoryProvider.of<UserDetailService>(context),
              ),
              authService: RepositoryProvider.of<AuthService>(
                  context), // Tambahkan AuthService di sini
            ),
          ),
        ],
        child: MaterialApp(
          title: 'VitaCal App',
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(), // Halaman awal aplikasi
        ),
      ),
    );
  }
}
