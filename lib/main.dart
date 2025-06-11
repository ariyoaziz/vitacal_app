// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import screens
import 'package:vitacal_app/screen/onboarding/splash_screen.dart';

// Import services
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/services/kalori_service.dart';
import 'package:vitacal_app/services/profile_service.dart';

// Import blocs
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_bloc.dart';

void main() {
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
          // Tambahkan KaloriBloc sebagai Bloc
          BlocProvider<KaloriBloc>(
            create: (context) => KaloriBloc(
              calorieService: RepositoryProvider.of<CalorieService>(context),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(profileService: ProfileService()),
          ),
        ],
        child: MaterialApp(
          title: 'VitaCal App',
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
