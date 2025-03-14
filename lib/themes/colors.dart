import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFFD7A86E);
  static const Color cream = Color(0xFFF5E6CA);
  static const Color screen = Color(0xFFFAFAFA);
  static const Color darkGrey = Color(0xFF4E4E4E);
  static const Color putih = Color(0xFFF4F6FF);

  // Gradient hijau dengan titik perubahan menggunakan persentase
  static const LinearGradient greenGradient = LinearGradient(
    colors: [
      Color(0xFF2E7D32), // Hijau tua (atas)
      Color(0xFF66A15A), // Hijau muda (bawah)
    ],
    stops: [0.33, 1.0], // Menggunakan persentase untuk mengubah warna
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
