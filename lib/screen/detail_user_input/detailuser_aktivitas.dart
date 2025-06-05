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
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              // Baris untuk Progress dan Tombol Back (fixed di atas)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Ink(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                        height: 15,
                        width: 15,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
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
              const SizedBox(
                  height: 20), // Jarak antara progress bar dan header

              // --- Bagian Header Statis (Tidak ikut di-scroll) ---
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Pusatkan teks di header
                children: [
                  const Text(
                    "Bagaimana Tingkat Aktivitasmu?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // --- PERBAIKAN: Penempatan Pesan Error di bawah judul ---
                  if (_aktivitasErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        _aktivitasErrorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // --- AKHIR PERBAIKAN ---
                  const SizedBox(height: 11),
                  const Text(
                    "Informasi ini membantu kami menghitung kebutuhan kalori harianmu dengan lebih akurat.",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 33), // Jarak sebelum konten scrollable
                ],
              ),
              // --- Akhir Bagian Header Statis ---

              // --- Bagian Konten yang bisa di-scroll (Expanded dan SingleChildScrollView) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Konten dimulai dari atas scroll view
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Pilihan Aktivitas dengan Card
                      Column(
                        children: [
                          _buildAktivitasCard(
                            label: "Jarang Sekali",
                            description:
                                "Kegiatan sehari-hari yang membutuhkan sedikit usaha, seperti beristirahat, kerja di belakang meja, atau mengemudi.",
                            icon: Icons.chair_alt,
                            value: Aktivitas.tidakAktif,
                            screenWidth: screenWidth,
                          ),
                          const SizedBox(height: 11),
                          _buildAktivitasCard(
                            label: "Sedikit Aktif",
                            description:
                                "Kegiatan sehari-hari yang membutuhkan beberapa upaya, seperti berdiri secara berkala, pekerjaan rumah, atau latihan ringan.",
                            icon: Icons.directions_walk,
                            value: Aktivitas.ringan,
                            screenWidth: screenWidth,
                          ),
                          const SizedBox(height: 11),
                          _buildAktivitasCard(
                            label: "Aktif",
                            description:
                                "Kegiatan sehari-hari yang membutuhkan upaya lebih, seperti berdiri lama, kerja fisik, atau olahraga ringan secara teratur.",
                            icon: Icons.run_circle,
                            value: Aktivitas.sedang,
                            screenWidth: screenWidth,
                          ),
                          const SizedBox(height: 11),
                          _buildAktivitasCard(
                            label: "Sangat Aktif",
                            description:
                                "Kegiatan yang membutuhkan usaha fisik berat, seperti pekerjaan konstruksi atau olahraga berat secara teratur.",
                            icon: Icons.fitness_center,
                            value: Aktivitas.berat,
                            screenWidth: screenWidth,
                          ),
                          const SizedBox(height: 11),
                          _buildAktivitasCard(
                            label: "Super Aktif",
                            description:
                                "Kegiatan yang sangat intensif setiap hari, seperti atlet profesional atau pekerjaan fisik ekstrem.",
                            icon: Icons.directions_bike,
                            value: Aktivitas.sangatBerat,
                            screenWidth: screenWidth,
                          ),
                        ],
                      ),
                      const SizedBox(
                          height:
                              20), // Jarak sebelum tombol Lanjut (jika di bawah scrollable)
                    ],
                  ),
                ),
              ),
              // --- Akhir Bagian Konten yang bisa di-scroll ---

              // Tombol Lanjut (fixed di bawah)
              SizedBox(
                width: screenWidth * 0.85,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.greenGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
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

  // Helper untuk membangun Card pilihan aktivitas
  Widget _buildAktivitasCard({
    required String label,
    required String description,
    required IconData icon,
    required Aktivitas value,
    required double screenWidth,
  }) {
    return SizedBox(
      width: screenWidth * 0.85,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAktivitas = value;
            _aktivitasErrorMessage = null; // Hapus error saat memilih
          });
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
            side: _selectedAktivitas == value && _aktivitasErrorMessage != null
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
          ),
          color: _selectedAktivitas == value
              ? const Color(0xFFF1F0E9)
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: _selectedAktivitas == value
                          ? AppColors.primary
                          : AppColors.darkGrey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _selectedAktivitas == value
                              ? AppColors.primary
                              : AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: _selectedAktivitas == value
                        ? AppColors.darkGrey
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
