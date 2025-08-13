// ignore_for_file: override_on_non_overriding_member, no_leading_underscores_for_local_identifiers, unnecessary_this

import 'dart:convert';
import 'dart:typed_data';
import 'package:vitacal_app/models/enums.dart'; // Pastikan ini diimpor
import 'package:equatable/equatable.dart'; // Pastikan Equatable diimpor

/// Data model untuk detail pengguna, termasuk informasi pribadi dan metrik kesehatan.
class UserDetailModel extends Equatable {
  final int userdetailId;
  final int userId;
  final String nama;
  final String? fotoProfilBase64; // Base64 string dari foto profil (nullable)
  final int? umur; // Nullable
  final JenisKelamin
      jenisKelamin; // Non-nullable, karena memiliki fallback di parser
  final double? beratBadan; // Nullable
  final double? tinggiBadan; // Nullable
  final Aktivitas aktivitas; // Non-nullable, karena memiliki fallback di parser
  final Tujuan? tujuan; // Nullable
  final double? targetBeratBadan; // Nullable
  final DateTime createdAt; // Non-nullable, diasumsikan selalu ada dan valid
  final DateTime updatedAt; // Non-nullable, dengan fallback jika null/invalid

  /// Konstruktor konstan untuk [UserDetailModel].
  const UserDetailModel({
    required this.userdetailId,
    required this.userId,
    required this.nama,
    this.fotoProfilBase64,
    this.umur, // Hapus 'required' karena sudah int?
    required this.jenisKelamin,
    this.beratBadan, // Hapus 'required' karena sudah double?
    this.tinggiBadan, // Hapus 'required' karena sudah double?
    required this.aktivitas,
    this.tujuan,
    this.targetBeratBadan,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor untuk membuat instance [UserDetailModel] dari JSON Map.
  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    // print('DEBUG: Full JSON received by UserDetailModel.fromJson: $json'); // Tetap aktif jika masih butuh debugging

    // Helper function untuk parsing DateTime yang aman
    DateTime? _tryParseDateTime(dynamic value, String fieldName) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String);
      } catch (e) {
        print('Error parsing $fieldName: "$value" to DateTime: $e');
        return null;
      }
    }

    return UserDetailModel(
      userdetailId: json['userdetail_id'] as int,
      userId: json['user_id'] as int,
      nama: json['nama'] as String,
      // Pastikan 'foto_profil_base64' adalah string, jika tidak null
      fotoProfilBase64: json['foto_profil_base64'] is String
          ? json['foto_profil_base64'] as String
          : null,
      umur: json['umur'] as int?, // Casting aman ke int?
      // Parsing Enum dengan helper, yang memiliki fallback jika string tidak valid
      jenisKelamin: _parseJenisKelamin(json['jenis_kelamin'] as String),
      // Parsing numerik dengan num? dan toDouble()
      beratBadan: (json['berat_badan'] as num?)?.toDouble(),
      tinggiBadan: (json['tinggi_badan'] as num?)?.toDouble(),
      // Parsing Enum dengan helper
      aktivitas: _parseAktivitas(json['aktivitas'] as String),
      // Parsing Tujuan Enum (nullable)
      tujuan: json['tujuan'] != null
          ? _parseTujuan(json['tujuan'] as String)
          : null,
      targetBeratBadan: (json['target_berat_badan'] as num?)?.toDouble(),
      // Parsing DateTime (createdAt diasumsikan non-nullable dari API)
      createdAt: _tryParseDateTime(json['created_at'], 'created_at')!,
      // Parsing DateTime (updatedAt dengan fallback jika null/invalid)
      updatedAt:
          _tryParseDateTime(json['updated_at'], 'updated_at') ?? DateTime.now(),
    );
  }

  /// Helper untuk mengonversi string API JenisKelamin ke Enum.
  static JenisKelamin _parseJenisKelamin(String value) {
    final cleanedValue = value.toLowerCase().replaceAll(' ', '_');
    switch (cleanedValue) {
      case "laki-laki":
      case "laki_laki":
        return JenisKelamin.lakiLaki;
      case "perempuan":
        return JenisKelamin.perempuan;
      default:
        // Log error dan berikan fallback yang masuk akal
        print(
            'Error: Invalid Jenis Kelamin API string: "$value". Returning default (lakiLaki).');
        return JenisKelamin.lakiLaki;
    }
  }

  static Aktivitas _parseAktivitas(String value) {
    final cleanedValue = value.toLowerCase().replaceAll(' ', '_');
    switch (cleanedValue) {
      case "tidak_aktif":
        return Aktivitas.tidakAktif;
      case "ringan":
        return Aktivitas.ringan;
      case "sedang":
        return Aktivitas.sedang;
      case "berat":
        return Aktivitas.berat;
      case "sangat_berat":
        return Aktivitas.sangatBerat;
      default:
        print(
            'Error: Invalid Aktivitas API string: "$value" (cleaned: "$cleanedValue"). Returning default (tidakAktif).');
        return Aktivitas.tidakAktif;
    }
  }

  // Map pre-defined untuk parsing Tujuan yang efisien
  static final Map<String, Tujuan> _tujuanMap = {
    "menurunkan_berat_badan": Tujuan.menurunkanBeratBadan,
    "menambah_berat_badan": Tujuan.menambahBeratBadan,
    "menjaga_berat_badan_ideal": Tujuan.menjagaBeratBadanIdeal,
    "menaikan_massa_tubuh": Tujuan.menaikanMassaTubuh,
  };

  /// Helper untuk mengonversi string API Tujuan ke Enum.
  static Tujuan _parseTujuan(String value) {
    final cleanedValue = value.toLowerCase().trim().replaceAll(' ', '_');
    // print('DEBUG: Parsing Tujuan. Cleaned value: "$cleanedValue" (Original: "$value")'); // Debugging, bisa dihapus

    final parsedTujuan = _tujuanMap[cleanedValue];
    if (parsedTujuan != null) {
      return parsedTujuan;
    } else {
      print(
          'Error: Invalid Tujuan API string: "$value" (cleaned: "$cleanedValue"). Returning default (menjagaBeratBadanIdeal).');
      return Tujuan.menjagaBeratBadanIdeal;
    }
  }

  /// Getter untuk mengonversi string Base64 foto profil ke Uint8List (bytes).
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

  /// Membuat salinan objek [UserDetailModel] dengan properti yang diperbarui.
  UserDetailModel copyWith({
    int? userdetailId,
    int? userId,
    String? nama,
    String? fotoProfilBase64,
    int? umur,
    JenisKelamin? jenisKelamin,
    double? beratBadan,
    double? tinggiBadan,
    Aktivitas? aktivitas,
    Tujuan? tujuan,
    double? targetBeratBadan,
    DateTime? updatedAt,
  }) {
    return UserDetailModel(
      userdetailId: userdetailId ?? this.userdetailId,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      fotoProfilBase64: fotoProfilBase64 ?? this.fotoProfilBase64,
      umur: umur ?? this.umur,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      aktivitas: aktivitas ?? this.aktivitas,
      tujuan: tujuan ?? this.tujuan,
      targetBeratBadan: targetBeratBadan ?? this.targetBeratBadan,
      createdAt: this.createdAt, // createdAt biasanya tidak berubah
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userdetail_id': userdetailId,
      'user_id': userId,
      'nama': nama,
      'foto_profil': fotoProfilBase64, // Kirim Base64 string ke API
      'umur': umur,
      'jenis_kelamin': jenisKelamin.toApiString(),
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'aktivitas': aktivitas.toApiString(),
      'tujuan': tujuan?.toApiString(), // Safely convert nullable enum to string
      'target_berat_badan': targetBeratBadan,
      'created_at':
          createdAt.toIso8601String(), // Convert DateTime ke string ISO
      'updated_at':
          updatedAt.toIso8601String(), // Convert DateTime ke string ISO
    };
  }

  @override
  List<Object?> get props => [
        userdetailId,
        userId,
        nama,
        fotoProfilBase64,
        umur,
        jenisKelamin,
        beratBadan,
        tinggiBadan,
        aktivitas,
        tujuan,
        targetBeratBadan,
        createdAt,
        updatedAt,
      ];
}
