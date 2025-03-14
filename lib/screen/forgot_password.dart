import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/login.dart';
import 'package:vitacal_app/screen/otp_forgotpassword.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter/gestures.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
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
                    "Lupa Kata Sandi?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // Spasi antar elemen

                  // Logo Image
                  SizedBox(
                    child: Image.asset(
                      'assets/images/forgot_password.png',
                    ),
                  ),
                  const SizedBox(height: 50),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Masukan nomor whatsapp yang terdaftar.\n",
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text:
                              "Kami akan mengirimkan kode untuk reset kata sandi.",
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
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
                              builder: (context) => const OtpForgotpassword(),
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
                          "Lanjut",
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
                    "Sudah ingat kata sandimu? wah, tinggal masuk aja!",
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
