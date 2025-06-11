// lib/models/bmi_model.dart
import 'package:equatable/equatable.dart';

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
      bmiValue: double.tryParse(json['bmi_value'].toString()) ??
          0.0, // Parse dari String ke double
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bmi_id': bmiId,
      'bmi_value': bmiValue
          .toString(), // Kembali ke String jika diperlukan untuk dikirim
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        bmiId,
        bmiValue,
        status,
        createdAt,
        updatedAt,
      ];
}
