import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/home/kalender.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';
import 'package:vitacal_app/screen/analytics/showdialog_berat.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  // Variabel untuk menyimpan nilai berat
  double currentWeight = 58.0; // Berat Sekarang
  double targetWeight = 63.0; // Tujuan Berat

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = 24.0;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan ikon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/logo.svg",
                      height: 35.0,
                    ),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          "assets/icons/calender.svg",
                          height: iconSize,
                        ),
                        onPressed: () {
                          // Panggil dialog kalender dari file terpisah
                          showKalenderDialog(context);
                        },
                      ),
                      SizedBox(width: 11),
                      IconButton(
                        icon: SvgPicture.asset(
                          "assets/icons/notif.svg",
                          height: iconSize,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Notifikasi(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 33),

              // Judul halaman
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/analytics.svg",
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 33),
              Row(
                children: [
                  // Kartu Kiri - Berat Sekarang
                  Expanded(
                    child: Card(
                      color: AppColors.screen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                      elevation: 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(11),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/weight_sekarang.svg",
                                      height: 14,
                                    ),
                                    const SizedBox(width: 11),
                                    const Text(
                                      "Berat Sekarang",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 21),
                                Text(
                                  "${currentWeight.toStringAsFixed(2)} kg", // Menampilkan berat sekarang dengan 2 angka desimal
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 21),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                showUpdateBeratDialog(
                                  context: context,
                                  title: "Berat Sekarang",
                                  initialValue: currentWeight,
                                  minValue: 40.0,
                                  maxValue: 100.0,
                                  onSave: (value) {
                                    setState(() {
                                      currentWeight =
                                          value; // Update nilai berat
                                    });
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(21),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Perbaharui",
                                style: TextStyle(
                                  color: AppColors.screen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 11),

                  // Kartu Kanan - Tujuan Berat
                  Expanded(
                    child: Card(
                      color: AppColors.screen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                      elevation: 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(11),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/weight_tujuan.svg",
                                      height: 14,
                                    ),
                                    const SizedBox(width: 11),
                                    const Text(
                                      "Tujuan Berat",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 21),
                                Text(
                                  "${targetWeight.toStringAsFixed(2)} kg", // Menampilkan tujuan berat dengan 2 angka desimal
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 21),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                showUpdateBeratDialog(
                                  context: context,
                                  title: "Tujuan Berat",
                                  initialValue: targetWeight,
                                  minValue: 40.0,
                                  maxValue: 100.0,
                                  onSave: (value) {
                                    setState(() {
                                      targetWeight =
                                          value; // Update nilai tujuan berat
                                    });
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(21),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Perbaharui",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
