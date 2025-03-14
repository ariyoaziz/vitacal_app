import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detailuser_gender.dart';
import 'package:vitacal_app/themes/colors.dart';

class DetailuserInputNama extends StatefulWidget {
  const DetailuserInputNama({super.key});

  @override
  State<DetailuserInputNama> createState() => _DetailuserInputNamaState();
}

class _DetailuserInputNamaState extends State<DetailuserInputNama> {
  final TextEditingController _nameController = TextEditingController();
  double _progressValue = 0.16;

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
              // Garis Progress - Ditempatkan langsung setelah padding atas
              SizedBox(
                width: screenWidth * 0.8,
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
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
                          "Masukan Nama Kamu",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 11),
                        const Text(
                          "Hai, Kami ingin mengenal Anda untuk menjadikan aplikasi VitaCal dipersonalisasi untuk Anda.",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 33),

                        // Input Nama
                        SizedBox(
                          width: screenWidth * 0.85,
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama',
                              hintText: 'Nama',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            keyboardType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

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
                          builder: (context) => const DetailuserGender(),
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
                        color: Colors.white,
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
