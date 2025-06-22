// lib/models/kalori_model.dart

import 'package:equatable/equatable.dart';

class KaloriModel extends Equatable {
  final double bmi;
  final double bmr;
  final double tdee;
  final String rekomendasiKaloriText;
  final String statusBmi;
  final String statusDatabase;
  final String tujuanText;
  final String aktivitasText; // <<< TAMBAHKAN PROPERTI INI

  const KaloriModel({
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.rekomendasiKaloriText,
    required this.statusBmi,
    required this.statusDatabase,
    required this.tujuanText,
    required this.aktivitasText, // <<< TAMBAHKAN KE KONSTRUKTOR
  });

  factory KaloriModel.fromJson(Map<String, dynamic> json) {
    return KaloriModel(
      bmi: (json['BMI'] as num?)?.toDouble() ?? 0.0,
      bmr: (json['BMR'] as num?)?.toDouble() ?? 0.0,
      tdee: (json['TDEE'] as num?)?.toDouble() ?? 0.0,
      rekomendasiKaloriText: json['rekomendasi_kalori'] as String? ?? '',
      statusBmi: json['status_bmi'] as String? ?? '',
      statusDatabase: json['status_database'] as String? ?? '',
      tujuanText: json['tujuan'] as String? ?? '',
      aktivitasText:
          json['aktivitas'] as String? ?? '', // <<< PARSING AKTIVITAS
    );
  }

  int get numericRekomendasiKalori {
    final match = RegExp(r'(\d+)').firstMatch(rekomendasiKaloriText);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  // Helper untuk membersihkan dan menampilkan string tujuan (jika diperlukan)
  String get cleanedTujuan {
    if (tujuanText.isEmpty) return 'Tidak ditetapkan';
    return tujuanText
        .replaceAll('Tujuan Anda adalah ', '')
        .replaceAll('_', ' ')
        .trim();
  }

  // Helper untuk membersihkan dan menampilkan string aktivitas (jika diperlukan)
  String get cleanedAktivitas {
    // <<< TAMBAHKAN HELPER INI
    if (aktivitasText.isEmpty) return 'Tidak ditetapkan';
    return aktivitasText.replaceAll('_', ' ').trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'BMI': bmi,
      'BMR': bmr,
      'TDEE': tdee,
      'rekomendasi_kalori': rekomendasiKaloriText,
      'status_bmi': statusBmi,
      'status_database': statusDatabase,
      'tujuan': tujuanText,
      'aktivitas': aktivitasText, // <<< TAMBAHKAN KE TOJSON
    };
  }

  @override
  List<Object?> get props => [
        bmi,
        bmr,
        tdee,
        rekomendasiKaloriText,
        statusBmi,
        statusDatabase,
        tujuanText,
        aktivitasText, // <<< TAMBAHKAN KE PROPS
      ];
}
