import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detailuser_usia.dart';
import 'package:vitacal_app/themes/colors.dart';

class DetailuserBeratDanTinggi extends StatefulWidget {
  const DetailuserBeratDanTinggi({super.key});

  @override
  State<DetailuserBeratDanTinggi> createState() =>
      _DetailuserBeratDanTinggiState();
}

class _DetailuserBeratDanTinggiState extends State<DetailuserBeratDanTinggi> {
  double _progressValue = 0.64;
  double _beratBadan = 60.0; // Default berat badan
  double _tinggiBadan = 160.0; // Default tinggi badan

  // Data untuk Berat Badan dan Tinggi Badan
  List<int> beratBadanList =
      List.generate(141, (index) => 10 + index); // 10 kg - 150 kg
  List<int> tinggiBadanList =
      List.generate(201, (index) => 50 + index); // 50 cm - 250 cm

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double itemHeight =
        screenHeight * 0.2; // 20% tinggi layar untuk setiap scrollable item
    double itemWidth = screenWidth * 0.4; // 40% lebar layar untuk list wheel

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
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
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
                          "Berapa Berat dan Tinggi Badanmu?",
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

                        // Baris untuk Berat Badan dan Tinggi Badan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Kolom Berat Badan di Kiri
                            Column(
                              children: [
                                const Text(
                                  "Berat Badan",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),

                                // ListWheelScrollView untuk Berat Badan
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.screen,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: SizedBox(
                                    height: itemHeight,
                                    width: itemWidth,
                                    child: ListWheelScrollView.useDelegate(
                                      itemExtent: 50, // Jarak antara item
                                      physics: FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          _beratBadan =
                                              beratBadanList[index].toDouble();
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                        builder: (context, index) {
                                          bool isSelected = index ==
                                              (beratBadanList.indexOf(
                                                  _beratBadan.toInt()));
                                          return Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors
                                                        .transparent, // Hijau untuk yang terpilih
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    beratBadanList[index]
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isSelected
                                                          ? AppColors.screen
                                                          : AppColors.darkGrey,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  if (isSelected)
                                                    Text(
                                                      "kg",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: beratBadanList.length,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Kolom Tinggi Badan di Kanan
                            Column(
                              children: [
                                const Text(
                                  "Tinggi Badan",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),

                                // ListWheelScrollView untuk Tinggi Badan
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.screen, // Background default
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: SizedBox(
                                    height: itemHeight,
                                    width: itemWidth,
                                    child: ListWheelScrollView.useDelegate(
                                      itemExtent: 50, // Jarak antara item
                                      physics: FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          _tinggiBadan =
                                              tinggiBadanList[index].toDouble();
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                        builder: (context, index) {
                                          bool isSelected = index ==
                                              (tinggiBadanList.indexOf(
                                                  _tinggiBadan.toInt()));
                                          return Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors
                                                        .transparent, // Hijau untuk yang terpilih
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    tinggiBadanList[index]
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isSelected
                                                          ? AppColors.screen
                                                          : AppColors.darkGrey,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  if (isSelected)
                                                    Text(
                                                      "cm",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: tinggiBadanList.length,
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
                          builder: (context) => const DetailuserUsia(),
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
