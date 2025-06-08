// lib/blocs/user_detail/userdetail_event.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/enums.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object> get props => [];
}

// Existing event for adding new user details (e.g., during registration flow)
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

// --- NEW EVENTS FOR ANALYTICS PAGE ---

// Event to load the current user's details from the backend
class LoadUserDetail extends UserDetailEvent {}

// Event to update the user's current weight
class UpdateUserDetailWeight extends UserDetailEvent {
  final double newWeight;
  final double currentHeight; // Needed for backend BMI recalculation

  const UpdateUserDetailWeight({
    required this.newWeight,
    required this.currentHeight,
  });

  @override
  List<Object> get props => [newWeight, currentHeight];
}

// Event to update the user's target weight
class UpdateUserDetailTargetWeight extends UserDetailEvent {
  final double newTargetWeight;

  const UpdateUserDetailTargetWeight({required this.newTargetWeight});

  @override
  List<Object> get props => [newTargetWeight];
}