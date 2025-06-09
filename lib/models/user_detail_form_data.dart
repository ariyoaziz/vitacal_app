import 'package:vitacal_app/models/enums.dart'; // Pastikan path ini benar

/// Model data yang digunakan untuk menampung input dari form detail pengguna.
///
/// Properti-properti di sini seringkali bersifat nullable karena pengguna
/// mungkin hanya mengisi sebagian informasi saat mengupdate profil,
/// atau saat form awal belum lengkap.
class UserDetailFormData {
  final int userId; // ID pengguna, seringkali tidak berubah di form update
  String? nama;
  int? umur;
  DateTime? tanggalLahir; // Jika Anda menggunakan DateTime Picker di form
  JenisKelamin? jenisKelamin;
  double? beratBadan;
  double? tinggiBadan; // Tinggi badan pengguna
  Aktivitas? aktivitas;
  Tujuan? tujuan;

  /// Konstruktor untuk [UserDetailFormData].
  /// [userId] adalah wajib, properti lain bersifat opsional.
  UserDetailFormData({
    required this.userId,
    this.nama,
    this.umur,
    this.tanggalLahir,
    this.jenisKelamin,
    this.beratBadan,
    this.tinggiBadan,
    this.aktivitas,
    this.tujuan,
  });

  /// Membuat salinan objek [UserDetailFormData] dengan properti yang diperbarui.
  ///
  /// Ini sangat berguna saat mengelola state form, di mana Anda ingin
  /// mengubah satu atau beberapa nilai tanpa mengubah objek aslinya.
  UserDetailFormData copyWith({
    String? nama,
    int? umur,
    DateTime? tanggalLahir,
    JenisKelamin? jenisKelamin,
    double? beratBadan,
    double? tinggiBadan,
    Aktivitas? aktivitas,
    Tujuan? tujuan,
  }) {
    return UserDetailFormData(
      userId: userId, // userId biasanya tidak diubah di copyWith
      nama: nama ?? this.nama,
      umur: umur ?? this.umur,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      aktivitas: aktivitas ?? this.aktivitas,
      tujuan: tujuan ?? this.tujuan,
    );
  }

  /// Metode bantu untuk mengonversi data form menjadi Map yang bisa dikirim ke API.
  ///
  /// Hanya properti yang memiliki nilai (bukan null) yang akan disertakan.
  /// Ini berguna karena API update Anda menerima partial updates.
  Map<String, dynamic> toApiJson() {
    final Map<String, dynamic> json = {};

    if (nama != null) json['nama'] = nama;
    if (umur != null) json['umur'] = umur;
    // tanggalLahir tidak dikirim langsung ke API Flask Anda saat ini
    if (jenisKelamin != null)
      // ignore: curly_braces_in_flow_control_structures
      json['jenis_kelamin'] = jenisKelamin!.toApiString();
    if (beratBadan != null) json['berat_badan'] = beratBadan;
    if (tinggiBadan != null) json['tinggi_badan'] = tinggiBadan;
    if (aktivitas != null) json['aktivitas'] = aktivitas!.toApiString();
    if (tujuan != null) json['tujuan'] = tujuan!.toApiString();

    return json;
  }
}
