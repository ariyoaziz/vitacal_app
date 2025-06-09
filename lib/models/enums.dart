// lib/models/enums.dart

// Enum untuk Jenis Kelamin
enum JenisKelamin {
  lakiLaki,
  perempuan,
}

extension JenisKelaminExtension on JenisKelamin {
  // Mengonversi enum ke string format snake_case yang diharapkan API
  String toApiString() {
    switch (this) {
      case JenisKelamin.lakiLaki:
        return "laki_laki";
      case JenisKelamin.perempuan:
        return "perempuan";
    }
  }

  // BARU: Mengonversi enum ke string yang mudah dibaca untuk tampilan UI
  String toDisplayString() {
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
  // Mengonversi enum ke string format snake_case yang diharapkan API
  String toApiString() {
    switch (this) {
      case Aktivitas.tidakAktif:
        return "tidak_aktif";
      case Aktivitas.ringan:
        return "ringan";
      case Aktivitas.sedang:
        return "sedang";
      case Aktivitas.berat:
        return "berat";
      case Aktivitas.sangatBerat:
        return "sangat_berat";
    }
  }

  // BARU: Mengonversi enum ke string yang mudah dibaca untuk tampilan UI
  String toDisplayString() {
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
  // Mengonversi enum ke string format snake_case yang diharapkan API
  String toApiString() {
    switch (this) {
      case Tujuan.menurunkanBeratBadan:
        return "menurunkan_berat_badan";
      case Tujuan.menambahBeratBadan:
        return "menambah_berat_badan";
      case Tujuan.menjagaBeratBadanIdeal:
        return "menjaga_berat_badan_ideal";
      case Tujuan.menaikanMassaTubuh:
        return "menaikan_massa_tubuh";
    }
  }

  // BARU: Mengonversi enum ke string yang mudah dibaca untuk tampilan UI
  String toDisplayString() {
    switch (this) {
      case Tujuan.menurunkanBeratBadan:
        return "Menurunkan Berat Badan";
      case Tujuan.menambahBeratBadan:
        return "Menambah Berat Badan";
      case Tujuan.menjagaBeratBadanIdeal:
        return "Menjaga Berat Badan Ideal";
      case Tujuan.menaikanMassaTubuh:
        return "Menaikkan Massa Tubuh";
    }
  }
}
