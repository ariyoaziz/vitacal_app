// lib/models/kalori_model.dart

// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/enums.dart'; // Make sure this is imported for Enums and Extensions

class KaloriModel extends Equatable {
  final double? bmiValue;
  final double? bmr;
  final double? tdee;
  final double? rekomendasiKaloriHarian;
  final String? statusBmi;
  final String? statusDatabaseBmi;
  final String? statusDatabaseRekomendasiKalori;

  // --- PERBAIKAN PENTING DI SINI ---
  // Ubah tipe data dari String? menjadi Tujuan? (Enum)
  final Tujuan? tujuanRekomendasiSistem;
  // --- AKHIR PERBAIKAN ---

  // Pastikan ini juga bertipe Enum? (sudah benar di iterasi sebelumnya)
  final Aktivitas? aktivitas;
  final JenisKelamin? jenisKelamin;

  final int? rekomendasikalId;
  final int? riwayatuserId;
  final int? userdetailIdTerkini;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Getter untuk mendapatkan nilai numerik Rekomendasi Kalori (aman)
  int get numericRekomendasiKalori {
    return rekomendasiKaloriHarian?.round() ?? 0;
  }

  const KaloriModel({
    this.bmiValue,
    this.bmr,
    this.tdee,
    this.rekomendasiKaloriHarian,
    this.statusBmi,
    this.statusDatabaseBmi,
    this.statusDatabaseRekomendasiKalori,
    this.tujuanRekomendasiSistem, // Sekarang bertipe Tujuan?
    this.aktivitas,
    this.jenisKelamin,
    this.rekomendasikalId,
    this.riwayatuserId,
    this.userdetailIdTerkini,
    this.createdAt,
    this.updatedAt,
  });

  factory KaloriModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG KaloriModel.fromJson received: $json');

    DateTime? _tryParseDateTime(dynamic value, String fieldName) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String);
      } catch (e) {
        print('Error parsing $fieldName: "$value" to DateTime: $e');
        return null;
      }
    }

    double? parsedRekomendasiKalori;
    if (json.containsKey('rekomendasi_kalori_harian')) {
      parsedRekomendasiKalori =
          (json['rekomendasi_kalori_harian'] as num?)?.toDouble();
    } else if (json.containsKey('rekomendasi_kal')) {
      parsedRekomendasiKalori = (json['rekomendasi_kal'] as num?)?.toDouble();
    }

    return KaloriModel(
      bmiValue: (json['bmi_value'] as num?)?.toDouble(),
      bmr: (json['bmr'] as num?)?.toDouble(),
      tdee: (json['tdee'] as num?)?.toDouble(),
      rekomendasiKaloriHarian: parsedRekomendasiKalori,
      statusBmi: json['status_bmi'] as String?,
      statusDatabaseBmi: json['status_database_bmi'] as String?,
      statusDatabaseRekomendasiKalori:
          json['status_database_rekomendasi_kalori'] as String?,
      tujuanRekomendasiSistem: json['tujuan_rekomendasi_sistem'] != null
          ? _parseTujuan(json['tujuan_rekomendasi_sistem'] as String)
          : null,
      aktivitas: json['aktivitas_display'] != null
          ? _parseAktivitas(json['aktivitas_display'] as String)
          : null,
      jenisKelamin: json['jenis_kelamin_display'] != null
          ? _parseJenisKelamin(json['jenis_kelamin_display'] as String)
          : null,
      rekomendasikalId: (json['rekomendasikal_id'] as int?),
      riwayatuserId: (json['riwayatuser_id'] as int?),
      userdetailIdTerkini: (json['userdetail_id_terkini'] as int?),
      createdAt: _tryParseDateTime(json['created_at'], 'created_at'),
      updatedAt: _tryParseDateTime(json['updated_at'], 'updated_at'),
    );
  }

  // --- Helper untuk parse Enum ---
  static JenisKelamin _parseJenisKelamin(String value) {
    final cleanedValue = value.toLowerCase().replaceAll(' ', '_');
    switch (cleanedValue) {
      case "laki-laki":
      case "laki_laki":
        return JenisKelamin.lakiLaki;
      case "perempuan":
        return JenisKelamin.perempuan;
      default:
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
        return Aktivitas.tidakAktif;
    }
  }

  static final Map<String, Tujuan> _tujuanMap = {
    "menurunkan_berat_badan": Tujuan.menurunkanBeratBadan,
    "menambah_berat_badan": Tujuan.menambahBeratBadan,
    "menjaga_berat_badan_ideal": Tujuan.menjagaBeratBadanIdeal,
    "menaikan_massa_tubuh": Tujuan.menaikanMassaTubuh,
  };

  static Tujuan _parseTujuan(String value) {
    final cleanedValue = value.toLowerCase().trim().replaceAll(' ', '_');
    print(
        'DEBUG: Parsing Tujuan. Cleaned value: "$cleanedValue" (Original: "$value")');

    final parsedTujuan = _tujuanMap[cleanedValue];
    if (parsedTujuan != null) {
      return parsedTujuan;
    } else {
      print(
          'Error: Invalid Tujuan API string: "$value" (cleaned: "$cleanedValue"). Returning default (menjagaBeratBadanIdeal).');
      return Tujuan.menjagaBeratBadanIdeal;
    }
  }

  @override
  List<Object?> get props => [
        bmiValue,
        bmr,
        tdee,
        rekomendasiKaloriHarian,
        statusBmi,
        statusDatabaseBmi,
        statusDatabaseRekomendasiKalori,
        tujuanRekomendasiSistem,
        aktivitas,
        jenisKelamin,
        rekomendasikalId,
        riwayatuserId,
        userdetailIdTerkini,
        createdAt,
        updatedAt,
      ];

  KaloriModel copyWith({
    double? bmiValue,
    double? bmr,
    double? tdee,
    double? rekomendasiKaloriHarian,
    String? statusBmi,
    String? statusDatabaseBmi,
    String? statusDatabaseRekomendasiKalori,
    Tujuan? tujuanRekomendasiSistem,
    Aktivitas? aktivitas,
    JenisKelamin? jenisKelamin,
    int? rekomendasikalId,
    int? riwayatuserId,
    int? userdetailIdTerkini,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KaloriModel(
      bmiValue: bmiValue ?? this.bmiValue,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      rekomendasiKaloriHarian:
          rekomendasiKaloriHarian ?? this.rekomendasiKaloriHarian,
      statusBmi: statusBmi ?? this.statusBmi,
      statusDatabaseBmi: statusDatabaseBmi ?? this.statusDatabaseBmi,
      statusDatabaseRekomendasiKalori: statusDatabaseRekomendasiKalori ??
          this.statusDatabaseRekomendasiKalori,
      tujuanRekomendasiSistem:
          tujuanRekomendasiSistem ?? this.tujuanRekomendasiSistem,
      aktivitas: aktivitas ?? this.aktivitas,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      rekomendasikalId: rekomendasikalId ?? this.rekomendasikalId,
      riwayatuserId: riwayatuserId ?? this.riwayatuserId,
      userdetailIdTerkini: userdetailIdTerkini ?? this.userdetailIdTerkini,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bmi_value': bmiValue,
      'bmr': bmr,
      'tdee': tdee,
      'rekomendasi_kalori_harian': rekomendasiKaloriHarian,
      'status_bmi': statusBmi,
      'status_database_bmi': statusDatabaseBmi,
      'status_database_rekomendasi_kalori': statusDatabaseRekomendasiKalori,
      // Saat kirim kembali ke API, kirim string API (snake_case)
      'tujuan_rekomendasi_sistem': tujuanRekomendasiSistem?.toApiString(),
      'aktivitas_display': aktivitas?.toApiString(),
      'jenis_kelamin_display': jenisKelamin?.toApiString(),
      'rekomendasikal_id': rekomendasikalId,
      'riwayatuser_id': riwayatuserId,
      'userdetail_id_terkini': userdetailIdTerkini,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
