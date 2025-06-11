import 'package:equatable/equatable.dart'; // Import Equatable

class KaloriModel extends Equatable {
  // Ditambahkan: extends Equatable
  final double bmi;
  final String statusBmi;
  final double bmr;
  final double tdee;
  final String tujuan;
  final String rekomendasiKalori;
  final String statusDatabase;

  // ignore: prefer_const_constructors_in_immutables
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
    // PERBAIKAN: Gunakan double.tryParse untuk penanganan angka dari string yang lebih aman
    return KaloriModel(
      bmi: (json['BMI'] != null)
          ? double.tryParse(json['BMI'].toString()) ?? 0.0
          : 0.0,
      statusBmi: json['status_bmi'] as String? ?? '',
      bmr: (json['BMR'] != null)
          ? double.tryParse(json['BMR'].toString()) ?? 0.0
          : 0.0,
      tdee: (json['TDEE'] != null)
          ? double.tryParse(json['TDEE'].toString()) ?? 0.0
          : 0.0,
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

  // --- BARU: Tambahkan metode toJson() ---
  Map<String, dynamic> toJson() {
    return {
      'BMI': bmi,
      'status_bmi': statusBmi,
      'BMR': bmr,
      'TDEE': tdee,
      'tujuan': tujuan,
      'rekomendasi_kalori': rekomendasiKalori,
      'status_database': statusDatabase,
    };
  }
  // --- AKHIR BARU ---

  @override
  List<Object?> get props => [
        // Ditambahkan: props untuk Equatable
        bmi,
        statusBmi,
        bmr,
        tdee,
        tujuan,
        rekomendasiKalori,
        statusDatabase,
      ];
}
