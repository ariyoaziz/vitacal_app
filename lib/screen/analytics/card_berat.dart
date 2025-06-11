import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';
// PASTIKAN PATH INI BENAR untuk dialog kustom Anda
import 'package:vitacal_app/screen/analytics/showdialog_berat.dart';

class BeratCard extends StatelessWidget {
  final String label;
  final String icon;
  final double value;
  final void Function(double) onUpdate;

  const BeratCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    String unit;
    double minValue;
    double maxValue;

    // Inisialisasi unit, minValue, dan maxValue berdasarkan label
    if (label == "Berat Sekarang" || label == "Tujuan Berat") {
      unit = "kg";
      minValue =
          10.0; // Contoh nilai minimum yang lebih fleksibel untuk berat badan
      maxValue = 200.0; // Contoh nilai maksimum untuk berat badan
    } else if (label == "Tinggi Badan") {
      unit = "cm";
      minValue = 50.0; // Contoh nilai minimum untuk tinggi badan
      maxValue = 250.0; // Contoh nilai maksimum untuk tinggi badan
    } else {
      // Default jika label tidak cocok
      unit = "";
      minValue = 0.0;
      maxValue = 100.0;
    }

    return Card(
      color: AppColors.screen,
      // Bentuk kartu yang lebih modern dengan radius 24 dan elevation 2
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2, // Menaikkan elevation untuk kesan kedalaman
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(
                20), // Padding yang lebih besar untuk konten
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ukuran ikon ditingkatkan agar lebih terlihat
                    SvgPicture.asset(icon, height: 24),
                    const SizedBox(width: 11),
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 16, // Ukuran font label disesuaikan
                          fontWeight: FontWeight.w600, // Sedikit lebih tebal
                          color: AppColors.darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Spasi setelah label/ikon
                Text(
                  // Menggunakan .toStringAsFixed(1) untuk menampilkan satu angka desimal
                  "${value.toStringAsFixed(1)} $unit",
                  style: const TextStyle(
                      fontSize: 28, // Ukuran font nilai lebih besar
                      fontWeight: FontWeight.w700, // Sangat tebal
                      color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
          // Spasi sebelum tombol, disesuaikan agar rapi dengan padding atas
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, // Memastikan tombol memenuhi lebar card
            child: ElevatedButton(
              onPressed: () {
                // Memanggil fungsi dialog showUpdateValueDialog
                showUpdateValueDialog(
                  context: context,
                  title: label,
                  onSave: (newValue) {
                    onUpdate(newValue); // Meneruskan nilai yang disimpan
                  },
                  initialValue: value,
                  minValue: minValue,
                  maxValue: maxValue,
                  unit: unit,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.screen, // Warna teks tombol
                // Bentuk tombol agar menyatu dengan radius bawah kartu
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24)), // Radius sesuai kartu
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 18), // Padding vertikal tombol lebih besar
                elevation:
                    0, // Menghilangkan elevation default tombol jika sudah ada shadow di parent
              ),
              child: const Text(
                "Perbaharui",
                style: TextStyle(
                    color: AppColors.screen,
                    fontWeight: FontWeight.w600,
                    fontSize: 16), // Ukuran font tombol
              ),
            ),
          ),
        ],
      ),
    );
  }
}
