import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/profile_model.dart'; // Import ProfileModel

/// Abstract base class untuk semua state terkait profil pengguna.
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// State awal Bloc/Cubit.
class ProfileInitial extends ProfileState {}

/// State saat data profil sedang dimuat.
class ProfileLoading extends ProfileState {}

/// State saat data profil berhasil dimuat.
/// [profileData] berisi model data profil lengkap.
class ProfileLoaded extends ProfileState {
  final ProfileModel profileData; // Tipe data ProfileModel

  const ProfileLoaded(this.profileData);

  @override
  List<Object> get props => [profileData];
}

/// State saat terjadi kesalahan dalam memuat data profil.
/// [message] berisi pesan kesalahan yang dapat ditampilkan kepada pengguna.
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
