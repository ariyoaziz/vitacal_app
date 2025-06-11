import 'package:flutter/material.dart';

class AppColors {
  // Warna Primer dan Sekunder (Warna Utama Aplikasi)
  static const Color primary = Color(0xFF2E7D32); // Hijau Tua
  static const Color secondary = Color(0xFFD7A86E); // Cream/Coklat Muda (Aksen)

  // Varian Warna Primer (untuk efek hover/selected/background halus)
  static const Color lightPrimary = Color(
      0xFFE8F5E9); // Hijau Sangat Muda/Hampir Putih (Contoh: untuk latar belakang item yang dipilih)
  static const Color darkPrimary = Color(
      0xFF1B5E20); // Hijau Lebih Tua (opsional, jika butuh darker shade dari primary)

  // Warna Netral (Untuk Background, Teks, dll.)
  static const Color cream =
      Color(0xFFF5E6CA); // Warna krem yang lebih spesifik
  static const Color screen =
      Color(0xFFFAFAFA); // Warna latar belakang layar (putih keabu-abuan)
  static const Color darkGrey =
      Color(0xFF4E4E4E); // Abu-abu gelap untuk teks utama
  static const Color mediumGrey =
      Color(0xFF8B8B8B); // Abu-abu menengah (bisa untuk hint text, subtitle)
  static const Color lightGrey = Color(
      0xFFE0E0E0); // Abu-abu terang (bisa untuk border, divider, atau background ringan)
  static const Color white =
      Color(0xFFFFFFFF); // Warna putih murni (pengganti putih)

  // Warna Lain-lain (sesuai kebutuhan Anda)
  static const Color infoBlue = Color(0xFF2196F3); // Biru untuk informasi/link
  static const Color successGreen =
      Color(0xFF4CAF50); // Hijau untuk pesan sukses
  static const Color warningOrange =
      Color(0xFFFF9800); // Oranye untuk peringatan
  static const Color errorRed = Color(0xFFF44336); // Merah untuk error

  // Gradient hijau dengan titik perubahan menggunakan persentase
  static const LinearGradient greenGradient = LinearGradient(
    colors: [
      Color(0xFF2E7D32), // Hijau tua (atas) - Sama dengan primary
      Color(
          0xFF66A15A), // Hijau muda (bawah) - Sama dengan lightgreen jika ingin konsisten, atau biarkan ini
    ],
    stops: [0.33, 1.0], // Menggunakan persentase untuk mengubah warna
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
