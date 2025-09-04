// lib/blocs/makanan/makanan_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:vitacal_app/models/makanan_item.dart';
import 'package:vitacal_app/models/api_list_response.dart';
import 'package:vitacal_app/services/makanan_service.dart';

import 'makanan_event.dart';
import 'makanan_state.dart';

EventTransformer<E> debounceDroppable<E>(Duration d) {
  // Cancel request sebelumnya & debounce (hindari race / spam)
  return (events, mapper) => events.debounceTime(d).switchMap(mapper);
}

class MakananBloc extends Bloc<MakananEvent, MakananState> {
  final MakananService service;

  // cache untuk list awal/rekomendasi
  final List<MakananItem> _listCache = [];
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;

  String _lastQuery = '';

  MakananBloc({required this.service}) : super(MakananInitial()) {
    on<MakananFetchAll>(_onFetchAll);
    on<MakananLoadMore>(_onLoadMore);
    on<MakananSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounceDroppable(const Duration(milliseconds: 350)),
    );
    on<MakananClearSearch>(_onClearSearch);
  }

  Future<void> _onFetchAll(
    MakananFetchAll e,
    Emitter<MakananState> emit,
  ) async {
    if (e.refresh) {
      _listCache.clear();
      _page = 1;
      _total = 0;
      _hasMore = false;
    }
    if (_listCache.isEmpty) {
      emit(MakananLoading());
    }

    try {
      ApiListResponse<MakananItem> res;

      final bool firstPageAndEmpty =
          (e.page == 1 && _listCache.isEmpty && !e.refresh);

      if (firstPageAndEmpty) {
        // Coba recommended dulu → fallback ke random
        try {
          res =
              await service.getAll(limit: e.limit, page: 1, recommended: true);
          if (res.data.isEmpty) {
            res = await service.getAll(limit: e.limit, page: 1, random: true);
          }
        } catch (_) {
          // kalau recommended error (mis. belum diaktifkan), fallback random
          res = await service.getAll(limit: e.limit, page: 1, random: true);
        }
      } else {
        res = await service.getAll(limit: e.limit, page: e.page);
      }

      if (e.page == 1) _listCache.clear();

      // dedupe by id
      final existing = _listCache.map((it) => it.id).toSet();
      for (final it in res.data) {
        if (!existing.contains(it.id)) {
          _listCache.add(it);
          existing.add(it.id);
        }
      }

      _page = e.page;
      _total = res.total;
      _hasMore = _listCache.length < _total;

      if (_listCache.isEmpty) {
        emit(const MakananEmpty('Belum ada data makanan.'));
      } else {
        emit(MakananListLoaded(
          items: List.unmodifiable(_listCache),
          total: _total,
          page: _page,
          hasMore: _hasMore,
        ));
      }
    } on ApiException catch (ex) {
      emit(MakananError(ex.message));
    } catch (ex) {
      emit(MakananError('Gagal memuat data: $ex'));
    }
  }

  Future<void> _onLoadMore(
    MakananLoadMore e,
    Emitter<MakananState> emit,
  ) async {
    if (!_hasMore) return;
    final next = _page + 1;

    try {
      final res = await service.getAll(limit: 50, page: next);

      // dedupe by id
      final existing = _listCache.map((it) => it.id).toSet();
      for (final it in res.data) {
        if (!existing.contains(it.id)) {
          _listCache.add(it);
          existing.add(it.id);
        }
      }

      _page = next;
      _total = res.total;
      _hasMore = _listCache.length < _total;

      emit(MakananListLoaded(
        items: List.unmodifiable(_listCache),
        total: _total,
        page: _page,
        hasMore: _hasMore,
      ));
    } on ApiException catch (ex) {
      emit(MakananError(ex.message));
    } catch (ex) {
      emit(MakananError('Gagal memuat data lanjut: $ex'));
    }
  }

  Future<void> _onSearchQueryChanged(
    MakananSearchQueryChanged e,
    Emitter<MakananState> emit,
  ) async {
    final q = e.query.trim();
    _lastQuery = q;

    if (q.isEmpty) {
      // kembali ke list cache
      if (_listCache.isEmpty) {
        add(const MakananFetchAll(limit: 50, page: 1, refresh: true));
        return;
      }
      emit(MakananListLoaded(
        items: List.unmodifiable(_listCache),
        total: _total,
        page: _page,
        hasMore: _hasMore,
      ));
      return;
    }

    emit(MakananSearchLoading(q));
    try {
      // top-7 sesuai server (fuzzy top-N)
      final res = await service.search(q, limit: 7);
      if (res.data.isEmpty) {
        emit(const MakananEmpty('Data tidak ditemukan.'));
      } else {
        emit(MakananSearchLoaded(query: q, items: res.data, total: res.total));
      }
    } on ApiException catch (ex) {
      emit(MakananError(ex.message));
    } catch (ex) {
      emit(MakananError('Gagal mencari: $ex'));
    }
  }

  Future<void> _onClearSearch(
    MakananClearSearch e,
    Emitter<MakananState> emit,
  ) async {
    _lastQuery = '';
    if (_listCache.isEmpty) {
      add(const MakananFetchAll(limit: 50, page: 1, refresh: true));
    } else {
      emit(MakananListLoaded(
        items: List.unmodifiable(_listCache),
        total: _total,
        page: _page,
        hasMore: _hasMore,
      ));
    }
  }

  bool get isSearching => _lastQuery.isNotEmpty;
}
