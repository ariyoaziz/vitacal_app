// lib/blocs/profile/profile_event.dart
import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/enums.dart'; // Import enums jika event menggunakannya

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileData extends ProfileEvent {
  const LoadProfileData();
}

class ResetProfileData extends ProfileEvent {
  const ResetProfileData();
}

// --- BARU: Event untuk memperbarui data pribadi ---

class UpdateBeratBadan extends ProfileEvent {
  final double beratBadan;
  const UpdateBeratBadan(this.beratBadan);
  @override
  List<Object> get props => [beratBadan];
}

class UpdateTinggiBadan extends ProfileEvent {
  final double tinggiBadan;
  const UpdateTinggiBadan(this.tinggiBadan);
  @override
  List<Object> get props => [tinggiBadan];
}

class UpdateJenisKelamin extends ProfileEvent {
  final JenisKelamin jenisKelamin;
  const UpdateJenisKelamin(this.jenisKelamin);
  @override
  List<Object> get props => [jenisKelamin];
}

class UpdateAktivitas extends ProfileEvent {
  final Aktivitas aktivitas;
  const UpdateAktivitas(this.aktivitas);
  @override
  List<Object> get props => [aktivitas];
}

class UpdateTujuan extends ProfileEvent {
  final Tujuan tujuan;
  const UpdateTujuan(this.tujuan);
  @override
  List<Object> get props => [tujuan];
}

class DeleteProfile extends ProfileEvent {
  const DeleteProfile();
}

class UpdateContactInfo extends ProfileEvent {
  final String email;
  final String phone;
  const UpdateContactInfo({required this.email, required this.phone});
}
