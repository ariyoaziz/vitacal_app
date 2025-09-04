import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/kalori_service.dart';
import 'package:vitacal_app/models/kalori_model.dart';

import 'package:vitacal_app/blocs/kalori/kalori_event.dart';
import 'package:vitacal_app/blocs/kalori/kalori_state.dart';

// pakai alias supaya tidak ambiguous
import 'package:vitacal_app/exceptions/api_exception.dart' as api;
import 'package:vitacal_app/exceptions/auth_exception.dart' as auth;

class KaloriBloc extends Bloc<KaloriEvent, KaloriState> {
  final CalorieService calorieService;

  KaloriBloc({required this.calorieService}) : super(const KaloriInitial()) {
    on<FetchKaloriData>(_onFetchKaloriData);
    on<DeleteKaloriData>(_onDeleteKaloriData);
    on<LoadDailyCalorieData>(_onLoadDailyCalorieData);
    on<LoadWeightGraphData>(_onLoadWeightGraphData);
    on<HydrateKaloriFromProfile>(_onHydrateFromProfile);
  }

  Future<void> _onHydrateFromProfile(
      HydrateKaloriFromProfile event, Emitter<KaloriState> emit) async {
    // langsung set Loaded dari data profile
    emit(KaloriLoaded(event.data));
  }

  Future<void> _onLoadDailyCalorieData(
      LoadDailyCalorieData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      emit(const KaloriError(
          'Fitur LoadDailyCalorieData belum diimplementasikan.'));
    } on auth.AuthException catch (e) {
      emit(KaloriError(e.message));
    } on api.ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError('Terjadi kesalahan saat memuat data kalori harian: $e'));
    }
  }

  Future<void> _onLoadWeightGraphData(
      LoadWeightGraphData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      emit(const KaloriError(
          'Fitur LoadWeightGraphData belum diimplementasikan.'));
    } on auth.AuthException catch (e) {
      emit(KaloriError(e.message));
    } on api.ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError(
          'Terjadi kesalahan saat memuat data grafik berat badan: $e'));
    }
  }

  Future<void> _onFetchKaloriData(
      FetchKaloriData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      final KaloriModel kaloriModel =
          await calorieService.fetchCalorieRecommendation();
      emit(KaloriLoaded(kaloriModel));
    } on auth.AuthException catch (e) {
      emit(KaloriError(e.message));
    } on api.ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError(
          'Terjadi kesalahan tidak terduga saat mengambil data kalori: $e'));
    }
  }

  Future<void> _onDeleteKaloriData(
      DeleteKaloriData event, Emitter<KaloriState> emit) async {
    emit(const KaloriLoading());
    try {
      final String message = await calorieService.deleteCalorieRecommendation();
      emit(KaloriSuccess(message));
      emit(const KaloriInitial());
    } on auth.AuthException catch (e) {
      emit(KaloriError(e.message));
    } on api.ApiException catch (e) {
      emit(KaloriError(e.message));
    } catch (e) {
      emit(KaloriError(
          'Terjadi kesalahan tidak terduga saat menghapus data kalori: $e'));
    }
  }
}
