// lib/blocs/user_detail/user_detail_event.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/enums.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object> get props => [];
}

class AddUserDetail extends UserDetailEvent {
  final int userId;
  final String nama;
  final int umur;
  final JenisKelamin jenisKelamin;
  final double beratBadan;
  final double tinggiBadan;
  final Aktivitas aktivitas;
  final Tujuan? tujuan; // Opsional

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
