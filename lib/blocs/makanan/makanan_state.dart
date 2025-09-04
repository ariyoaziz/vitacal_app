import 'package:equatable/equatable.dart';
import 'package:vitacal_app/models/makanan_item.dart';

abstract class MakananState extends Equatable {
  const MakananState();
  @override
  List<Object?> get props => [];
}

class MakananInitial extends MakananState {}

class MakananLoading extends MakananState {}

class MakananError extends MakananState {
  final String message;
  const MakananError(this.message);
  @override
  List<Object?> get props => [message];
}

class MakananEmpty extends MakananState {
  final String message;
  const MakananEmpty(this.message);
  @override
  List<Object?> get props => [message];
}

class MakananListLoaded extends MakananState {
  final List<MakananItem> items;
  final int total;
  final int page;
  final bool hasMore;
  const MakananListLoaded({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
  });
  @override
  List<Object?> get props => [items, total, page, hasMore];
}

class MakananSearchLoading extends MakananState {
  final String query;
  const MakananSearchLoading(this.query);
  @override
  List<Object?> get props => [query];
}

class MakananSearchLoaded extends MakananState {
  final String query;
  final List<MakananItem> items;
  final int total;
  const MakananSearchLoaded({
    required this.query,
    required this.items,
    required this.total,
  });
  @override
  List<Object?> get props => [query, items, total];
}
