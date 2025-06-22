// lib/blocs/profile/profile_state.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
  @override
  List<Object> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
  @override
  List<Object> get props => [];
}

class ProfileLoaded extends ProfileState {
  final ProfileModel profileData;
  const ProfileLoaded(this.profileData);
  @override
  List<Object> get props => [profileData];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

class ProfileSuccess extends ProfileState {
  final String message;
  const ProfileSuccess(this.message);
  @override
  List<Object> get props => [message];
}

// >>>>>> TAMBAHKAN STATE INI <<<<<<
class ProfileNoChange extends ProfileState {
  final String message;
  const ProfileNoChange(this.message);
  @override
  List<Object> get props => [message];
}
