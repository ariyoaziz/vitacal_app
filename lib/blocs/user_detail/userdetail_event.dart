import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/enums.dart';

/// Abstract base class untuk semua event terkait detail pengguna.
/// Setiap event harus meng-override [props] untuk perbandingan yang efektif menggunakan Equatable.
abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  // Tipe kembalian yang benar untuk menangani properti nullable
  List<Object?> get props => [];
}

/// Event untuk menambah detail pengguna baru.
/// Dipanggil saat alur pendaftaran awal untuk menyimpan data detail pengguna.
class AddUserDetail extends UserDetailEvent {
  final String nama;
  final int umur;
  final JenisKelamin jenisKelamin;
  final double beratBadan;
  final double tinggiBadan;
  final Aktivitas aktivitas;
  final Tujuan? tujuan; // Optional

  const AddUserDetail({
    required this.nama,
    required this.umur,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.aktivitas,
    this.tujuan,
  });

  @override
  // Menggunakan List<Object?> agar konsisten dengan tipe kembalian kelas abstrak.
  // Properti nullable (seperti 'tujuan') bisa disertakan langsung, Equatable akan menanganinya.
  List<Object?> get props => [
        nama,
        umur,
        jenisKelamin,
        beratBadan,
        tinggiBadan,
        aktivitas,
        tujuan, // 'tujuan' bisa langsung disertakan karena List<Object?>
      ];
}

/// Event untuk memuat detail pengguna yang sudah ada.
class LoadUserDetail extends UserDetailEvent {
  const LoadUserDetail(); // Tambahkan constructor const jika memungkinkan

  @override
  List<Object?> get props => []; // Tidak ada properti, jadi kosong
}

/// Event untuk memperbarui detail pengguna.
class UpdateUserDetail extends UserDetailEvent {
  final Map<String, dynamic> updates;

  const UpdateUserDetail(
      {required this.updates}); // Tambahkan constructor const

  @override
  // Menggunakan List<Object?> agar konsisten.
  // 'updates' itu sendiri tidak nullable, tapi List<Object?> bisa menampungnya.
  List<Object?> get props => [updates];
}

/// Event untuk menghapus detail pengguna.
class DeleteUserDetail extends UserDetailEvent {
  const DeleteUserDetail(); // Tambahkan constructor const

  @override
  List<Object?> get props => []; // Tidak ada properti, jadi kosong
}
