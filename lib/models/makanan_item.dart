class MakananItem {
  final int id;
  final String nama;
  final double energiKal; // "energi (kal)"
  final double proteinG; // "protein (g)"
  final double lemakG; // "lemak (g)"
  final double karbohidratG; // "karbohidrat (g)"
  final String? satuan;
  final double? takaranSaji;

  const MakananItem({
    required this.id,
    required this.nama,
    required this.energiKal,
    required this.proteinG,
    required this.lemakG,
    required this.karbohidratG,
    this.satuan,
    this.takaranSaji,
  });

  static double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return fallback;
    return double.tryParse(s) ?? fallback;
  }

  factory MakananItem.fromJson(Map<String, dynamic> json) {
    return MakananItem(
      id: (json['id'] as num).toInt(),
      nama: (json['nama'] ?? '').toString(),
      energiKal: _toDouble(json['energi (kal)']),
      proteinG: _toDouble(json['protein (g)']),
      lemakG: _toDouble(json['lemak (g)']),
      karbohidratG: _toDouble(json['karbohidrat (g)']),
      satuan: json['satuan']?.toString(),
      takaranSaji:
          json['takaran_saji'] == null ? null : _toDouble(json['takaran_saji']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'energi (kal)': energiKal,
        'protein (g)': proteinG,
        'lemak (g)': lemakG,
        'karbohidrat (g)': karbohidratG,
        'satuan': satuan,
        'takaran_saji': takaranSaji,
      };
}
