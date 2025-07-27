// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/onboarding/splash_screen.dart';
import 'package:vitacal_app/themes/colors.dart';

class Koneksi extends StatelessWidget {
  const Koneksi({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final double screenWidth = screen.width;
    final double screenHeight = screen.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.08), // Tidak terlalu atas

            // Judul
            const Text(
              "Yah, Nggak Ada Sinyal!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            // Spacer sebelum konten tengah
            const Spacer(flex: 2),

            // Gambar + Deskripsi di tengah
            Column(
              children: [
                Image.asset(
                  'assets/images/koneksi.png',
                  height: screenHeight * 0.22,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: const Text(
                    "Cek dulu koneksimu.\nSiapa tahu Wifi-nya ngambek atau kuota habis (x_X). "
                    "Nanti kalau udah nyambung, coba lagi ya.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height:
                          1.6, // Tambahkan line spacing agar tidak terlalu rapat
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
              ],
            ),

            // Spacer ke bawah
            const Spacer(flex: 3),

            // Tombol Aksi
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [
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
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const SplashScreen()),
                            (route) => false,
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
                          "Coba Lagi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Kebijakan Privasi
                  const Text(
                    "Dengan melanjutkan Anda menyetujui",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      print('Syarat dan Ketentuan Diklik');
                    },
                    child: const Text(
                      "Syarat dan Ketentuan Kami dan Kebijakan Privasi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
