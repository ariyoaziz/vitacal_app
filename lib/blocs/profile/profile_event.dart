import 'package:equatable/equatable.dart';

/// Abstract base class untuk semua event terkait profil pengguna.
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

/// Event untuk memuat data profil pengguna dari backend.
class LoadProfileData extends ProfileEvent {}
