import 'package:flutter/material.dart';
import 'dart:async'; // Pastikan ini diimpor
import 'package:flutter_svg/flutter_svg.dart'; // Pastikan ini diimpor
import 'package:flutter_bloc/flutter_bloc.dart'; // Import ini untuk akses Bloc/RepositoryProvider
import 'package:vitacal_app/screen/main_page.dart';

// Import halaman yang mungkin dituju
import 'package:vitacal_app/screen/onboarding/get_started.dart'; // Halaman jika belum login/onboarding
import 'package:vitacal_app/services/auth_service.dart'; // Import AuthService

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

    // >>>>>> PERUBAHAN LOGIKA UTAMA DI SINI <<<<<<
    _checkLoginStatus(); // Panggil fungsi pengecekan status login
  }

  // Fungsi baru untuk memeriksa status login
  Future<void> _checkLoginStatus() async {
    // Memberikan sedikit delay untuk efek splash screen dan agar animasi selesai
    await Future.delayed(const Duration(seconds: 3));

    // Pastikan context masih valid sebelum melakukan navigasi
    if (!mounted) return;

    try {
      final authService = RepositoryProvider.of<AuthService>(context);
      final token = await authService.getJwtToken();

      print('DEBUG SPLASH: Token ditemukan: ${token != null ? "Ya" : "Tidak"}');

      if (token != null) {
        bool isTokenStillValid =
            await _verifyTokenWithBackend(token, authService);

        if (isTokenStillValid && mounted) {
          print('DEBUG SPLASH: Token valid, mengarahkan ke Home.');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          print(
              'DEBUG SPLASH: Token tidak valid/expired, mengarahkan ke GetStarted.');
          await authService.deleteJwtToken(); // Hapus token kadaluarsa/invalid
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GetStarted()),
          );
        }
      } else {
        print('DEBUG SPLASH: Tidak ada token, mengarahkan ke GetStarted.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GetStarted()),
        );
      }
    } catch (e) {
      // Tangani error jika terjadi masalah saat mengakses AuthService atau SharedPreferences
      print('ERROR SPLASH: Terjadi kesalahan saat memeriksa status login: $e');
      // Sebagai fallback, arahkan ke GetStarted jika ada error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GetStarted()),
      );
    }
  }

  // Fungsi untuk memverifikasi token dengan backend (Opsional tapi Direkomendasikan)
  // Anda perlu membuat endpoint di backend Anda, misalnya GET /users/verify-token
  // yang hanya membutuhkan @jwt_required() dan mengembalikan 200 OK jika valid.
  Future<bool> _verifyTokenWithBackend(
      String token, AuthService authService) async {
    try {
      // Asumsi AuthService memiliki metode verifyToken yang memanggil API backend.
      // Jika tidak ada, untuk demo, kita asumsikan true.
      // DI PRODUKSI, HARUS ADA VERIFIKASI DENGAN BACKEND ATAU DEKODE JWT UNTUK CEK KADALUARSA.
      // Contoh: return await authService.verifyToken(token);
      return true; // <<< Placeholder: Untuk sekarang, asumsikan token yang ada itu valid
    } catch (e) {
      print(
          'DEBUG SPLASH: Token verification failed in _verifyTokenWithBackend: $e');
      return false;
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
            child: SvgPicture.asset(
              'assets/icons/logo1.svg',
            ),
          ),
        ),
      ),
    );
  }
}
