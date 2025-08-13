class CalorieDay {
  final DateTime date;
  final double recommended;
  final double consumed;
  final double deficit;

  CalorieDay({
    required this.date,
    required this.recommended,
    required this.consumed,
    required this.deficit,
  });

  factory CalorieDay.fromJson(Map<String, dynamic> json) {
    return CalorieDay(
      date: DateTime.parse(json['date'] as String),
      recommended: (json['recommended'] ?? 0).toDouble(),
      consumed: (json['consumed'] ?? 0).toDouble(),
      deficit: (json['deficit'] ?? 0).toDouble(),
    );
  }

  /// Supaya tetap kompatibel dengan KaloriChartCard yang butuh Map
  Map<String, dynamic> toChartPoint() => {
        'date': date.toIso8601String().split('T').first,
        'calories': consumed, // dipakai sebagai tinggi bar
        'recommended': recommended, // kalau mau dipakai garis target dinamis
        'deficit': deficit,
      };
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toChartPoint() => {
        'date': date.toIso8601String().split('T').first,
        'weight': weight,
      };
}

class HistoryResponse {
  final List<CalorieDay> calorieHistory;
  final List<WeightEntry> weightHistory;

  HistoryResponse({
    required this.calorieHistory,
    required this.weightHistory,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    final cal = (json['calorie_history'] as List<dynamic>? ?? [])
        .map((e) => CalorieDay.fromJson(e as Map<String, dynamic>))
        .toList();

    final wt = (json['weight_history'] as List<dynamic>? ?? [])
        .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return HistoryResponse(calorieHistory: cal, weightHistory: wt);
  }
}
