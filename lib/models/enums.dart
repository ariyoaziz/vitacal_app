// lib/models/enums.dart

// Enum untuk Jenis Kelamin
enum JenisKelamin {
  lakiLaki,
  perempuan,
}

extension JenisKelaminExtension on JenisKelamin {
  String toApiString() {
    switch (this) {
      case JenisKelamin.lakiLaki:
        return "Laki-laki";
      case JenisKelamin.perempuan:
        return "Perempuan";
    }
  }
}

// Enum untuk Tingkat Aktivitas
enum Aktivitas {
  tidakAktif,
  ringan,
  sedang,
  berat,
  sangatBerat,
}

extension AktivitasExtension on Aktivitas {
  String toApiString() {
    switch (this) {
      case Aktivitas.tidakAktif:
        return "Tidak Aktif";
      case Aktivitas.ringan:
        return "Ringan";
      case Aktivitas.sedang:
        return "Sedang";
      case Aktivitas.berat:
        return "Berat";
      case Aktivitas.sangatBerat:
        return "Sangat Berat";
    }
  }
}

// Enum untuk Tujuan
enum Tujuan {
  menurunkanBeratBadan,
  menambahBeratBadan,
  menjagaBeratBadanIdeal,
  menaikanMassaTubuh,
}

extension TujuanExtension on Tujuan {
  String toApiString() {
    switch (this) {
      case Tujuan.menurunkanBeratBadan:
        return "Menurunkan Berat Badan";
      case Tujuan.menambahBeratBadan:
        return "Menambah Berat Badan";
      case Tujuan.menjagaBeratBadanIdeal:
        return "Menjaga Berat Badan Ideal";
      case Tujuan.menaikanMassaTubuh:
        return "Menaikan Massa Tubuh";
    }
  }
}
