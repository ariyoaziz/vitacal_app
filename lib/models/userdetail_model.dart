import 'dart:convert'; // For base64Decode
import 'dart:typed_data'; // For Uint8List
import 'package:vitacal_app/models/enums.dart'; // Ensure this path is correct
import 'package:equatable/equatable.dart'; // Import Equatable, crucial for BLoC

/// Data model for user details, including personal information and health metrics.
class UserDetailModel extends Equatable {
  final int userdetailId;
  final int userId;
  final String nama;
  final String? fotoProfilBase64; // Base64 string of the profile picture
  final int umur;
  final JenisKelamin jenisKelamin;
  final double beratBadan;
  final double tinggiBadan;
  final Aktivitas aktivitas;
  final Tujuan? tujuan; // Nullable
  final double? targetBeratBadan; // Added this field, nullable
  final String updatedAt;

  /// Constant constructor for [UserDetailModel].
  const UserDetailModel({
    required this.userdetailId,
    required this.userId,
    required this.nama,
    this.fotoProfilBase64,
    required this.umur,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.aktivitas,
    this.tujuan,
    this.targetBeratBadan, // Include in constructor
    required this.updatedAt,
  });

  /// Creates a [UserDetailModel] instance from a JSON Map.
  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      userdetailId: json['userdetail_id'] as int,
      userId: json['user_id'] as int,
      nama: json['nama'] as String,
      fotoProfilBase64: json['foto_profil'] as String?,
      umur: json['umur'] as int,
      jenisKelamin: _parseJenisKelamin(json['jenis_kelamin'] as String),
      beratBadan: (json['berat_badan'] as num).toDouble(),
      tinggiBadan: (json['tinggi_badan'] as num).toDouble(),
      aktivitas: _parseAktivitas(json['aktivitas'] as String),
      tujuan: json['tujuan'] != null
          ? _parseTujuan(json['tujuan'] as String)
          : null,
      targetBeratBadan: (json['target_berat_badan'] as num?)
          ?.toDouble(), // Parsing target_berat_badan
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Helper to parse JenisKelamin Enum values from API strings.
  static JenisKelamin _parseJenisKelamin(String value) {
    switch (value.toLowerCase()) {
      // Convert input to lowercase for comparison
      case "laki-laki":
      case "laki_laki": // Add case for snake_case format from API
        return JenisKelamin.lakiLaki;
      case "perempuan":
        return JenisKelamin.perempuan;
      default:
        throw FormatException('Invalid Jenis Kelamin: $value');
    }
  }

  /// Helper to parse Aktivitas Enum values from API strings.
  static Aktivitas _parseAktivitas(String value) {
    // Convert input to lowercase AND replace spaces with underscores
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
        throw FormatException('Invalid Aktivitas: $value');
    }
  }

  // --- PERBAIKAN DI SINI: _parseTujuan menggunakan Map lookup untuk robustnes ---
  static final Map<String, Tujuan> _tujuanMap = {
    "menurunkan_berat_badan": Tujuan.menurunkanBeratBadan,
    "menambah_berat_badan": Tujuan.menambahBeratBadan,
    "menjaga_berat_badan_ideal": Tujuan.menjagaBeratBadanIdeal,
    "menaikan_massa_tubuh": Tujuan.menaikanMassaTubuh,
  };


  static Tujuan _parseTujuan(String value) {
    // Clean the value: convert to lowercase, trim whitespace, replace spaces with underscores
    final cleanedValue = value.toLowerCase().trim().replaceAll(' ', '_');
    // DEBUG: Cetak nilai yang sudah dibersihkan untuk verifikasi
    print(
        'DEBUG: Parsing Tujuan. Cleaned value: "$cleanedValue" (Original: "$value")');

    final parsedTujuan = _tujuanMap[cleanedValue];
    if (parsedTujuan != null) {
      return parsedTujuan;
    } else {
      // Lebih detail di pesan error untuk debugging
      throw FormatException(
          'Invalid Tujuan: $value (Cleaned: "$cleanedValue")');
    }
  }
  // --- AKHIR PERBAIKAN _parseTujuan ---

  /// Converts the Base64 profile picture string to Uint8List (bytes).
  /// Returns null if `fotoProfilBase64` is null or decoding fails.
  Uint8List? get profileImageBytes {
    if (fotoProfilBase64 == null) return null;
    try {
      final bytes = base64Decode(fotoProfilBase64!);
      return bytes;
    } catch (e) {
      print('Error decoding base64 image to bytes: $e'); // For debugging
      return null;
    }
  }

  /// Creates a copy of the [UserDetailModel] object with updated properties.
  /// This is highly useful for immutable state management in BLoC.
  UserDetailModel copyWith({
    int? userdetailId,
    int? userId,
    String? nama,
    String? fotoProfilBase64,
    int? umur,
    JenisKelamin? jenisKelamin,
    double? beratBadan,
    double? tinggiBadan,
    Aktivitas? aktivitas,
    Tujuan? tujuan,
    double? targetBeratBadan,
    String? updatedAt,
  }) {
    return UserDetailModel(
      userdetailId: userdetailId ?? this.userdetailId,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      fotoProfilBase64: fotoProfilBase64 ?? this.fotoProfilBase64,
      umur: umur ?? this.umur,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      aktivitas: aktivitas ?? this.aktivitas,
      tujuan: tujuan ?? this.tujuan,
      targetBeratBadan: targetBeratBadan ?? this.targetBeratBadan,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the [UserDetailModel] object to a [Map<String, dynamic>].
  /// Useful for sending data back to the Flask API.
  Map<String, dynamic> toJson() {
    return {
      'userdetail_id': userdetailId,
      'user_id': userId,
      'nama': nama,
      'foto_profil': fotoProfilBase64,
      'umur': umur,
      'jenis_kelamin': jenisKelamin
          .toApiString(), // Assumes toApiString() in enums returns API-friendly format
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'aktivitas': aktivitas
          .toApiString(), // Assumes toApiString() in enums returns API-friendly format
      'tujuan': tujuan
          ?.toApiString(), // Assumes toApiString() in enums returns API-friendly format
      'target_berat_badan': targetBeratBadan,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        userdetailId,
        userId,
        nama,
        fotoProfilBase64,
        umur,
        jenisKelamin,
        beratBadan,
        tinggiBadan,
        aktivitas,
        tujuan,
        targetBeratBadan,
        updatedAt,
      ];
}
