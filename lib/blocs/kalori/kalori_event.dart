import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/kalori_model.dart';

abstract class KaloriEvent extends Equatable {
  const KaloriEvent();
  @override
  List<Object> get props => [];
}

class FetchKaloriData extends KaloriEvent {
  const FetchKaloriData();
}

class DeleteKaloriData extends KaloriEvent {
  const DeleteKaloriData();
}

class LoadDailyCalorieData extends KaloriEvent {
  const LoadDailyCalorieData();
}

class LoadWeightGraphData extends KaloriEvent {
  const LoadWeightGraphData();
}

/// Hydrate KaloriBloc dari data yang datang bersama Profile (tanpa network call baru)
class HydrateKaloriFromProfile extends KaloriEvent {
  final KaloriModel data;
  const HydrateKaloriFromProfile(this.data);

  @override
  List<Object> get props => [data];
}
