// lib/blocs/kalori/kalori_state.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/kalori_model.dart'; // Import model KaloriModel Anda

// State dasar yang akan di-extend oleh semua state terkait kalori.
abstract class KaloriState extends Equatable {
  const KaloriState();

  @override
  List<Object> get props => [];
}

// State awal sebelum ada operasi yang dilakukan.
class KaloriInitial extends KaloriState {
  const KaloriInitial();

  @override
  List<Object> get props => [];
}

// State ketika data kalori sedang dimuat (misalnya, dari API).
class KaloriLoading extends KaloriState {
  const KaloriLoading();

  @override
  List<Object> get props => [];
}

// State ketika data kalori berhasil dimuat.
class KaloriLoaded extends KaloriState {
  final KaloriModel kaloriModel; // Menggunakan KaloriModel
  const KaloriLoaded(this.kaloriModel);

  @override
  List<Object> get props => [kaloriModel];
}

// State ketika operasi (misalnya, penghapusan) berhasil dilakukan.
class KaloriSuccess extends KaloriState {
  final String message; // Pesan sukses (misalnya, "Data berhasil dihapus")
  const KaloriSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// State ketika terjadi kesalahan dalam operasi kalori.
class KaloriError extends KaloriState {
  final String message; // Pesan error untuk ditampilkan ke pengguna
  const KaloriError(this.message);

  @override
  List<Object> get props => [message];
}
