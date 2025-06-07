// lib/blocs/kalori/kalori_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/services/kalori_service.dart'; // Import CalorieService Anda
import 'package:vitacal_app/exceptions/api_exception.dart'; // Import ApiException Anda
import 'package:vitacal_app/models/kalori_model.dart'; // Import KaloriModel Anda

// Import event dan state yang baru dibuat
import 'package:vitacal_app/blocs/kalori/kalori_event.dart';
import 'package:vitacal_app/blocs/kalori/kalori_state.dart';

class KaloriBloc extends Bloc<KaloriEvent, KaloriState> {
  final CalorieService calorieService; // Dependensi untuk service API

  // Constructor BLoC
  KaloriBloc({required this.calorieService}) : super(const KaloriInitial()) {
    // Daftarkan handler untuk setiap event
    on<FetchKaloriData>(_onFetchKaloriData);
    on<DeleteKaloriData>(_onDeleteKaloriData);
  }

  // Handler untuk event FetchKaloriData
  Future<void> _onFetchKaloriData(
      FetchKaloriData event, Emitter<KaloriState> emit) async {
    // Keluarkan state Loading sebelum memulai operasi asinkron
    emit(const KaloriLoading());
    try {
      // --- PERBAIKAN: MENAMBAHKAN JEDA LEBIH LAMA UNTUK MENGATASI RACE CONDITION TOKEN ---
      // Memberi sedikit jeda untuk memastikan JWT token sudah sepenuhnya disimpan.
      // Jika masalah masih berlanjut, Anda mungkin perlu meningkatkan jeda ini
      // atau mengimplementasikan mekanisme pengecekan token yang lebih canggih.
      await Future.delayed(
          const Duration(milliseconds: 1000)); // Ditingkatkan ke 1 detik
      // ---------------------------------------------------------------------------------

      // Panggil service untuk mendapatkan data kalori
      final KaloriModel kaloriModel =
          await calorieService.fetchCalorieRecommendation();
      // Keluarkan state Loaded dengan data yang berhasil diambil
      emit(KaloriLoaded(kaloriModel));
    } on ApiException catch (e) {
      // Tangani ApiException dari service
      emit(KaloriError(e.message));
    } catch (e) {
      // Tangani error umum lainnya
      emit(KaloriError(
          'Terjadi kesalahan tidak terduga saat mengambil data kalori: ${e.toString()}'));
    }
  }

  // Handler untuk event DeleteKaloriData
  Future<void> _onDeleteKaloriData(
      DeleteKaloriData event, Emitter<KaloriState> emit) async {
    // Keluarkan state Loading (atau bisa juga state khusus untuk deleting)
    emit(const KaloriLoading());
    try {
      // --- PERBAIKAN: MENAMBAHKAN JEDA LEBIH LAMA UNTUK MENGATASI RACE CONDITION TOKEN ---
      // Memberi sedikit jeda untuk memastikan JWT token sudah sepenuhnya disimpan.
      await Future.delayed(
          const Duration(milliseconds: 1000)); // Ditingkatkan ke 1 detik
      // ---------------------------------------------------------------------------------

      // Panggil service untuk menghapus data kalori
      final String message = await calorieService.deleteCalorieRecommendation();
      // Keluarkan state Success dengan pesan dari API
      emit(KaloriSuccess(message));
      // Setelah sukses menghapus, Anda mungkin ingin me-refresh data kalori
      // atau mengarahkan user, atau emit KaloriInitial/KaloriLoaded(null)
      // untuk menghapus tampilan data lama.
      emit(const KaloriInitial()); // Atau add(const FetchKaloriData());
    } on ApiException catch (e) {
      // Tangani ApiException dari service
      emit(KaloriError(e.message));
    } catch (e) {
      // Tangani error umum lainnya
      emit(KaloriError(
          'Terjadi kesalahan tidak terduga saat menghapus data kalori: ${e.toString()}'));
    }
  }
}
