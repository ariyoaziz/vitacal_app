import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';
// PERBAIKAN: Menggunakan import yang benar untuk file dialog yang sudah digabungkan
import 'package:vitacal_app/screen/analytics/showdialog_berat.dart'; // <<< PASTIKAN PATH INI BENAR >>>

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

    // PERBAIKAN: Inisialisasi unit, minValue, dan maxValue berdasarkan label
    if (label == "Berat Sekarang" || label == "Tujuan Berat") {
      unit = "kg";
      // PERBAIKAN minValue: Mengubah dari 30.0 ke 10.0
      // Ini akan memungkinkan nilai seperti 24.9 untuk valid
      minValue =
          10.0; // Contoh nilai minimum yang lebih fleksibel untuk berat badan
      maxValue = 200.0; // Contoh nilai maksimum untuk berat badan
    } else if (label == "Tinggi Badan") {
      unit = "cm";
      minValue = 50.0; // Contoh nilai minimum untuk tinggi badan
      maxValue = 250.0; // Contoh nilai maksimum untuk tinggi badan
    } else {
      // Default jika label tidak cocok (seharusnya tidak terjadi jika pemanggilan sudah tepat)
      unit = "";
      minValue = 0.0;
      maxValue = 100.0;
    }

    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      elevation: 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(icon, height: 14),
                    const SizedBox(width: 11),
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 21),
                Text(
                  // Menggunakan .toStringAsFixed(1) untuk menampilkan satu angka desimal
                  // sesuai dengan presisi picker dan kebutuhan.
                  "${value.toStringAsFixed(1)} $unit", // Menambahkan unit langsung di sini
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Memanggil fungsi dialog showUpdateValueDialog yang sudah digabungkan
                showUpdateValueDialog(
                  context: context,
                  title: label,
                  onSave: (newValue) {
                    onUpdate(
                        newValue); // Meneruskan nilai yang disimpan kembali
                  },
                  initialValue: value,
                  minValue:
                      minValue, // Meneruskan minValue yang sudah disesuaikan
                  maxValue:
                      maxValue, // Meneruskan maxValue yang sudah disesuaikan
                  unit: unit,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(21)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
              ),
              child: const Text(
                "Perbaharui",
                style: TextStyle(
                    color: AppColors.screen, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
