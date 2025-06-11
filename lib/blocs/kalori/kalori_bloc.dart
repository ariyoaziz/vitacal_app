// lib/blocs/kalori/kalori_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/kalori_service.dart'; // Import CalorieService Anda
import 'package:vitacal_app/exceptions/api_exception.dart'; // Import ApiException Anda
import 'package:vitacal_app/models/kalori_model.dart'; // Import KaloriModel Anda

// Import event dan state yang baru dibuat
import 'package:vitacal_app/blocs/kalori/kalori_event.dart';
import 'package:vitacal_app/blocs/kalori/kalori_state.dart';

class KaloriBloc extends Bloc<KaloriEvent, KaloriState> {
  final CalorieService calorieService;

  KaloriBloc({required this.calorieService}) : super(const KaloriInitial()) {
    on<FetchKaloriData>(_onFetchKaloriData);
    on<DeleteKaloriData>(_onDeleteKaloriData);
    on<LoadDailyCalorieData>(_onLoadDailyCalorieData);
    on<LoadWeightGraphData>(_onLoadWeightGraphData);
  }
  Future<void> _onLoadDailyCalorieData(
      LoadDailyCalorieData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      emit(const KaloriError(
          'Fitur LoadDailyCalorieData belum diimplementasikan.')); // Placeholder
    } on ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError(
          'Terjadi kesalahan saat memuat data kalori harian: ${e.toString()}'));
    }
  }

  Future<void> _onLoadWeightGraphData(
      LoadWeightGraphData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      emit(const KaloriError(
          'Fitur LoadWeightGraphData belum diimplementasikan.')); // Placeholder
    } on ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError(
          'Terjadi kesalahan saat memuat data grafik berat badan: ${e.toString()}'));
    }
  }

  Future<void> _onFetchKaloriData(
      FetchKaloriData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      await Future.delayed(
          const Duration(milliseconds: 1000)); // Ditingkatkan ke 1 detik

      final KaloriModel kaloriModel =
          await calorieService.fetchCalorieRecommendation();

      emit(KaloriLoaded(kaloriModel));
    } on ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError(
          'Terjadi kesalahan tidak terduga saat mengambil data kalori: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteKaloriData(
      DeleteKaloriData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final String message = await calorieService.deleteCalorieRecommendation();

      emit(KaloriSuccess(message));
      emit(const KaloriInitial());
    } on ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError(
          'Terjadi kesalahan tidak terduga saat menghapus data kalori: ${e.toString()}'));
    }
  }
}
