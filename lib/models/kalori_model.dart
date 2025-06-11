// lib/models/kalori_model.dart
import 'package:equatable/equatable.dart';

class KaloriModel extends Equatable {
  // Properti sesuai dengan respons dari endpoint '/hitung-kalori'
  final double bmi; // Dari "BMI"
  final double bmr; // Dari "BMR"
  final double tdee; // Dari "TDEE"
  final String rekomendasiKaloriText;
  final String statusBmi;
  final String statusDatabase;
  final String tujuanText;

  const KaloriModel({
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.rekomendasiKaloriText, // Perbaiki nama properti
    required this.statusBmi,
    required this.statusDatabase,
    required this.tujuanText, // Perbaiki nama properti
  });

  factory KaloriModel.fromJson(Map<String, dynamic> json) {
    return KaloriModel(
      bmi: (json['BMI'] as num?)?.toDouble() ?? 0.0,
      bmr: (json['BMR'] as num?)?.toDouble() ?? 0.0,
      tdee: (json['TDEE'] as num?)?.toDouble() ?? 0.0,
      rekomendasiKaloriText:
          json['rekomendasi_kalori'] as String? ?? '', // Parse sebagai String
      statusBmi: json['status_bmi'] as String? ?? '',
      statusDatabase: json['status_database'] as String? ?? '',
      tujuanText: json['tujuan'] as String? ?? '', // Parse sebagai String
    );
  }

  // Helper untuk mengekstrak hanya bagian angka dari rekomendasiKaloriText (String)
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
    // Menghapus "Tujuan Anda adalah " jika ada
    return tujuanText
        .replaceAll('Tujuan Anda adalah ', '')
        .replaceAll('_', ' ')
        .trim();
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
      ];
}
