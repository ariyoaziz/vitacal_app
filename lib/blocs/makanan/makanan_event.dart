import 'package:equatable/equatable.dart';

abstract class MakananEvent extends Equatable {
  const MakananEvent();
  @override
  List<Object?> get props => [];
}

class MakananFetchAll extends MakananEvent {
  final int limit;
  final int page;
  final bool refresh;
  const MakananFetchAll({this.limit = 50, this.page = 1, this.refresh = false});
  @override
  List<Object?> get props => [limit, page, refresh];
}

class MakananLoadMore extends MakananEvent {
  const MakananLoadMore();
}

class MakananSearchQueryChanged extends MakananEvent {
  final String query;
  const MakananSearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class MakananClearSearch extends MakananEvent {
  const MakananClearSearch();
}
