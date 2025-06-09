import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/enums.dart';

/// Abstract base class untuk semua event terkait detail pengguna.
/// Setiap event harus meng-override [props] untuk perbandingan yang efektif menggunakan Equatable.
abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  // PERBAIKAN: Mengubah tipe kembalian menjadi List<Object?> untuk menangani properti nullable
  List<Object?> get props => [];
}

/// Event untuk menambah detail pengguna baru.
/// Biasanya dipanggil saat alur pendaftaran awal untuk menyimpan data detail pengguna.
class AddUserDetail extends UserDetailEvent {
  final int userId;
  final String nama;
  final int umur;
  final JenisKelamin jenisKelamin;
  final double beratBadan;
  final double tinggiBadan;
  final Aktivitas aktivitas;
  final Tujuan? tujuan; // Optional

  const AddUserDetail({
    required this.userId,
    required this.nama,
    required this.umur,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.aktivitas,
    this.tujuan,
  });

  @override
  List<Object> get props => [
        userId,
        nama,
        umur,
        jenisKelamin,
        beratBadan,
        tinggiBadan,
        aktivitas,
        tujuan ?? '', // Handle nullable for equatable
      ];
}

class LoadUserDetail extends UserDetailEvent {}

class UpdateUserDetail extends UserDetailEvent {
  final Map<String, dynamic> updates;

  const UpdateUserDetail({required this.updates});

  @override
  List<Object> get props =>
      [updates]; // Ini tetap List<Object> karena Map tidak nullable di sini
}

class DeleteUserDetail extends UserDetailEvent {}
