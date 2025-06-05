// lib/blocs/user_detail/user_detail_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/services/userdetail_service.dart';

import 'userdetail_event.dart';
import 'userdetail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserDetailService userDetailService;

  UserDetailBloc({required this.userDetailService})
      : super(UserDetailInitial()) {
    on<AddUserDetail>((event, emit) async {
      emit(UserDetailLoading());
      try {
        final userDetail = await userDetailService.addUserDetail(
          userId: event.userId,
          nama: event.nama,
          umur: event.umur,
          jenisKelamin: event.jenisKelamin,
          beratBadan: event.beratBadan,
          tinggiBadan: event.tinggiBadan,
          aktivitas: event.aktivitas,
          tujuan: event.tujuan,
        );
        emit(UserDetailAddedSuccess(userDetail));
      } on AuthException catch (e) {
        print('UserDetailBloc: Menangkap AuthException: "${e.message}"');
        emit(UserDetailError(e.message));
      } catch (e) {
        print(
            'UserDetailBloc: Error tak terduga (AddUserDetail): ${e.runtimeType} - $e');
        emit(UserDetailError(
            'Terjadi masalah tak terduga. Mohon coba lagi nanti.'));
      }
    });
  }
}
