// lib/models/user_detail_form_data.dart

import 'package:vitacal_app/models/enums.dart';

class UserDetailFormData {
  final int userId;
  String? nama;
  int? umur;
  DateTime? tanggalLahir;
  JenisKelamin? jenisKelamin;
  double? beratBadan;
  double? tinggiBadan; // Pastikan ini tinggiBadan
  Aktivitas? aktivitas;
  Tujuan? tujuan;

  UserDetailFormData({
    required this.userId,
    this.nama,
    this.umur,
    this.tanggalLahir,
    this.jenisKelamin,
    this.beratBadan,
    this.tinggiBadan,
    this.aktivitas,
    this.tujuan,
  });

  UserDetailFormData copyWith({
    String? nama,
    int? umur,
    DateTime? tanggalLahir,
    JenisKelamin? jenisKelamin,
    double? beratBadan,
    double? tinggiBadan, // Pastikan ini tinggiBadan
    Aktivitas? aktivitas,
    Tujuan? tujuan,
  }) {
    return UserDetailFormData(
      userId: userId,
      nama: nama ?? this.nama,
      umur: umur ?? this.umur,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan, // <--- PERBAIKAN DI SINI!
      aktivitas: aktivitas ?? this.aktivitas,
      tujuan: tujuan ?? this.tujuan,
    );
  }
}
