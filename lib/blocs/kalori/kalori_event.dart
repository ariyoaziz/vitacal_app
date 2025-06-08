// lib/blocs/kalori/kalori_event.dart

import 'package:equatable/equatable.dart';

// Event dasar yang akan di-extend oleh semua event terkait kalori.
abstract class KaloriEvent extends Equatable {
  const KaloriEvent();

  @override
  List<Object> get props => [];
}

// Event untuk meminta pengambilan data rekomendasi kalori (existing).
class FetchKaloriData extends KaloriEvent {
  const FetchKaloriData();

  @override
  List<Object> get props => [];
}

// Event untuk meminta penghapusan data rekomendasi kalori (existing).
class DeleteKaloriData extends KaloriEvent {
  const DeleteKaloriData();

  @override
  List<Object> get props => [];
}

// --- NEW EVENTS FOR ANALYTICS PAGE ---

// Event untuk meminta pemuatan data ringkasan kalori harian.
class LoadDailyCalorieData extends KaloriEvent {
  const LoadDailyCalorieData();

  @override
  List<Object> get props => [];
}

// Event untuk meminta pemuatan data riwayat berat badan untuk grafik.
class LoadWeightGraphData extends KaloriEvent {
  const LoadWeightGraphData();

  @override
  List<Object> get props => [];
}
