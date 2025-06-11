// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_tujuan.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart';
import 'package:vitacal_app/models/enums.dart';

class DetailuserAktivitas extends StatefulWidget {
  final UserDetailFormData formData;

  const DetailuserAktivitas({super.key, required this.formData});

  @override
  State<DetailuserAktivitas> createState() => _DetailuserAktivitasState();
}

class _DetailuserAktivitasState extends State<DetailuserAktivitas> {
  final double _progressValue = 0.83;
  Aktivitas? _selectedAktivitas;
  String? _aktivitasErrorMessage;

  @override
  void initState() {
    super.initState();
    _selectedAktivitas = widget.formData.aktivitas;
  }

  // Fungsi saat tombol "Lanjut" ditekan - FUNGSI INI TIDAK DIUBAH
  void _onNextPressed() {
    setState(() {
      _aktivitasErrorMessage = null;
    });

    if (_selectedAktivitas == null) {
      setState(() {
        _aktivitasErrorMessage = "Eits, pilih tingkat aktivitasmu dulu ya!";
      });
      return;
    }

    final updatedFormData = widget.formData.copyWith(
      aktivitas: _selectedAktivitas,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailuserTujuan(formData: updatedFormData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Padding(
          // Padding global disesuaikan
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // Konsisten dengan halaman auth
            vertical: screenHeight * 0.05, // Spasi vertikal yang nyaman
          ),
          child: Column(
            children: [
              // Baris untuk Tombol Back dan Garis Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.65,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ],
              ),
              // Expanded untuk mendorong konten dan tombol agar terdistribusi dengan baik
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Konten di tengah vertikal
                  children: [
                    // Judul
                    const Text(
                      "Bagaimana Tingkat Aktivitasmu?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28, // Ukuran font judul konsisten
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    // Pesan error validasi kustom
                    if (_aktivitasErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 12.0, bottom: 8.0), // Padding disesuaikan
                        child: Text(
                          _aktivitasErrorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 12), // Spasi setelah judul/error
                    // Deskripsi
                    const Text(
                      "Informasi ini membantu kami menghitung kebutuhan kalori harianmu dengan lebih akurat.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15, // Ukuran font deskripsi konsisten
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(
                        height: 30), // Spasi sebelum pilihan aktivitas

                    // Pilihan Aktivitas dengan Card
                    // Menggunakan SingleChildScrollView agar semua pilihan bisa di-scroll
                    Expanded(
                      // Tambahkan Expanded untuk SingleChildScrollView
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildAktivitasCard(
                              context,
                              label: "Jarang Sekali",
                              description:
                                  "Kegiatan sehari-hari yang membutuhkan sedikit usaha, seperti beristirahat, kerja di belakang meja, atau mengemudi.",
                              icon: Icons.chair_alt,
                              value: Aktivitas.tidakAktif,
                              screenWidth: screenWidth,
                              isSelected:
                                  _selectedAktivitas == Aktivitas.tidakAktif,
                              onTap: () {
                                setState(() {
                                  _selectedAktivitas = Aktivitas.tidakAktif;
                                  _aktivitasErrorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(
                                height: 12), // Spasi antar kartu aktivitas
                            _buildAktivitasCard(
                              context,
                              label: "Sedikit Aktif",
                              description:
                                  "Kegiatan sehari-hari yang membutuhkan beberapa upaya, seperti berdiri secara berkala, pekerjaan rumah, atau latihan ringan.",
                              icon: Icons.directions_walk,
                              value: Aktivitas.ringan,
                              screenWidth: screenWidth,
                              isSelected:
                                  _selectedAktivitas == Aktivitas.ringan,
                              onTap: () {
                                setState(() {
                                  _selectedAktivitas = Aktivitas.ringan;
                                  _aktivitasErrorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildAktivitasCard(
                              context,
                              label: "Aktif",
                              description:
                                  "Kegiatan sehari-hari yang membutuhkan upaya lebih, seperti berdiri lama, kerja fisik, atau olahraga ringan secara teratur.",
                              icon: Icons.run_circle,
                              value: Aktivitas.sedang,
                              screenWidth: screenWidth,
                              isSelected:
                                  _selectedAktivitas == Aktivitas.sedang,
                              onTap: () {
                                setState(() {
                                  _selectedAktivitas = Aktivitas.sedang;
                                  _aktivitasErrorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildAktivitasCard(
                              context,
                              label: "Sangat Aktif",
                              description:
                                  "Kegiatan yang membutuhkan usaha fisik berat, seperti pekerjaan konstruksi atau olahraga berat secara teratur.",
                              icon: Icons.fitness_center,
                              value: Aktivitas.berat,
                              screenWidth: screenWidth,
                              isSelected: _selectedAktivitas == Aktivitas.berat,
                              onTap: () {
                                setState(() {
                                  _selectedAktivitas = Aktivitas.berat;
                                  _aktivitasErrorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildAktivitasCard(
                              context,
                              label: "Super Aktif",
                              description:
                                  "Kegiatan yang sangat intensif setiap hari, seperti atlet profesional atau pekerjaan fisik ekstrem.",
                              icon: Icons.directions_bike,
                              value: Aktivitas.sangatBerat,
                              screenWidth: screenWidth,
                              isSelected:
                                  _selectedAktivitas == Aktivitas.sangatBerat,
                              onTap: () {
                                setState(() {
                                  _selectedAktivitas = Aktivitas.sangatBerat;
                                  _aktivitasErrorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(
                                height:
                                    20), // Padding bawah daftar kartu aktivitas
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Lanjut (fixed di bawah)
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
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Lanjut",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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

  // Helper untuk membangun Card pilihan aktivitas
  Widget _buildAktivitasCard(
    BuildContext context, {
    required String label,
    required String description,
    required IconData icon,
    required Aktivitas value,
    required double screenWidth,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12), // Radius konsisten dengan input field
      child: Card(
        elevation: 1, // Elevation yang sedikit lebih rendah
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Radius konsisten
          side: isSelected
              ? const BorderSide(
                  color: AppColors.primary, width: 2) // Border saat terpilih
              : BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1), // Border halus saat tidak terpilih
        ),
        color: isSelected
            ? AppColors.lightPrimary
            : Colors.white, // Warna background saat terpilih atau tidak
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20), // Padding dalam card pilihan disesuaikan
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.darkGrey, // Warna ikon
                    size: 28, // Ukuran ikon
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    // Menggunakan Expanded agar label tidak overflow
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkGrey, // Warna teks
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Spasi antara label dan deskripsi
              Text(
                description,
                style: TextStyle(
                  fontSize: 14, // Ukuran font deskripsi disesuaikan
                  color: isSelected
                      ? AppColors.darkGrey
                      : Colors.grey[600], // Warna deskripsi
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
