import 'dart:convert';
import 'dart:typed_data';
import 'package:vitacal_app/models/enums.dart'; // Pastikan path ini benar
import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/kalori_model.dart'; // Pastikan path ini benar
import 'package:vitacal_app/models/bmi_model.dart'; // Pastikan path ini benar

/// Model data lengkap untuk profil pengguna, mencakup informasi dari `User` dan `UserDetail`.
class ProfileModel extends Equatable {
  // Properti dari objek 'user' utama di respons API
  final int userId;
  final String username;
  final String email;
  final String phone;
  final bool verified;
  final String userCreatedAt;
  final String userUpdatedAt;

  // Properti dari objek 'user_detail' yang bersarang di dalam 'user'
  final int userdetailId;
  final String nama;
  final String? fotoProfilBase64;
  final int umur;
  final JenisKelamin jenisKelamin;
  final double beratBadan;
  final double tinggiBadan;
  final Aktivitas aktivitas;
  final Tujuan? tujuan; // Bisa null
  final double? targetBeratBadan; // Bisa null
  final String? detailUpdatedAt; // Bisa null
  final String? detailCreatedAt; // Bisa null
  final KaloriModel? rekomendasiKalori; // Bisa null
  final BmiDataModel? bmiData; // Bisa null

  /// Konstruktor konstan untuk [ProfileModel].
  const ProfileModel({
    // Dari objek 'user' utama
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.verified,
    required this.userCreatedAt,
    required this.userUpdatedAt,
    // Dari objek 'user_detail' yang bersarang
    required this.userdetailId,
    required this.nama,
    this.fotoProfilBase64,
    required this.umur,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.aktivitas,
    this.tujuan,
    this.targetBeratBadan,
    this.detailUpdatedAt,
    this.detailCreatedAt,
    this.rekomendasiKalori,
    this.bmiData,
  });

  /// Membuat instance [ProfileModel] dari sebuah Map JSON.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? userJson =
        json['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const FormatException(
          'Respons API tidak memiliki kunci "user" atau nilainya null.');
    }

    final Map<String, dynamic>? userDetailJson =
        userJson['user_detail'] as Map<String, dynamic>?;
    if (userDetailJson == null) {
      // Lebih spesifik untuk error jika user_detail kosong
      throw const FormatException(
          'Data detail pengguna tidak ditemukan. Pastikan detail pengguna sudah dibuat.');
    }

    return ProfileModel(
      // Parsing dari objek 'user' utama
      userId: userJson['user_id'] as int,
      username: userJson['username'] as String,
      email: userJson['email'] as String,
      phone: userJson['phone'] as String,
      verified:
          userJson['verified'] as bool? ?? false, // Default ke false jika null
      userCreatedAt: userJson['created_at'] as String,
      userUpdatedAt: userJson['updated_at'] as String,

      // Parsing dari objek 'user_detail' yang bersarang
      userdetailId: userDetailJson['userdetail_id'] as int,
      nama: userDetailJson['nama'] as String,
      fotoProfilBase64: userDetailJson['foto_profil'] as String?,
      umur: userDetailJson['umur'] as int,
      jenisKelamin: ProfileModel._parseJenisKelamin(
          userDetailJson['jenis_kelamin'] as String),
      beratBadan: (userDetailJson['berat_badan'] as num).toDouble(),
      tinggiBadan: (userDetailJson['tinggi_badan'] as num).toDouble(),
      aktivitas:
          ProfileModel._parseAktivitas(userDetailJson['aktivitas'] as String),
      tujuan: userDetailJson['tujuan'] != null &&
              userDetailJson['tujuan'] is String // Pastikan itu string
          ? ProfileModel._parseTujuan(userDetailJson['tujuan'] as String)
          : null,
      targetBeratBadan:
          (userDetailJson['target_berat_badan'] as num?)?.toDouble(),
      detailUpdatedAt: userDetailJson['updated_at'] as String?,
      detailCreatedAt: userDetailJson['created_at'] as String?,
      rekomendasiKalori: userDetailJson['rekomendasi_kalori'] != null
          ? KaloriModel.fromJson(userDetailJson['rekomendasi_kalori'])
          : null,
      bmiData: userDetailJson['bmi_data'] != null
          ? BmiDataModel.fromJson(userDetailJson['bmi_data'])
          : null,
    );
  }

  // Metode Parsing Enum (static)
  static JenisKelamin _parseJenisKelamin(String value) {
    switch (value.toLowerCase()) {
      case "laki-laki":
      case "laki_laki":
        return JenisKelamin.lakiLaki;
      case "perempuan":
        return JenisKelamin.perempuan;
      default:
        // Handle case if value is not expected, throw error or return a default
        throw FormatException('Nilai Jenis Kelamin tidak valid: $value');
    }
  }

  static Aktivitas _parseAktivitas(String value) {
    switch (value.toLowerCase().replaceAll(' ', '_')) {
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
        throw FormatException('Nilai Aktivitas tidak valid: $value');
    }
  }

  static Tujuan _parseTujuan(String value) {
    switch (value.toLowerCase().replaceAll(' ', '_')) {
      case "menurunkan_berat_badan":
        return Tujuan.menurunkanBeratBadan;
      case "menambah_berat_badan":
        return Tujuan.menambahBeratBadan;
      case "menjaga_berat_badan_ideal":
        return Tujuan.menjagaBeratBadanIdeal;
      case "menaikan_massa_tubuh":
        return Tujuan.menaikanMassaTubuh;
      default:
        throw FormatException('Nilai Tujuan tidak valid: $value');
    }
  }

  /// Mengonversi string foto profil Base64 ke Uint8List (bytes).
  Uint8List? get profileImageBytes {
    if (fotoProfilBase64 == null) return null;
    try {
      final bytes = base64Decode(fotoProfilBase64!);
      return bytes;
    } catch (e) {
      print('Error decoding base64 image to bytes: $e');
      return null;
    }
  }

  /// Membuat salinan objek [ProfileModel] dengan properti yang diperbarui.
  ProfileModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? phone,
    bool? verified,
    String? userCreatedAt,
    String? userUpdatedAt,
    int? userdetailId,
    String? nama,
    String? fotoProfilBase64,
    int? umur,
    JenisKelamin? jenisKelamin,
    double? beratBadan,
    double? tinggiBadan,
    Aktivitas? aktivitas,
    Tujuan? tujuan,
    double? targetBeratBadan,
    String? detailUpdatedAt,
    String? detailCreatedAt,
    KaloriModel? rekomendasiKalori,
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

      userdetailId: userdetailId ?? this.userdetailId,
      nama: nama ?? this.nama,
      fotoProfilBase64: fotoProfilBase64 ?? this.fotoProfilBase64,
      umur: umur ?? this.umur,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      aktivitas: aktivitas ?? this.aktivitas,
      tujuan: tujuan ?? this.tujuan, // Menangani nullability
      targetBeratBadan:
          targetBeratBadan ?? this.targetBeratBadan, // Menangani nullability
      detailUpdatedAt:
          detailUpdatedAt ?? this.detailUpdatedAt, // Menangani nullability
      detailCreatedAt:
          detailCreatedAt ?? this.detailCreatedAt, // Menangani nullability
      rekomendasiKalori:
          rekomendasiKalori ?? this.rekomendasiKalori, // Menangani nullability
      bmiData: bmiData ?? this.bmiData, // Menangani nullability
    );
  }

  /// Mengonversi objek [ProfileModel] menjadi [Map<String, dynamic>].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      // Data dari objek 'user' utama
      'user_id': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'verified': verified,
      'created_at': userCreatedAt,
      'updated_at': userUpdatedAt,
      // Data dari objek 'user_detail' yang bersarang
      'user_detail': {
        'userdetail_id': userdetailId,
        'nama': nama,
        'foto_profil': fotoProfilBase64,
        'umur': umur,
        'jenis_kelamin': jenisKelamin.toApiString(),
        'berat_badan': beratBadan,
        'tinggi_badan': tinggiBadan,
        'aktivitas': aktivitas.toApiString(),
        'tujuan': tujuan?.toApiString(), // Menggunakan ?. untuk null safety
        'target_berat_badan': targetBeratBadan,
        'updated_at': detailUpdatedAt,
        'created_at': detailCreatedAt,
        'rekomendasi_kalori':
            rekomendasiKalori?.toJson(), // Menggunakan ?. untuk null safety
        'bmi_data': bmiData?.toJson(), // Menggunakan ?. untuk null safety
      }
    };
    // Hapus properti dengan nilai null di level root JSON
    json.removeWhere((key, value) => value == null);
    // Hapus properti dengan nilai null di user_detail
    (json['user_detail'] as Map<String, dynamic>)
        .removeWhere((key, value) => value == null);
    return json;
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        email,
        phone,
        verified,
        userCreatedAt,
        userUpdatedAt,
        userdetailId,
        nama,
        fotoProfilBase64,
        umur,
        jenisKelamin,
        beratBadan,
        tinggiBadan,
        aktivitas,
        tujuan,
        targetBeratBadan,
        detailUpdatedAt,
        detailCreatedAt,
        rekomendasiKalori,
        bmiData
      ];
}
