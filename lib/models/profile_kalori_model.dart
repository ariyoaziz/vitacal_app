// lib/models/profile_kalori_model.dart
import 'package:equatable/equatable.dart';

class ProfileKaloriModel extends Equatable {
  final int rekomendasiKaloriId; // 'rekomendasi_kalori_id' dari /profile
  final double bmr; // 'bmr' dari /profile
  final double tdee; // 'tdee' dari /profile
  final double rekomendasiKal; // 'rekomendasi_kal' dari /profile (double)
  final String? createdAt;
  final String? updatedAt;

  const ProfileKaloriModel({
    required this.rekomendasiKaloriId,
    required this.bmr,
    required this.tdee,
    required this.rekomendasiKal,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileKaloriModel.fromJson(Map<String, dynamic> json) {
    return ProfileKaloriModel(
      rekomendasiKaloriId: (json['rekomendasi_kalori_id'] as int?) ?? 0,
      bmr: (json['bmr'] as num?)?.toDouble() ?? 0.0,
      tdee: (json['tdee'] as num?)?.toDouble() ?? 0.0,
      rekomendasiKal: (json['rekomendasi_kal'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  int get numericRekomendasiKalori {
    return rekomendasiKal.toInt();
  }

  Map<String, dynamic> toJson() {
    return {
      'rekomendasi_kalori_id': rekomendasiKaloriId,
      'bmr': bmr,
      'tdee': tdee,
      'rekomendasi_kal': rekomendasiKal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        rekomendasiKaloriId,
        bmr,
        tdee,
        rekomendasiKal,
        createdAt,
        updatedAt,
      ];
}
