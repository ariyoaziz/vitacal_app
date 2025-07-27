// import utama
// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/screen/main_page.dart';
import 'package:vitacal_app/screen/onboarding/get_started.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:vitacal_app/screen/error/koneksi.dart';
import 'package:vitacal_app/screen/error/perbaikan.dart';
import 'package:vitacal_app/services/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _checkLoginStatus();
  }

  Future<bool> _hasActiveInternet() async {
    try {
      print('Mengecek koneksi internet...');
      final response =
          await http.get(Uri.parse('https://www.google.com')).timeout(
                const Duration(seconds: 5),
              );
      print('Status code Google: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Gagal koneksi ke internet: $e');
      return false;
    }
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    // 🔌 1. Cek koneksi internet
    bool hasInternet = await _hasActiveInternet();
    if (!hasInternet) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Koneksi()),
      );
      return;
    }

    // 🔧 2. Cek koneksi backend & database
    try {
      final response = await http
          .get(Uri.parse(AppConstants.checkDbEndpoint))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Perbaikan()),
        );
        return;
      }
    } on TimeoutException {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Perbaikan()),
      );
      return;
    } catch (e) {
      // Tangani semua error termasuk SocketException dan lainnya
      print('ERROR KONEKSI BACKEND: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Perbaikan()),
      );
      return;
    }

    // ✅ 3. Cek status login via token
    if (!mounted) return;
    try {
      final authService = RepositoryProvider.of<AuthService>(context);
      final token = await authService.getJwtToken();

      print('DEBUG SPLASH: Token ditemukan: ${token != null ? "Ya" : "Tidak"}');

      if (token != null) {
        print('DEBUG SPLASH: Verifikasi token ke backend...');
        bool isTokenStillValid =
            await authService.verifyTokenWithBackend(token);
        print('DEBUG SPLASH: Validasi token hasil: $isTokenStillValid');

        if (isTokenStillValid && mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
            (route) => false,
          );
        } else {
          await authService.deleteJwtToken();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const GetStarted()),
            (route) => false,
          );
        }
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GetStarted()),
          (route) => false,
        );
      }
    } catch (e) {
      print('ERROR SPLASH: $e');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const GetStarted()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SvgPicture.asset('assets/icons/logo1.svg'),
          ),
        ),
      ),
    );
  }
}
