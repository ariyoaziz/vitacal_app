import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_tujuan.dart';
import 'package:vitacal_app/themes/colors.dart';

class DetailuserGender extends StatefulWidget {
  const DetailuserGender({super.key});

  @override
  State<DetailuserGender> createState() => _DetailuserGenderState();
}

class _DetailuserGenderState extends State<DetailuserGender> {
  double _progressValue = 0.32;
  String? _selectedGender;

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
                        // ignore: deprecated_member_use
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
                          "Pilih Gender Kamu",
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
                            // Laki-laki Option
                            SizedBox(
                              width: screenWidth *
                                  0.85, // Menyamaikan lebar dengan tombol
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGender = "Laki-laki";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                  color: _selectedGender == "Laki-laki"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.male,
                                          color: _selectedGender == "Laki-laki"
                                              ? AppColors.primary
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Laki-laki",
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
                            // Perempuan Option
                            SizedBox(
                              width: screenWidth * 0.85,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGender = "Perempuan";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                  color: _selectedGender == "Perempuan"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.female,
                                          color: _selectedGender == "Perempuan"
                                              ? AppColors.primary
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Perempuan",
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
                          builder: (context) => const DetailuserTujuan(),
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
