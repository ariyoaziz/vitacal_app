// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vitacal_app/screen/detailuser_berat_dan_tinggi.dart';
import 'package:vitacal_app/themes/colors.dart';

class DetailuserTujuan extends StatefulWidget {
  const DetailuserTujuan({super.key});

  @override
  State<DetailuserTujuan> createState() => _DetailuserTujuanState();
}

class _DetailuserTujuanState extends State<DetailuserTujuan> {
  double _progressValue = 0.48;
  String? _selectedTujuan;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05, // Padding atas & bawah
          ),
          child: Column(
            children: [
              // Baris untuk Progress dan Tombol Back
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Back
                  Ink(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        color: AppColors.primary,
                        height: 15,
                        width: 15,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                      },
                    ),
                  ),

                  // Garis Progress
                  SizedBox(
                    width: screenWidth * 0.73,
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),

              // Expanded untuk menyesuaikan layout agar button tetap di bawah
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        // Judul
                        const Text(
                          "Apa Tujuan Kamu?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 11),
                        const Text(
                          "Kami ingin mengenal Anda lebih baik untuk menjadikan aplikasi VitaCal dipersonalisasi.",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 33),

                        // Pilihan Gender dengan Card
                        Column(
                          children: [
                            // Menurunkan Berat Badan
                            SizedBox(
                              width: screenWidth *
                                  0.85, // Menyamaikan lebar dengan tombol
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan = "Menurunkan Berat Badan";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                  color: _selectedTujuan ==
                                          "Menurunkan Berat Badan"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .remove_circle_outline, // Ikon untuk menurunkan berat badan
                                          color: _selectedTujuan ==
                                                  "Menurunkan Berat Badan"
                                              ? AppColors.primary
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Menurunkan Berat Badan",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Menambahkan Berat Badan
                            SizedBox(
                              width: screenWidth *
                                  0.85, // Menyamaikan lebar dengan tombol
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan = "Menambahkan Berat Badan";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                  color: _selectedTujuan ==
                                          "Menambahkan Berat Badan"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .add_circle_outline, // Ikon untuk menambahkan berat badan
                                          color: _selectedTujuan ==
                                                  "Menambahkan Berat Badan"
                                              ? AppColors.primary
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Menambahkan Berat Badan",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Menjaga Berat Badan Ideal
                            SizedBox(
                              width: screenWidth *
                                  0.85, // Menyamaikan lebar dengan tombol
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan =
                                        "Menjaga Berat Badan Ideal";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                  color: _selectedTujuan ==
                                          "Menjaga Berat Badan Ideal"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .fitness_center, // Ikon untuk menjaga berat badan ideal
                                          color: _selectedTujuan ==
                                                  "Menjaga Berat Badan Ideal"
                                              ? AppColors.primary
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Menjaga Berat Badan Ideal",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Menaikan Massa Tubuh
                            SizedBox(
                              width: screenWidth *
                                  0.85, // Menyamaikan lebar dengan tombol
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan = "Menaikan Massa Tubuh";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                  color:
                                      _selectedTujuan == "Menaikan Massa Tubuh"
                                          ? Color(0xFFF1F0E9)
                                          : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .accessibility_new, // Ikon untuk menaikan massa tubuh
                                          color: _selectedTujuan ==
                                                  "Menaikan Massa Tubuh"
                                              ? AppColors.primary
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Menaikan Massa Tubuh",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Lanjut - Selalu berada di bagian bawah sebelum padding
              SizedBox(
                width: screenWidth * 0.85,
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
                          builder: (context) =>
                              const DetailuserBeratDanTinggi(),
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
                        color: AppColors.screen,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
