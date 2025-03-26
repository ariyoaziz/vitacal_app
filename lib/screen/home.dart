// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:vitacal_app/screen/navabar.dart';
import 'package:vitacal_app/themes/colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = -1; // Indeks untuk menandai hari yang dipilih

  // Mapping nama hari menjadi 2 huruf
  final Map<String, String> shortDays = {
    "Monday": "Mo",
    "Tuesday": "Tu",
    "Wednesday": "We",
    "Thursday": "Th",
    "Friday": "Fr",
    "Saturday": "Sa",
    "Sunday": "Su",
  };

  late List<DateTime> weekDates; // Daftar tanggal dari Senin sampai Minggu

  @override
  void initState() {
    super.initState();

    // Cari Senin terdekat sebelum atau sama dengan hari ini
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    // Buat daftar 7 hari dari Senin ke Minggu
    weekDates =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    // Set `selectedIndex` agar sesuai dengan tanggal hari ini
    selectedIndex = weekDates.indexWhere((date) =>
        DateFormat("yyyy-MM-dd").format(date) ==
        DateFormat("yyyy-MM-dd").format(today));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = 24.0; // Ukuran ikon yang konsisten

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
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
                            onPressed: () {},
                          ),
                          SizedBox(width: 11),
                          IconButton(
                            icon: SvgPicture.asset(
                              "assets/icons/notif.svg",
                              height: iconSize,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 33),

                  // Tanggal utama (tanggal hari ini)
                  Text(
                    DateFormat("d MMMM yyyy")
                        .format(DateTime.now()), // Format: 22 Maret 2025
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 33),

                  // Row hari dan tanggal dalam kotak dengan border
                  SizedBox(
                    width: double
                        .infinity, // Agar sejajar dengan header di atasnya
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekDates.asMap().entries.map((entry) {
                        int index = entry.key;
                        DateTime date = entry.value;

                        bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 15),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black
                                        .withOpacity(0.5), // Opasitas 50%
                                width: 0.5, // Border lebih tipis
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  shortDays[DateFormat("EEEE").format(date)]!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.7)
                                        : AppColors.darkGrey.withOpacity(0.7),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  DateFormat("d")
                                      .format(date), // Hanya angka tanggal
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkGrey,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 33),
                  SizedBox(
                    width: 280,
                    child: Text(
                      "Siap jaga pola makan hari ini? Yuk, hitung kalorimu dan tetap sehat!",
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign:
                          TextAlign.center, // Agar teks lebih rapi di tengah
                    ),
                  ),
                  const SizedBox(height: 33),
                  Container(
                    width: 372,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Warna hijau dominan
                      borderRadius: BorderRadius.circular(33),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Indikator Lingkaran Kalori
                        SizedBox(height: 33),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 170,
                              height: 170,
                              child: CircularProgressIndicator(
                                value: 0.8, // 80% progress
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 15,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bolt, // Ikon petir
                                  color: Colors.amber, // Warna kuning keorenan
                                  size: 28, // Sesuaikan ukuran agar pas
                                ),
                                SizedBox(
                                    height: 5), // Jarak antara ikon dan angka
                                FittedBox(
                                  child: Text(
                                    '200', // Kalori tersisa
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    "Kalori yang masih bisa dikonsumsi",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.amber,
                                size: 25,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "2,300 Kkal",
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.cream,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Kalori yang sudah dikonsumsi",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 33),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons
                                      .fitness_center, // Ikon otot untuk protein
                                  color: AppColors.screen,
                                  size: 24,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Protein",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "50g",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.cream,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: AppColors.screen,
                                  size: 24,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Lemak",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "30g",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.cream,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  color: AppColors.screen,
                                  size: 24,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Karbohidrat",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "200g",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.cream,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),

                  SizedBox(height: 33),
                  Column(
                    children: [
                      // Makan Pagi
                      Container(
                        width: 372,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.screen,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: Icon(Icons.sunny_snowing,
                                      color: Colors.deepOrangeAccent, size: 28),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Makan Pagi",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGrey)),
                                    SizedBox(height: 5),
                                    Text("Total: 500 Kkal",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.darkGrey
                                                .withOpacity(0.8))),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: AppColors.darkGrey, size: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 21),

                      // Makan Siang
                      Container(
                        width: 372,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.screen,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: Icon(Icons.wb_sunny_sharp,
                                      color: Colors.orange, size: 28),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Makan Siang",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGrey)),
                                    SizedBox(height: 5),
                                    Text("Total: 700 Kkal",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.darkGrey
                                                .withOpacity(0.8))),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: AppColors.darkGrey, size: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 21),

                      // Makan Malam
                      Container(
                        width: 372,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.screen,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: Icon(Icons.nightlight_round,
                                      color: Colors.blueAccent, size: 28),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Makan Malam",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGrey)),
                                    SizedBox(height: 5),
                                    Text("Total: 600 Kkal",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.darkGrey
                                                .withOpacity(0.8))),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: AppColors.darkGrey, size: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 21),

                      // Cemilan / Lainnya
                      Container(
                        width: 372,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.screen,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: Icon(Icons.more_horiz,
                                      color: AppColors.primary, size: 28),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cemilan / Lainnya",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Total: 300 Kkal",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            AppColors.darkGrey.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.darkGrey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavBar(),
    );
  }
}
