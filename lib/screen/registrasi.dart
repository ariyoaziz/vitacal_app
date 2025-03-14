import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/login.dart';
import 'package:vitacal_app/screen/otp_registrasi.dart';
import 'package:vitacal_app/themes/colors.dart';

class Registrasi extends StatefulWidget {
  const Registrasi({super.key});

  @override
  State<Registrasi> createState() => _RegistrasiState();
}

class _RegistrasiState extends State<Registrasi> {
  bool _isPasswordVisible = false; // Variabel untuk menampilkan password
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.05,
                bottom: screenHeight * 0.05,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Ayo Gabung,",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    "dan Mulai Hidup Sehat!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Email',
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
                            'assets/icons/email.svg', // Ganti dengan path file SVG yang sesuai
                            width: 20, // Sesuaikan lebar ikon
                            height: 20, // Sesuaikan tinggi ikon
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(height: 33),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Phone Number',
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
                            'assets/icons/phone.svg', // Ganti dengan path file SVG yang sesuai
                            width: 20, // Sesuaikan lebar ikon
                            height: 20, // Sesuaikan tinggi ikon
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(height: 33),
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
                  SizedBox(height: 33),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm Password',
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
                  SizedBox(height: screenHeight * 0.08),
                  const Text(
                    "Siap capai tujuan sehatmu?",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 11),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Klik ",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: "Daftar Sekarang",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: " dan mulai perjalanan\n",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: "barumu bersama ",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: "Vita",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: "Cal!",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
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
                              builder: (context) => const OtpRegistrasi(),
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
                          "Daftar Sekarang",
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
                    "Udah punya akun? wah, tinggal masuk aja!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5), // Memberikan jarak antar teks
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Masuk disini!',
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
                                builder: (context) => const Login()),
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
