// lib/blocs/user_detail/userdetail_state.dart

import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/userdetail_model.dart'; // Make sure this is imported

// Abstract base class for all UserDetail states
abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

// Initial state before any UserDetail actions
class UserDetailInitial extends UserDetailState {}

// Loading state for UserDetail operations
class UserDetailLoading extends UserDetailState {}

// Error state for UserDetail operations
class UserDetailError extends UserDetailState {
  final String message;
  const UserDetailError(this.message);

  @override
  List<Object> get props => [message];
}

// State for successfully loaded UserDetail data
class UserDetailLoaded extends UserDetailState {
  final UserDetailModel userDetail;
  const UserDetailLoaded(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

// State for successful addition of UserDetail data
class UserDetailAddSuccess extends UserDetailState {
  final UserDetailModel userDetail;
  const UserDetailAddSuccess(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

// State for successful update of UserDetail data
class UserDetailUpdateSuccess extends UserDetailState {
  final UserDetailModel userDetail;
  const UserDetailUpdateSuccess(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

// --- MISSING STATE 1: UserDetailNotComplete ---
// State for when user detail data is not found (e.g., 404 from backend)
// and user needs to complete their profile.
class UserDetailNotComplete extends UserDetailState {
  final int userId; // userId is passed to navigate to profile setup page
  const UserDetailNotComplete({required this.userId});

  @override
  List<Object> get props => [userId];
}
// --- END MISSING STATE 1 ---

// --- MISSING STATE 2: UserDetailDeleteSuccess ---
// State for successful deletion of user detail data
class UserDetailDeleteSuccess extends UserDetailState {
  final String message;
  const UserDetailDeleteSuccess(this.message);

  @override
  List<Object> get props => [message];
}
// --- END MISSING STATE 2 ---
