import 'package:equatable/equatable.dart';

abstract class RiwayatUserEvent extends Equatable {
  const RiwayatUserEvent();
  @override
  List<Object?> get props => [];
}

class LoadRiwayat extends RiwayatUserEvent {
  final int days;
  const LoadRiwayat({this.days = 7});

  @override
  List<Object?> get props => [days];
}

class ClearRiwayat extends RiwayatUserEvent {
  const ClearRiwayat();
}
