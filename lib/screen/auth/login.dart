import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/auth/forgot_password.dart';
// ignore: unused_import
import 'package:vitacal_app/screen/home/home.dart';
import 'package:vitacal_app/screen/auth/registrasi.dart';
import 'package:vitacal_app/screen/main_page.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isPasswordVisible = false; // Variabel untuk menampilkan password

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar dan tinggi layar
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.1, // Padding atas 150
                bottom: screenHeight * 0.05, // Padding bawah 30
                left: screenWidth * 0.05, // Padding kiri 20
                right: screenWidth * 0.05, // Padding kanan 20
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Hore, Ketemu Lagi!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // Spasi antar elemen

                  // Logo Image
                  SizedBox(
                    child: SvgPicture.asset(
                      'assets/icons/logo1.svg',
                    ),
                  ),
                  const Text(
                    "Sahabat Nutrisi Sehatmu!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08), // Spasi antar elemen

                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Name',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SvgPicture.asset(
                            'assets/icons/user.svg', // Ganti dengan path file SVG yang sesuai
                            width: 20, // Sesuaikan lebar ikon
                            height: 20, // Sesuaikan tinggi ikon
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  const SizedBox(height: 33), // Spasi antar elemen

                  // TextField for Password
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Password',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SvgPicture.asset(
                            'assets/icons/sandi.svg', // Ganti dengan path file SVG yang sesuai
                            width: 20, // Sesuaikan lebar ikon
                            height: 20, // Sesuaikan tinggi ikon
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // Forget Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPassword(), // Navigasi ke halaman Lupa Kata Sandi
                          ),
                        );
                      },
                      child: const Text(
                        'Lupa kata sandi? Tenang, kami bantu!',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppColors.greenGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors
                                .white, // Warna teks agar tetap terlihat jelas
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 33),
                  const Text(
                    "Belum punya akun? Wah, kamu harus gabung nih!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8), // Memberikan jarak antar teks
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Daftar Yuk!',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Registrasi()),
                          );
                        },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
