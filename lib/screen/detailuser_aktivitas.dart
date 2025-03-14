import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/login.dart';
import 'package:vitacal_app/themes/colors.dart';

class DetailuserAktivitas extends StatefulWidget {
  const DetailuserAktivitas({super.key});

  @override
  State<DetailuserAktivitas> createState() => _DetailuserAktivitasState();
}

class _DetailuserAktivitasState extends State<DetailuserAktivitas> {
  double _progressValue = 1;
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
            vertical: screenHeight * 0.05,
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
                    width: screenWidth * 0.75,
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
                          "Bgaiamana Aktivitas Harian Anda?",
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

                        // Pilihan Aktivitas dengan Card
                        Column(
                          children: [
                            // Jarang Sekali
                            SizedBox(
                              width: screenWidth * 0.85,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan = "Jarang Sekali";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  color: _selectedTujuan == "Jarang Sekali"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .pause_circle_outline, // Ikon untuk jarang sekali
                                              color: _selectedTujuan ==
                                                      "Jarang Sekali"
                                                  ? AppColors.primary
                                                  : AppColors.primary,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Jarang Sekali",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Kegiatan sehari-hari yang membutuhkan sedikit usaha, seperti beristirahat, kerja di belakang meja, atau mengemudi.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 11),

                            // Sedikit Aktif
                            SizedBox(
                              width: screenWidth * 0.85,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan = "Sedikit Aktif";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  color: _selectedTujuan == "Sedikit Aktif"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .access_alarm, // Ikon untuk sedikit aktif
                                              color: _selectedTujuan ==
                                                      "Sedikit Aktif"
                                                  ? AppColors.primary
                                                  : AppColors.primary,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Sedikit Aktif",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Kegiatan sehari-hari yang membutuhkan beberapa upaya, seperti berdiri secara berkala, pekerjaan rumah, atau latihan ringan.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 11),

                            // Aktif
                            SizedBox(
                              width: screenWidth * 0.85,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan = "Aktif";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  color: _selectedTujuan == "Aktif"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .directions_run, // Ikon untuk aktif
                                              color: _selectedTujuan == "Aktif"
                                                  ? AppColors.primary
                                                  : AppColors.primary,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Aktif",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Kegiatan sehari-hari yang membutuhkan upaya lebih, seperti berdiri lama, kerja fisik, atau olahraga ringan secara teratur.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 11),

                            // Sangat Aktif
                            SizedBox(
                              width: screenWidth * 0.85,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTujuan = "Sangat Aktif";
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  color: _selectedTujuan == "Sangat Aktif"
                                      ? Color(0xFFF1F0E9)
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .fitness_center, // Ikon untuk sangat aktif
                                              color: _selectedTujuan ==
                                                      "Sangat Aktif"
                                                  ? AppColors.primary
                                                  : AppColors.primary,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Sangat Aktif",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Kegiatan yang membutuhkan usaha fisik berat, seperti pekerjaan konstruksi atau olahraga berat secara teratur.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.darkGrey,
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

              // Tombol Lanjut
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
                          builder: (context) => const Login(),
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
                      "Simapan",
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
