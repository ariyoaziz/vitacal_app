import 'package:equatable/equatable.dart';

/// Model untuk data BMI (Body Mass Index).
class BmiDataModel extends Equatable {
  final int bmiId;
  final double bmiValue;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const BmiDataModel({
    required this.bmiId,
    required this.bmiValue,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BmiDataModel.fromJson(Map<String, dynamic> json) {
    return BmiDataModel(
      bmiId: json['bmi_id'] as int,
      // Penting: Parsing bmi_value yang mungkin string atau float dari API
      bmiValue: (json['bmi_value'] is String)
          ? double.tryParse(json['bmi_value']) ?? 0.0
          : (json['bmi_value'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bmi_id': bmiId,
      'bmi_value': bmiValue,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [bmiId, bmiValue, status, createdAt, updatedAt];
}
