// lib/models/profile_model.dart

import 'dart:typed_data';
import 'package:vitacal_app/models/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/models/bmi_model.dart';
import 'package:vitacal_app/models/kalori_model.dart'; // Import KaloriModel

class ProfileModel extends Equatable {
  final int userId;
  final String username;
  final String email;
  final String phone;
  final bool verified;
  final DateTime userCreatedAt; // <<< TETAPKAN INI DateTime
  final DateTime userUpdatedAt; // <<< TETAPKAN INI DateTime

  final UserDetailModel? userDetail;

  final KaloriModel? rekomendasiKaloriData;
  final BmiDataModel? bmiData;

  const ProfileModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.verified,
    required this.userCreatedAt, // <<< TETAPKAN INI DateTime
    required this.userUpdatedAt, // <<< TETAPKAN INI DateTime
    this.userDetail,
    this.rekomendasiKaloriData,
    this.bmiData,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG ProfileModel.fromJson: Full JSON received: $json');

    final Map<String, dynamic>? userJson =
        json['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const FormatException(
          'Respons API tidak memiliki kunci "user" atau nilainya null.');
    }
    print('DEBUG ProfileModel.fromJson: userJson: $userJson');

    final Map<String, dynamic>? userDetailJson =
        userJson['user_detail'] as Map<String, dynamic>?;
    UserDetailModel? parsedUserDetail;
    if (userDetailJson != null) {
      print('DEBUG ProfileModel.fromJson: userDetailJson: $userDetailJson');
      try {
        parsedUserDetail = UserDetailModel.fromJson(userDetailJson);
      } catch (e) {
        print('ERROR parsing user_detail to UserDetailModel: $e');
        // Jika parsing gagal, set ke null atau default jika UserDetailModel bisa null
        parsedUserDetail = null;
      }
    } else {
      print(
          'INFO ProfileModel.fromJson: user_detail is null or missing from userJson.');
    }

    KaloriModel? parsedRekomendasiKaloriData;
    if (json['rekomendasi_kalori_data'] != null &&
        json['rekomendasi_kalori_data'] is Map<String, dynamic>) {
      print(
          'DEBUG ProfileModel.fromJson: rekomendasi_kalori_data JSON: ${json['rekomendasi_kalori_data']}');
      try {
        parsedRekomendasiKaloriData = KaloriModel.fromJson(
            Map<String, dynamic>.from(json['rekomendasi_kalori_data']));
      } catch (e) {
        print('ERROR parsing rekomendasi_kalori_data to KaloriModel: $e');
        // Jika parsing gagal, set ke null
        parsedRekomendasiKaloriData = null;
      }
    } else {
      print(
          'INFO ProfileModel.fromJson: rekomendasi_kalori_data is null or missing from root JSON.');
    }

    BmiDataModel? parsedBmiData;
    if (json['bmi_data'] != null && json['bmi_data'] is Map<String, dynamic>) {
      print('DEBUG ProfileModel.fromJson: bmi_data JSON: ${json['bmi_data']}');
      try {
        parsedBmiData =
            BmiDataModel.fromJson(Map<String, dynamic>.from(json['bmi_data']));
      } catch (e) {
        print('ERROR parsing bmi_data to BmiDataModel: $e');
        // Jika parsing gagal, set ke null
        parsedBmiData = null;
      }
    } else {
      print(
          'INFO ProfileModel.fromJson: bmi_data is null or missing from root JSON.');
    }

    return ProfileModel(
      userId: userJson['user_id'] as int,
      username: userJson['username'] as String,
      email: userJson['email'] as String,
      phone: userJson['phone'] as String,
      verified: userJson['verified'] as bool? ?? false,
      // <<< PERBAIKAN: Parsing userCreatedAt dan userUpdatedAt lebih aman >>>
      userCreatedAt: (userJson['created_at'] is String)
          ? DateTime.parse(userJson['created_at'])
          : DateTime.now(), // Fallback jika bukan string atau null
      userUpdatedAt: (userJson['updated_at'] is String)
          ? DateTime.parse(userJson['updated_at'])
          : DateTime.now(), // Fallback
      // <<< AKHIR PERBAIKAN >>>
      userDetail: parsedUserDetail,
      rekomendasiKaloriData: parsedRekomendasiKaloriData,
      bmiData: parsedBmiData,
    );
  }

  String get nama => userDetail?.nama ?? 'Tidak Ada Nama';
  int get umur => userDetail?.umur ?? 0;
  JenisKelamin get jenisKelamin =>
      userDetail?.jenisKelamin ?? JenisKelamin.lakiLaki;
  double get beratBadan => userDetail?.beratBadan ?? 0.0;
  double get tinggiBadan => userDetail?.tinggiBadan ?? 0.0;
  Aktivitas get aktivitas => userDetail?.aktivitas ?? Aktivitas.tidakAktif;
  Tujuan? get tujuan => userDetail?.tujuan;
  double? get targetBeratBadan => userDetail?.targetBeratBadan;
  Uint8List? get profileImageBytes => userDetail?.profileImageBytes;

  @override
  List<Object?> get props => [
        userId,
        username,
        email,
        phone,
        verified,
        userCreatedAt,
        userUpdatedAt,
        userDetail,
        rekomendasiKaloriData,
        bmiData,
      ];

  ProfileModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? phone,
    bool? verified,
    DateTime? userCreatedAt,
    DateTime? userUpdatedAt,
    UserDetailModel? userDetail,
    KaloriModel? rekomendasiKaloriData,
    BmiDataModel? bmiData,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      verified: verified ?? this.verified,
      userCreatedAt: userCreatedAt ?? this.userCreatedAt,
      userUpdatedAt: userUpdatedAt ?? this.userUpdatedAt,
      userDetail: userDetail ?? this.userDetail,
      rekomendasiKaloriData:
          rekomendasiKaloriData ?? this.rekomendasiKaloriData,
      bmiData: bmiData ?? this.bmiData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'verified': verified,
      'created_at': userCreatedAt.toIso8601String(),
      'updated_at': userUpdatedAt.toIso8601String(),
      'user_detail': userDetail?.toJson(),
      'rekomendasi_kalori_data': rekomendasiKaloriData?.toJson(),
      'bmi_data': bmiData?.toJson(),
    };
  }
}
