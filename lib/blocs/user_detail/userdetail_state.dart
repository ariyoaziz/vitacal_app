import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/userdetail_model.dart';

/// Abstract base class untuk semua state terkait detail pengguna.
abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

/// State awal Bloc/Cubit.
class UserDetailInitial extends UserDetailState {}

/// State saat data detail pengguna sedang dimuat atau diperbarui.
class UserDetailLoading extends UserDetailState {}

/// State saat data detail pengguna berhasil dimuat atau diperbarui.
/// [userDetail] berisi model data detail pengguna terbaru.
class UserDetailLoaded extends UserDetailState {
  final UserDetailModel userDetail;

  const UserDetailLoaded(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

/// State saat penambahan detail pengguna baru berhasil.
/// [userDetail] berisi model data detail pengguna yang baru saja ditambahkan.
class UserDetailAddSuccess extends UserDetailState {
  final UserDetailModel userDetail;

  const UserDetailAddSuccess(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

/// --- BARU: State saat pembaruan data detail pengguna berhasil. ---
/// [userDetail] berisi model data detail pengguna setelah pembaruan.
class UserDetailUpdateSuccess extends UserDetailState {
  final UserDetailModel userDetail;

  const UserDetailUpdateSuccess(this.userDetail);

  @override
  List<Object> get props => [userDetail];
}

/// --- AKHIR BARU ---

/// State saat terjadi kesalahan dalam operasi detail pengguna.
/// [message] berisi pesan kesalahan yang dapat ditampilkan kepada pengguna.
class UserDetailError extends UserDetailState {
  final String message;

  const UserDetailError(this.message);

  @override
  List<Object> get props => [message];
}
