import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detailuser_aktivitas.dart';
import 'package:vitacal_app/themes/colors.dart';

class DetailuserUsia extends StatefulWidget {
  const DetailuserUsia({super.key});

  @override
  State<DetailuserUsia> createState() => _DetailuserUsiaState();
}

class _DetailuserUsiaState extends State<DetailuserUsia> {
  double _progressValue = 0.80;
  int _tanggal = 1; // Default tanggal
  int _bulan = 0; // Default bulan (0 untuk Januari)
  int _tahun = 2000; // Default tahun

  // Data untuk Tanggal, Bulan, dan Tahun
  List<int> tanggalList = List.generate(31, (index) => index + 1); // 1-31
  List<String> bulanList = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  List<int> tahunList =
      List.generate(101, (index) => 2025 - index); // 2025-1925

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Menyesuaikan ukuran font dan padding agar responsif
    double itemHeight = screenHeight * 0.2;
    double itemWidth =
        screenWidth * 0.3; // Lebih kecil agar pas di berbagai ukuran layar
    double fontSize =
        screenWidth * 0.05; // Ukuran font proporsional dengan lebar layar

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
                        Text(
                          "Berapa Usia Anda?",
                          style: TextStyle(
                            fontSize: 24, // Ukuran font responsif
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Text(
                          "Kami ingin mengenal Anda lebih baik untuk menjadikan aplikasi VitaCal dipersonalisasi.",
                          style: TextStyle(
                            fontSize:
                                screenWidth * 0.04, // Ukuran font responsif
                            color: AppColors.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 33),

                        // Baris untuk Tanggal, Bulan, dan Tahun
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Kolom Tanggal di Kiri
                            Column(
                              children: [
                                Text(
                                  "Tanggal",
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),

                                // ListWheelScrollView untuk Tanggal
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
                                          _tanggal = tanggalList[index];
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                        builder: (context, index) {
                                          bool isSelected = index ==
                                              tanggalList.indexOf(_tanggal);
                                          return Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: Text(
                                                tanggalList[index].toString(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? AppColors.screen
                                                      : AppColors.darkGrey,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: tanggalList.length,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Kolom Bulan di Tengah
                            Column(
                              children: [
                                Text(
                                  "Bulan",
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),

                                // ListWheelScrollView untuk Bulan
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.screen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: SizedBox(
                                    height: itemHeight,
                                    width: itemWidth,
                                    child: ListWheelScrollView.useDelegate(
                                      itemExtent: 50,
                                      physics: FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          _bulan = index;
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                        builder: (context, index) {
                                          bool isSelected = index == _bulan;
                                          return Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: Text(
                                                bulanList[index],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? AppColors.screen
                                                      : AppColors.darkGrey,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: bulanList.length,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Kolom Tahun di Kanan
                            Column(
                              children: [
                                Text(
                                  "Tahun",
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),

                                // ListWheelScrollView untuk Tahun
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
                                      itemExtent: 50,
                                      physics: FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          _tahun = tahunList[index];
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                        builder: (context, index) {
                                          bool isSelected = index ==
                                              tahunList.indexOf(_tahun);
                                          return Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: Text(
                                                tahunList[index].toString(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? AppColors.screen
                                                      : AppColors.darkGrey,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: tahunList.length,
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
                          builder: (context) => const DetailuserAktivitas(),
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
