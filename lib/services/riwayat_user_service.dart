import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:vitacal_app/services/constants.dart';
import 'package:vitacal_app/services/auth_service.dart';
import 'package:vitacal_app/models/riwayat_user_models.dart';

class RiwayatUserService {
  final AuthService authService;
  final http.Client _client;

  RiwayatUserService({
    required this.authService,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _fetchRaw({int days = 7}) async {
    final token = await authService.getAuthToken();
    final uri = Uri.parse('${AppConstants.baseUrl}/riwayat?days=$days');

    debugPrint('DEBUG RIWAYAT_USER_SERVICE: GET $uri');
    final res = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    debugPrint('DEBUG RIWAYAT_USER_SERVICE: Status ${res.statusCode}');
    debugPrint('DEBUG RIWAYAT_USER_SERVICE: Body ${res.body}');

    if (res.statusCode == 401) {
      throw Exception('Unauthorized (401)');
    }
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat riwayat: ${res.statusCode} ${res.body}');
    }

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    return decoded;
  }

  /// Ambil response bertipe kuat (typed)
  Future<HistoryResponse> getHistory({int days = 7}) async {
    final raw = await _fetchRaw(days: days);
    return HistoryResponse.fromJson(raw);
  }

  /// Helper: data untuk KaloriChartCard (pakai Map agar kompatibel)
  Future<List<Map<String, dynamic>>> getCalorieChartData({int days = 7}) async {
    final hist = await getHistory(days: days);
    return hist.calorieHistory.map((e) => e.toChartPoint()).toList();
  }

  /// Helper: data berat versi Map (kalau kamu punya grafik berat yang expect Map)
  Future<List<Map<String, dynamic>>> getWeightHistory({int days = 7}) async {
    final hist = await getHistory(days: days);
    return hist.weightHistory.map((e) => e.toChartPoint()).toList();
  }

  /// Rata-rata rekomendasi untuk periode
  Future<double> getAvgRecommended({int days = 7}) async {
    final hist = await getHistory(days: days);
    if (hist.calorieHistory.isEmpty) return 0.0;

    final sum =
        hist.calorieHistory.fold<double>(0.0, (acc, e) => acc + e.recommended);
    return sum / hist.calorieHistory.length;
  }
}
