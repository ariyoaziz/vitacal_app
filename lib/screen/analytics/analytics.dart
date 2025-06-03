import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/analytics/card_beratgrafik.dart';
import 'package:vitacal_app/screen/analytics/card_kal.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/screen/home/kalender.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';

import 'package:vitacal_app/screen/analytics/card_berat.dart';
import 'package:vitacal_app/screen/analytics/card_bmi.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  double currentWeight = 58.0;
  double targetWeight = 63.0;
  double height = 165.0;

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi refresh
    setState(
      () {
        // Tambahkan logika pembaruan data jika perlu
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double heightInMeter = height / 100;
    double bmi = currentWeight / (heightInMeter * heightInMeter);

    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: AppColors.screen.withOpacity(0.98),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          backgroundColor: AppColors.screen,
          strokeWidth: 3,
          displacement: 60,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          SvgPicture.asset("assets/icons/logo.svg", height: 35),
                      onPressed: () {},
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/calender.svg",
                              height: 24),
                          onPressed: () => showKalenderDialog(context),
                        ),
                        const SizedBox(width: 11),
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/notif.svg",
                              height: 24),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Notifikasi()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 33),
                // Title
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/analytics.svg"),
                    const SizedBox(width: 11),
                    const Text(
                      "Analytics",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 33),
                // Weight Cards
                Row(
                  children: [
                    Expanded(
                      child: BeratCard(
                        label: "Berat Sekarang",
                        icon: "assets/icons/weight_sekarang.svg",
                        value: currentWeight,
                        onUpdate: (value) {
                          setState(() {
                            currentWeight = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: BeratCard(
                        label: "Tujuan Berat",
                        icon: "assets/icons/weight_tujuan.svg",
                        value: targetWeight,
                        onUpdate: (value) {
                          setState(() {
                            targetWeight = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 33),
                // BMI Card
                BmiCard(bmi: bmi),
                const SizedBox(height: 33),
                KaloriChartCard(),
                const SizedBox(height: 33),
                CardBeratGrafik(),
                SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    child: Text(
                      "Yuk, cek kalorimu dan terus melangkah menuju hidup sehat!",
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
