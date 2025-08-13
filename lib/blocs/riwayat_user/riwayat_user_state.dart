import 'package:equatable/equatable.dart';

abstract class RiwayatUserState extends Equatable {
  const RiwayatUserState();
  @override
  List<Object?> get props => [];
}

class RiwayatUserInitial extends RiwayatUserState {
  const RiwayatUserInitial();
}

class RiwayatUserLoading extends RiwayatUserState {
  const RiwayatUserLoading();
}

class RiwayatUserLoaded extends RiwayatUserState {
  final List<Map<String, dynamic>>
      calorieHistory; // [{date, calories(=consumed), recommended, deficit}]
  final List<Map<String, dynamic>> weightHistory; // [{date, weight}]

  const RiwayatUserLoaded({
    required this.calorieHistory,
    required this.weightHistory,
  });

  @override
  List<Object?> get props => [calorieHistory, weightHistory];
}

class RiwayatUserError extends RiwayatUserState {
  final String message;
  const RiwayatUserError(this.message);

  @override
  List<Object?> get props => [message];
}
