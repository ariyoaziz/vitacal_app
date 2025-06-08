// lib/blocs/user_detail/user_detail_state.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/userdetail_model.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {}

class UserDetailAddedSuccess extends UserDetailState {
  final UserDetailModel userDetail;

  const UserDetailAddedSuccess(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

class UserDetailError extends UserDetailState {
  final String message;

  const UserDetailError(this.message);

  @override
  List<Object> get props => [message];
}

