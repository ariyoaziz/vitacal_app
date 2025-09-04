import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:vitacal_app/services/constants.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/models/riwayat_user_models.dart';

/// Exception ringan untuk autentikasi.
/// (Kalau kamu sudah punya kelas serupa di tempat lain, silakan pakai itu dan hapus class ini.)
class AuthException implements Exception {
  final String code; // contoh: 'missing_token', 'invalid_or_expired'
  final String message; // opsional
  const AuthException(this.code, [this.message = '']);
  @override
  String toString() => 'AuthException($code): $message';
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class RiwayatUserService {
  final AuthService authService;
  final http.Client _client;

  RiwayatUserService({
    required this.authService,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _fetchRaw({int days = 7}) async {
    final token = await authService.getAuthToken();

    // 1) Kalau token tidak ada, JANGAN request—langsung silent fail ke caller (bloc)
    if (token == null) {
      throw const AuthException('missing_token', 'Auth token not found');
    }

    final uri = Uri.parse('${AppConstants.baseUrl}/riwayat?days=$days');

    // Log hanya saat token ada (biar nggak spam saat logout)
    debugPrint('DEBUG RIWAYAT_USER_SERVICE: GET $uri');

    try {
      final res = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('DEBUG RIWAYAT_USER_SERVICE: Status ${res.statusCode}');
      if (kDebugMode && res.statusCode != 200) {
        // Body sering berguna saat debug
        debugPrint('DEBUG RIWAYAT_USER_SERVICE: Body ${res.body}');
      }

      // 2) Kalau 401, anggap token invalid/expired → biar bloc bisa transisi ke unauthenticated tanpa dialog
      if (res.statusCode == 401) {
        throw const AuthException('invalid_or_expired', 'Unauthorized (401)');
      }

      if (res.statusCode != 200) {
        throw Exception('Gagal memuat riwayat: ${res.statusCode}');
      }

      final decoded = json.decode(res.body) as Map<String, dynamic>;
      return decoded;
    } on TimeoutException {
      // Jangan munculkan dialog—biar UI bisa tetap “tenang”
      throw Exception('Timeout saat memuat riwayat.');
    } on SocketException {
      throw Exception('Tidak bisa terhubung ke server.');
    }
  }

  // Ambil response bertipe kuat (typed)
  Future<HistoryResponse> getHistory({int days = 7}) async {
    final raw = await _fetchRaw(days: days);
    return HistoryResponse.fromJson(raw);
  }

  // Helper: data untuk KaloriChartCard
  Future<List<Map<String, dynamic>>> getCalorieChartData({int days = 7}) async {
    final hist = await getHistory(days: days);
    return hist.calorieHistory.map((e) => e.toChartPoint()).toList();
  }

  // Helper: data berat untuk chart
  Future<List<Map<String, dynamic>>> getWeightHistory({int days = 7}) async {
    final hist = await getHistory(days: days);
    return hist.weightHistory.map((e) => e.toChartPoint()).toList();
  }

  // Rata-rata rekomendasi
  Future<double> getAvgRecommended({int days = 7}) async {
    final hist = await getHistory(days: days);
    if (hist.calorieHistory.isEmpty) return 0.0;
    final sum =
        hist.calorieHistory.fold<double>(0.0, (acc, e) => acc + e.recommended);
    return sum / hist.calorieHistory.length;
  }
}
