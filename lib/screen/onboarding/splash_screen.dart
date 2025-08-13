// lib/screen/onboarding/splash_screen.dart

// import utama
// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/screen/main_page.dart';
import 'package:vitacal_app/screen/onboarding/get_started.dart';
import 'package:vitacal_app/services/auth_service.dart'; // Pastikan AuthService diimpor
import 'package:connectivity_plus/connectivity_plus.dart'; // Pastikan ini diimpor jika digunakan
import 'package:http/http.dart' as http;
import 'package:vitacal_app/screen/error/koneksi.dart';
import 'package:vitacal_app/screen/error/perbaikan.dart';
import 'package:vitacal_app/services/constants.dart'; // Pastikan AppConstants.checkDbEndpoint ada

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

  /// Mengecek koneksi internet aktif.
  Future<bool> _hasActiveInternet() async {
    try {
      print('Mengecek koneksi internet...');
      final response =
          await http.get(Uri.parse('https://www.google.com')).timeout(
                const Duration(seconds: 5),
              );
      print('Status code Google: ${response.statusCode}');
      return response.statusCode == 200;
    } on SocketException catch (e) {
      // Tangani SocketException secara spesifik
      print('Gagal koneksi ke internet (SocketException): $e');
      return false;
    } on TimeoutException {
      // Tangani TimeoutException secara spesifik
      print('Gagal koneksi ke internet (TimeoutException): Koneksi timeout.');
      return false;
    } catch (e) {
      print('Gagal koneksi ke internet: $e');
      return false;
    }
  }

  Future<void> _checkLoginStatus() async {
    // Beri waktu animasi splash screen tampil
    await Future.delayed(const Duration(seconds: 3));

    bool hasInternet = await _hasActiveInternet();
    if (!hasInternet) {
      if (!mounted) return;
      // Navigasi ke halaman error koneksi internet
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Koneksi()),
      );
      return;
    }

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
    } on SocketException {
      print(
          'ERROR KONEKSI BACKEND (SocketException): Tidak bisa terhubung ke server.');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Perbaikan()),
      );
      return;
    } catch (e) {
      print('ERROR KONEKSI BACKEND: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Perbaikan()),
      );
      return;
    }

    if (!mounted) return;
    try {
      // Ambil instance AuthService dari Provider/RepositoryProvider
      final authService = RepositoryProvider.of<AuthService>(context);

      final token = await authService.getAuthToken();

      print('DEBUG SPLASH: Token ditemukan: ${token != null ? "Ya" : "Tidak"}');

      if (token != null) {
        print('DEBUG SPLASH: Verifikasi token ke backend...');
        bool isTokenStillValid =
            await authService.verifyTokenWithBackend(token);
        print('DEBUG SPLASH: Validasi token hasil: $isTokenStillValid');

        if (isTokenStillValid && mounted) {
          // Token valid, navigasi ke halaman utama
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
            (route) => false, // Hapus semua rute sebelumnya
          );
        } else {
          // Token tidak valid (kadaluarsa, dll.), hapus dan navigasi ke GetStarted
          // --- PERBAIKAN: Ganti deleteJwtToken() menjadi deleteAuthToken() ---
          await authService.deleteAuthToken();
          // --- AKHIR PERBAIKAN ---
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const GetStarted()),
            (route) => false,
          );
        }
      } else {
        // Tidak ada token, navigasi ke GetStarted
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GetStarted()),
          (route) => false,
        );
      }
    } catch (e) {
      // Tangani error umum selama proses cek token
      print('ERROR SPLASH: Terjadi kesalahan saat memeriksa status login: $e');
      // Navigasi ke GetStarted jika ada error
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
