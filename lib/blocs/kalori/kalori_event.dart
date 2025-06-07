// lib/blocs/kalori/kalori_event.dart

import 'package:equatable/equatable.dart';

// Event dasar yang akan di-extend oleh semua event terkait kalori.
abstract class KaloriEvent extends Equatable {
  const KaloriEvent();

  @override
  List<Object> get props => [];
}

// Event untuk meminta pengambilan data rekomendasi kalori.
class FetchKaloriData extends KaloriEvent {
  const FetchKaloriData();

  @override
  List<Object> get props => [];
}

// Event untuk meminta penghapusan data rekomendasi kalori.
class DeleteKaloriData extends KaloriEvent {
  const DeleteKaloriData();

  @override
  List<Object> get props => [];
}
