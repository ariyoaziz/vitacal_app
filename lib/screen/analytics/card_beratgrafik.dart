// lib/screen/analytics/card_beratgrafik.dart
// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vitacal_app/themes/colors.dart';

/// Data: [{"date":"YYYY-MM-DD","weight":<num>}]
class CardBeratGrafik extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  /// Callback opsional di header (otomatis tersembunyi kalau null)
  final VoidCallback? onViewDetail;
  final VoidCallback? onDownload;

  const CardBeratGrafik({
    super.key,
    required this.data,
    this.onViewDetail,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    try {
      initializeDateFormatting('id_ID', null);
    } catch (_) {}

    // Ambil 7 data terakhir (tua -> terbaru)
    final displayedData = data.length > 7
        ? data.sublist(data.length - 7)
        : List<Map<String, dynamic>>.from(data);

    if (displayedData.isEmpty) {
      return Card(
        color: AppColors.screen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monitor_weight_rounded,
                        size: 48, color: AppColors.darkGrey.withOpacity(0.35)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada data berat badan.',
                      style: TextStyle(
                        color: AppColors.darkGrey.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tambahkan catatan berat untuk mulai melihat progresmu.',
                      style: TextStyle(
                        color: AppColors.darkGrey.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Spots
    final spots = List<FlSpot>.generate(displayedData.length, (i) {
      final w = (displayedData[i]['weight'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(i.toDouble(), w);
    });

    // Skala Y yang aman & enak dilihat
    final weights = spots.map((s) => s.y).toList();
    double minVal = weights.reduce(math.min);
    double maxVal = weights.reduce(math.max);

    // padding adaptif
    final range = (maxVal - minVal);
    final pad = range < 4 ? 3.0 : math.max(4.0, range * 0.12);
    double minY = (minVal - pad);
    double maxY = (maxVal + pad);
    if (minY < 0) minY = 0;

    // interval Y aman (minimal 1)
    final intervalY = () {
      final r = (maxY - minY);
      if (r <= 0) return 1.0;
      final raw = r / 4;
      // bulatkan ke 0.5 atau 1 terdekat biar cantik
      final step =
          (raw < 5) ? (raw).clamp(1.0, 5.0) : (raw / 5).roundToDouble() * 5;
      return step <= 0 ? 1.0 : step;
    }();

    // rata-rata berat ditampilkan sebagai garis referensi
    final avg = weights.reduce((a, b) => a + b) / weights.length;

    // info terakhir (chip)
    final last = displayedData.last;
    final lastW = (last['weight'] as num?)?.toDouble() ?? 0.0;
    DateTime? lastDate;
    try {
      lastDate = DateTime.parse((last['date'] ?? '') as String);
    } catch (_) {}

    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 11),
            if (lastDate != null)
              Row(
                children: [
                  _miniChip(
                    icon: Icons.trending_up_rounded,
                    label:
                        'Terakhir: ${lastW.toStringAsFixed(1)} kg • ${DateFormat('d MMM yyyy', 'id_ID').format(lastDate)}',
                  ),
                ],
              ),
            const SizedBox(height: 33),
            AspectRatio(
              aspectRatio: 1.25,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.18),
                      strokeWidth: 0.6,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.12),
                      strokeWidth: 0.6,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        interval: intervalY,
                        getTitlesWidget: (v, meta) {
                          if (v < minY || v > maxY) return const SizedBox();
                          return Text(
                            '${v.toStringAsFixed(0)} kg',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.darkGrey),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= displayedData.length)
                            return const SizedBox();
                          final ds = (displayedData[i]['date'] ?? '') as String;
                          DateTime? d;
                          try {
                            d = DateTime.parse(ds);
                          } catch (_) {}
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              d != null
                                  ? DateFormat('dd/MM', 'id_ID').format(d)
                                  : '',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.darkGrey),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // garis utama
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Colors.green.shade600],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final isLast = index == spots.length - 1;
                          return FlDotCirclePainter(
                            radius: isLast ? 5.5 : 4,
                            color: AppColors.screen,
                            strokeWidth: isLast ? 2.5 : 2,
                            strokeColor: isLast
                                ? Colors.green.shade600
                                : AppColors.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.20),
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  // garis rata-rata
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: avg,
                        dashArray: const [6, 6],
                        color: AppColors.primary.withOpacity(0.7),
                        strokeWidth: 1.4,
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 6, bottom: 6),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          labelResolver: (line) =>
                              'Rata-rata: ${avg.toStringAsFixed(1)} kg',
                        ),
                      ),
                    ],
                  ),
                  // interaksi sentuh
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator: (bar, spotIndexes) {
                      return spotIndexes.map((i) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                              color: AppColors.primary.withOpacity(0.35),
                              strokeWidth: 1),
                          FlDotData(
                            show: true,
                            getDotPainter: (s, p, b, idx) => FlDotCirclePainter(
                              radius: 6,
                              color: AppColors.screen,
                              strokeWidth: 2.8,
                              strokeColor: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipColor: (_) => AppColors.cream,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((t) {
                          final i = t.spotIndex;
                          final ds = (displayedData[i]['date'] ?? '') as String;
                          DateTime? d;
                          try {
                            d = DateTime.parse(ds);
                          } catch (_) {}
                          final dateText = d != null
                              ? DateFormat('EEEE, d MMM yyyy', 'id_ID')
                                  .format(d)
                              : ds;

                          return LineTooltipItem(
                            '${t.y.toStringAsFixed(1)} kg\n',
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGrey,
                            ),
                            children: [
                              TextSpan(
                                text: dateText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ],
                            textAlign: TextAlign.left,
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.monitor_weight_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Berat Badan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
          ),
        ),
        const Spacer(),
        if (onViewDetail != null)
          TextButton.icon(
            onPressed: onViewDetail,
            label: const Text(
              'Lihat Detail',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  Widget _miniChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
