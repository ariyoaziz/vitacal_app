// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/auth/login.dart';
import 'package:vitacal_app/screen/auth/registrasi.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo - Ukuran diperbesar
                SvgPicture.asset(
                  'assets/icons/logo1.svg',
                  height: 150, // Tinggi logo diperbesar
                ),
                const SizedBox(height: 16),
                const Text(
                  "Sahabat Nutrisi Sehatmu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 80),

                // Tombol "Pengguna Baru"
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Registrasi(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Pengguna Baru",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol "Sudah Punya Akun"
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      "Sudah Punya Akun",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 100),

                // Teks Kebijakan Privasi
                const Text(
                  "Dengan melanjutkan Anda menyetujui",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, // Ukuran font diperkecil
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4), // Spasi antara baris teks
                GestureDetector(
                  onTap: () {
                    print('Syarat dan Ketentuan Diklik');
                  },
                  child: Text(
                    "Syarat dan Ketentuan Kami dan Kebijakan Privasi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11, // Ukuran font diperkecil
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Jarak dari bagian paling bawah
              ],
            ),
          ),
        ),
      ),
    );
  }
}
