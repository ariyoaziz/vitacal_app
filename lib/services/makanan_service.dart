// lib/services/makanan_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:vitacal_app/services/constants.dart';
import 'package:vitacal_app/models/makanan_item.dart';
import 'package:vitacal_app/models/api_list_response.dart';
import 'package:vitacal_app/services/auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class MakananService {
  final String baseUrl;
  final http.Client _client;
  final AuthService? _auth;
  final String listPath;
  final String searchPath;
  final Duration _timeout;

  MakananService({
    String? baseUrl,
    http.Client? client,
    AuthService? authService,
    String? listPath,
    String? searchPath,
    Duration timeout = const Duration(seconds: 10),
  })  : baseUrl = (baseUrl ?? AppConstants.baseUrl),
        _client = client ?? http.Client(),
        _auth = authService,
        listPath = (listPath ?? '/gizi/food'),
        searchPath = (searchPath ?? '/gizi/search'),
        _timeout = timeout;

  factory MakananService.fromConstants({
    http.Client? client,
    AuthService? authService,
    Duration timeout = const Duration(seconds: 10),
  }) {
    return MakananService(
      baseUrl: AppConstants.baseUrl,
      client: client,
      authService: authService,
      listPath: '/gizi/food',
      searchPath: '/gizi/search',
      timeout: timeout,
    );
  }

  Uri _uri(String path, [Map<String, dynamic>? q]) {
    final u = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$u$p').replace(
      queryParameters: q?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  Future<Map<String, String>> _headers() async {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_auth != null) {
      final token = await _auth.getAuthToken();
      if (token != null && token.isNotEmpty) {
        h['Authorization'] = 'Bearer $token';
      }
    }
    return h;
  }

  ApiListResponse<MakananItem> _parse(Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString();
    final message = (json['message'] ?? '').toString();
    final total = (json['total'] is num) ? (json['total'] as num).toInt() : 0;
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => MakananItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return ApiListResponse<MakananItem>(
      status: status,
      message: message,
      total: total,
      data: items,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final resp =
        await _client.get(uri, headers: await _headers()).timeout(_timeout);
    final code = resp.statusCode;
    final bodyBytes = resp.bodyBytes;
    final body = bodyBytes.isEmpty ? '{}' : utf8.decode(bodyBytes);

    // Validasi konten
    final contentType = resp.headers['content-type'] ?? '';
    final looksLikeJson = contentType.contains('application/json') ||
        body.trim().startsWith('{') ||
        body.trim().startsWith('[');

    if (!looksLikeJson) {
      final snippet = body.length > 180 ? '${body.substring(0, 180)}…' : body;
      throw ApiException(
        'Respon server tidak valid (bukan JSON). '
        'Cek endpoint: ${uri.path} (HTTP $code). Cuplikan: $snippet',
        statusCode: code,
      );
    }

    Map<String, dynamic> map;
    try {
      map = json.decode(body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException(
        'Respon server tidak valid (gagal parse JSON). '
        'Cek endpoint: ${uri.path} (HTTP $code).',
        statusCode: code,
      );
    }

    // Jika HTTP error, coba angkat pesan dari body
    if (code >= 400) {
      final msg = (map['message'] ?? 'HTTP $code error').toString();
      throw ApiException(msg, statusCode: code);
    }
    return map;
  }

  /// GET /gizi/food?limit=&page=&recommended=&random=
  Future<ApiListResponse<MakananItem>> getAll({
    int? limit,
    int? page,
    bool? recommended,
    bool? random,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (limit != null) qp['limit'] = limit;
      if (page != null) qp['page'] = page;
      if (recommended != null) qp['recommended'] = recommended;
      if (random != null) qp['random'] = random;

      final uri = _uri(listPath, qp.isEmpty ? null : qp);
      final map = await _getJson(uri);

      // Banyak backend custom mengembalikan 200 meskipun status != 'success'.
      // Selama ada `data`, kita parse saja.
      if (map.containsKey('data')) return _parse(map);
      throw ApiException(map['message']?.toString() ?? 'Gagal memuat data');
    } on TimeoutException {
      throw ApiException(
          'Permintaan ke server timeout. Coba ulang beberapa saat lagi.');
    } on SocketException {
      throw ApiException(
        'Tidak bisa terhubung ke server ($baseUrl). Pastikan device & server satu jaringan.',
      );
    } on http.ClientException catch (e) {
      throw ApiException('Gagal memuat data: ${e.message}');
    }
  }

  /// GET /gizi/search?name=&limit=
  /// Pakai param `name` (sesuai log server). Default limit top-7.
  Future<ApiListResponse<MakananItem>> search(
    String query, {
    int limit = 7,
  }) async {
    try {
      final uri = _uri(searchPath, {'name': query, 'limit': limit});
      final map = await _getJson(uri);

      final status = (map['status'] ?? '').toString().toLowerCase();
      if (status == 'not_found') {
        return ApiListResponse<MakananItem>(
          status: status,
          message: (map['message'] ?? 'Data tidak ditemukan').toString(),
          total: 0,
          data: const [],
        );
      }
      return _parse(map);
    } on TimeoutException {
      throw ApiException(
          'Permintaan ke server timeout. Coba ulang beberapa saat lagi.');
    } on SocketException {
      throw ApiException(
        'Tidak bisa terhubung ke server ($baseUrl). Pastikan device & server satu jaringan.',
      );
    } on http.ClientException catch (e) {
      throw ApiException('Gagal mencari data: ${e.message}');
    }
  }

  /// Helper: rekomendasi dari server
  Future<ApiListResponse<MakananItem>> getRecommended({int? limit}) {
    return getAll(limit: limit, recommended: true);
  }

  /// Helper: random dari server (untuk state awal jika belum mencari)
  Future<ApiListResponse<MakananItem>> getRandom({int? limit}) {
    return getAll(limit: limit, random: true);
  }

  void dispose() => _client.close();
}
