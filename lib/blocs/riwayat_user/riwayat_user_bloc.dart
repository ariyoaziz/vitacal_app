import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/riwayat_user_service.dart';

import 'riwayat_user_event.dart';
import 'riwayat_user_state.dart';

class RiwayatUserBloc extends Bloc<RiwayatUserEvent, RiwayatUserState> {
  final RiwayatUserService service;

  RiwayatUserBloc({required this.service}) : super(const RiwayatUserInitial()) {
    on<LoadRiwayat>(_onLoadRiwayat);
  }

  Future<void> _onLoadRiwayat(
    LoadRiwayat event,
    Emitter<RiwayatUserState> emit,
  ) async {
    emit(const RiwayatUserLoading());
    try {
      final calorie = await service.getCalorieChartData(days: event.days);
      final weight = await service.getWeightHistory(days: event.days);
      emit(RiwayatUserLoaded(
        calorieHistory: calorie,
        weightHistory: weight,
      ));
    } catch (e) {
      emit(RiwayatUserError('Gagal memuat riwayat: $e'));
    }
  }
}
