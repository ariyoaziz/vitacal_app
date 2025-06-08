// lib/models/user_detail.dart

import 'dart:convert'; // Untuk base64Decode
import 'dart:typed_data'; // Untuk Uint8List
import 'package:vitacal_app/models/enums.dart';

// Penting: Pastikan file ini TIDAK memiliki import 'package:flutter/material.dart'
// atau 'package:flutter/widgets.dart'

class UserDetailModel {
  // <--- Nama kelas diubah kembali menjadi UserDetailModel
  final int userdetailId;
  final int userId;
  final String nama;
  final String? fotoProfilBase64; // String Base64 dari foto profil
  final int umur;
  final JenisKelamin jenisKelamin;
  final double beratBadan;
  final double tinggiBadan;
  final Aktivitas aktivitas;
  final Tujuan? tujuan; // Nullable
  final String updatedAt;

  UserDetailModel({
    // <--- Nama konstruktor diubah kembali menjadi UserDetailModel
    required this.userdetailId,
    required this.userId,
    required this.nama,
    this.fotoProfilBase64,
    required this.umur,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.aktivitas,
    this.tujuan,
    required this.updatedAt,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    // <--- Nama factory diubah kembali
    return UserDetailModel(
      // <--- Nama objek yang dibuat diubah kembali
      userdetailId: json['userdetail_id'] as int,
      userId: json['user_id'] as int,
      nama: json['nama'] as String,
      fotoProfilBase64: json['foto_profil'] as String?,
      umur: json['umur'] as int,
      jenisKelamin: _parseJenisKelamin(json['jenis_kelamin'] as String),
      beratBadan: (json['berat_badan'] as num).toDouble(),
      tinggiBadan: (json['tinggi_badan'] as num).toDouble(),
      aktivitas: _parseAktivitas(json['aktivitas'] as String),
      tujuan: json['tujuan'] != null
          ? _parseTujuan(json['tujuan'] as String)
          : null,
      updatedAt: json['updated_at'] as String,
    );
  }

  // Helper untuk parsing Enum dari string API
  static JenisKelamin _parseJenisKelamin(String value) {
    if (value == "Laki-laki") {
      return JenisKelamin.lakiLaki;
    }
    if (value == "Perempuan") {
      return JenisKelamin.perempuan;
    }
    throw FormatException('Jenis Kelamin tidak valid: $value');
  }

  static Aktivitas _parseAktivitas(String value) {
    if (value == "Tidak Aktif") {
      return Aktivitas.tidakAktif;
    }
    if (value == "Ringan") {
      return Aktivitas.ringan;
    }
    if (value == "Sedang") {
      return Aktivitas.sedang;
    }
    if (value == "Berat") {
      return Aktivitas.berat;
    }
    if (value == "Sangat Berat") {
      return Aktivitas.sangatBerat;
    }
    throw FormatException('Aktivitas tidak valid: $value');
  }

  static Tujuan _parseTujuan(String value) {
    if (value == "Menurunkan Berat Badan") {
      return Tujuan.menurunkanBeratBadan;
    }
    if (value == "Menambah Berat Badan") {
      return Tujuan.menambahBeratBadan;
    }
    if (value == "Menjaga Berat Badan Ideal") {
      return Tujuan.menjagaBeratBadanIdeal;
    }
    if (value == "Menaikan Massa Tubuh") {
      return Tujuan.menaikanMassaTubuh;
    }
    throw FormatException('Tujuan tidak valid: $value');
  }

  // Fungsi untuk konversi Base64 string ke Uint8List (bytes)
  Uint8List? get profileImageBytes {
    if (fotoProfilBase64 == null) return null;
    try {
      final bytes = base64Decode(fotoProfilBase64!);
      return bytes;
    } catch (e) {
      print('Error decoding base64 image to bytes: $e');
      return null;
    }
  }

  get targetBeratBadan => null;
}
