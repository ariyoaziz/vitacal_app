// lib/screen/analytics/card_beratgrafik.dart
// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, no_leading_underscores_for_local_identifiers

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vitacal_app/themes/colors.dart';

/// Data contoh: [{"date":"YYYY-MM-DD","weight":<num>}]
class CardBeratGrafik extends StatelessWidget {
  final List<Map<String, dynamic>> data;
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

    // Ambil 7 data terakhir (urut lama -> baru)
    final displayedData = data.length > 7
        ? data.sublist(data.length - 7)
        : List<Map<String, dynamic>>.from(data);

    if (displayedData.isEmpty) {
      return Card(
        color: AppColors.screen,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(.06), width: 1),
        ),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 33),
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monitor_weight_rounded,
                        size: 40, color: AppColors.darkGrey.withOpacity(0.35)),
                    const SizedBox(height: 10),
                    Text(
                      'Belum ada data berat badan',
                      style: TextStyle(
                        color: AppColors.darkGrey.withOpacity(0.9),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tambahkan catatan berat untuk mulai melihat grafik.',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12.5,
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

    // Range Y yang enak dilihat
    final ys = spots.map((s) => s.y).toList();
    double minVal = ys.reduce(math.min);
    double maxVal = ys.reduce(math.max);
    final range = (maxVal - minVal);

    // padding adaptif (sedikit tapi cukup)
    final pad = range < 4 ? 2.5 : math.max(3.0, range * 0.12);
    double minY = (minVal - pad);
    double maxY = (maxVal + pad);
    if (minY < 0) minY = 0;

    // step sumbu Y yang “nice”
    double _niceStep(double r) {
      if (r <= 0) return 1.0;
      final raw = r / 4;
      // bulatkan ke 0.5/1/2/5 terdekat
      final candidates = [0.5, 1.0, 2.0, 5.0, 10.0];
      double best = candidates.first;
      double bestDiff = (raw - best).abs();
      for (final c in candidates) {
        final diff = (raw - c).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          best = c;
        }
      }
      return best;
    }

    final intervalY = _niceStep(maxY - minY);

    // rata-rata berat (garis referensi)
    final avg = ys.reduce((a, b) => a + b) / ys.length;

    // info terakhir (chip)
    final last = displayedData.last;
    final lastW = (last['weight'] as num?)?.toDouble() ?? 0.0;
    DateTime? lastDate;
    try {
      lastDate = DateTime.parse((last['date'] ?? '') as String);
    } catch (_) {}

    // delta dari data pertama ke terakhir (opsional kecil di header)
    final firstW = (displayedData.first['weight'] as num?)?.toDouble() ?? lastW;
    final delta = (lastW - firstW);
    final deltaStr =
        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg dari awal';

    return Card(
      color: AppColors.screen,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.black.withOpacity(.06), width: 1),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(actions: [
              if (onViewDetail != null)
                TextButton(
                  onPressed: onViewDetail,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Lihat detail',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              if (onDownload != null)
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded,
                      color: AppColors.primary),
                  splashRadius: 20,
                  tooltip: 'Unduh',
                ),
            ]),
            const SizedBox(height: 21),

            // chip info terakhir + delta sederhana
            if (lastDate != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _miniChip(
                    icon: Icons.event,
                    label:
                        'Terakhir: ${lastW.toStringAsFixed(1)} kg • ${DateFormat('d MMM yyyy', 'id_ID').format(lastDate)}',
                  ),
                  _miniChip(
                    icon: delta >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    label: deltaStr,
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
                            '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)} kg',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.darkGrey),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= displayedData.length) {
                            return const SizedBox();
                          }
                          final ds = (displayedData[i]['date'] ?? '') as String;
                          DateTime? d;
                          try {
                            d = DateTime.parse(ds);
                          } catch (_) {}
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
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
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      barWidth: 3,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          Colors.green.shade600,
                        ],
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
                            AppColors.primary.withOpacity(0.18),
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
                        strokeWidth: 1.3,
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
                                style: const TextStyle(
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

  Widget _buildHeader({List<Widget> actions = const []}) {
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
        ...actions,
      ],
    );
  }

  Widget _miniChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
