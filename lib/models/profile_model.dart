// lib/models/profile_model.dart

import 'dart:typed_data';
import 'package:vitacal_app/models/enums.dart'; // Diperlukan untuk Enums
import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/userdetail_model.dart'; // Import UserDetailModel
import 'package:vitacal_app/models/bmi_model.dart'; // Import BmiDataModel
import 'package:vitacal_app/models/profile_kalori_model.dart'; // <<< PENTING: Import ProfileKaloriModel

class ProfileModel extends Equatable {
  // Properti dari objek 'user' utama di respons API
  final int userId;
  final String username;
  final String email;
  final String phone;
  final bool verified;
  final String userCreatedAt;
  final String userUpdatedAt;

  // Referensi ke UserDetailModel
  final UserDetailModel? userDetail;

  // Objek KaloriModel untuk halaman Home. Objek ini bisa nullable.
  // Pastikan ini adalah KaloriModel yang sesuai dengan respons '/hitung-kalori'
  // dan di-parse di tempat yang tepat (misalnya di HomeBloc).
  // Di ProfileModel, kita akan gunakan ProfileKaloriModel.
  // Jika `rekomendasiKalori` di sini adalah untuk toJson yang sesuai dengan `/hitung-kalori`,
  // maka ia harus di-handle dengan bijak. Untuk parsing dari `/profile`, kita pakai ProfileKaloriModel.
  // Untuk menghindari kebingungan, saya akan ganti nama properti di ProfileModel ini.
  final ProfileKaloriModel?
      profileRekomendasiKalori; // <<< GANTI NAMA PROPERTI INI

  final BmiDataModel? bmiData;

  const ProfileModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.verified,
    required this.userCreatedAt,
    required this.userUpdatedAt,
    this.userDetail,
    this.profileRekomendasiKalori, // <<< GANTI NAMA DI KONSTRUKTOR
    this.bmiData,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // --- TAMBAHKAN DEBUGGING DI SINI ---
    print('DEBUG ProfileModel.fromJson: Full JSON received: $json');
    // --- END DEBUGGING ---

    final Map<String, dynamic>? userJson =
        json['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const FormatException(
          'Respons API tidak memiliki kunci "user" atau nilainya null.');
    }

    // --- TAMBAHKAN DEBUGGING DI SINI ---
    print('DEBUG ProfileModel.fromJson: userJson: $userJson');
    // --- END DEBUGGING ---

    // Pastikan user_detail ada di dalam userJson, bukan di level root
    final Map<String, dynamic>? userDetailJson =
        userJson['user_detail'] as Map<String, dynamic>?;

    UserDetailModel? parsedUserDetail;
    if (userDetailJson != null) {
      // --- TAMBAHKAN DEBUGGING DI SINI ---
      print('DEBUG ProfileModel.fromJson: userDetailJson: $userDetailJson');
      // --- END DEBUGGING ---
      try {
        parsedUserDetail = UserDetailModel.fromJson(userDetailJson);
      } catch (e) {
        print('ERROR parsing user_detail to UserDetailModel: $e');
      }
    } else {
      print(
          'INFO ProfileModel.fromJson: user_detail is null or missing from userJson.');
    }

    // Parsing ProfileKaloriModel jika ada (dari endpoint /profile)
    ProfileKaloriModel? parsedProfileRekomendasiKalori;
    if (userDetailJson?['rekomendasi_kalori'] != null &&
        userDetailJson?['rekomendasi_kalori'] is Map<String, dynamic>) {
      // --- TAMBAHKAN DEBUGGING DI SINI ---
      print(
          'DEBUG ProfileModel.fromJson: rekomendasi_kalori JSON: ${userDetailJson!['rekomendasi_kalori']}');
      // --- END DEBUGGING ---
      try {
        parsedProfileRekomendasiKalori = ProfileKaloriModel.fromJson(
            Map<String, dynamic>.from(userDetailJson['rekomendasi_kalori']));
      } catch (e) {
        print('ERROR parsing rekomendasi_kalori to ProfileKaloriModel: $e');
      }
    } else {
      print(
          'INFO ProfileModel.fromJson: rekomendasi_kalori is null or missing from userDetailJson.');
    }

    // Parsing BmiDataModel jika ada
    BmiDataModel? parsedBmiData;
    if (userDetailJson?['bmi_data'] != null &&
        userDetailJson?['bmi_data'] is Map<String, dynamic>) {
      // --- TAMBAHKAN DEBUGGING DI SINI ---
      print(
          'DEBUG ProfileModel.fromJson: bmi_data JSON: ${userDetailJson!['bmi_data']}');
      // --- END DEBUGGING ---
      try {
        parsedBmiData = BmiDataModel.fromJson(
            Map<String, dynamic>.from(userDetailJson['bmi_data']));
      } catch (e) {
        print('ERROR parsing bmi_data to BmiDataModel: $e');
      }
    } else {
      print(
          'INFO ProfileModel.fromJson: bmi_data is null or missing from userDetailJson.');
    }

    return ProfileModel(
      userId: userJson['user_id'] as int,
      username: userJson['username'] as String,
      email: userJson['email'] as String,
      phone: userJson['phone'] as String,
      verified: userJson['verified'] as bool? ?? false,
      userCreatedAt: userJson['created_at'] as String,
      userUpdatedAt: userJson['updated_at'] as String,
      userDetail: parsedUserDetail,
      profileRekomendasiKalori: parsedProfileRekomendasiKalori,
      bmiData: parsedBmiData,
    );
  }
  // Getter untuk akses mudah ke data dari UserDetailModel
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
        profileRekomendasiKalori, // <<< GANTI NAMA
        bmiData,
      ];

  // copyWith dan toJson perlu disesuaikan untuk mencerminkan perubahan ini
  ProfileModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? phone,
    bool? verified,
    String? userCreatedAt,
    String? userUpdatedAt,
    UserDetailModel? userDetail,
    ProfileKaloriModel? profileRekomendasiKalori, // <<< GANTI NAMA
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
      profileRekomendasiKalori: profileRekomendasiKalori ??
          this.profileRekomendasiKalori, // <<< GANTI NAMA
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
      'created_at': userCreatedAt,
      'updated_at': userUpdatedAt,
      'user_detail': userDetail?.toJson(),
      'rekomendasi_kalori': profileRekomendasiKalori
          ?.toJson(), // <<< GANTI NAMA, Kirim sebagai objek terpisah
      'bmi_data': bmiData?.toJson(),
    };
  }
}
