// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/screen/onboarding/splash_screen.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';

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
        // Tambahkan UserDetailService sebagai Repository
        RepositoryProvider<UserDetailService>(
          create: (context) => UserDetailService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: RepositoryProvider.of<AuthService>(context),
            ),
          ),
          // Tambahkan UserDetailBloc sebagai Bloc
          BlocProvider<UserDetailBloc>(
            create: (context) => UserDetailBloc(
              userDetailService:
                  RepositoryProvider.of<UserDetailService>(context),
            ),
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
