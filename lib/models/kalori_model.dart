// lib/models/kalori_model.dart

class KaloriModel {
  final double bmi;
  final String statusBmi;
  final double bmr;
  final double tdee;
  final String tujuan;
  final String rekomendasiKalori;
  final String statusDatabase;

  KaloriModel({
    required this.bmi,
    required this.statusBmi,
    required this.bmr,
    required this.tdee,
    required this.tujuan,
    required this.rekomendasiKalori,
    required this.statusDatabase,
  });

  factory KaloriModel.fromJson(Map<String, dynamic> json) {
    return KaloriModel(
      bmi: json['BMI']?.toDouble() ?? 0.0, // Tangani null atau tipe berbeda
      statusBmi: json['status_bmi'] as String? ?? '',
      bmr: json['BMR']?.toDouble() ?? 0.0,
      tdee: json['TDEE']?.toDouble() ?? 0.0,
      tujuan: json['tujuan'] as String? ?? '',
      rekomendasiKalori: json['rekomendasi_kalori'] as String? ?? '',
      statusDatabase: json['status_database'] as String? ?? '',
    );
  }

  // Helper untuk mengekstrak hanya bagian angka dari rekomendasi kalori
  int get numericRekomendasiKalori {
    final match = RegExp(r'(\d+)').firstMatch(rekomendasiKalori);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }
}
