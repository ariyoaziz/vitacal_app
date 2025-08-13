// lib/screen/analytics/card_kal.dart
// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vitacal_app/themes/colors.dart';

class KaloriChartCard extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final VoidCallback? onViewDetail;
  final VoidCallback? onDownload;

  const KaloriChartCard({
    super.key,
    required this.data,
    this.onViewDetail,
    this.onDownload,
  });

  @override
  State<KaloriChartCard> createState() => _KaloriChartCardState();
}

class _KaloriChartCardState extends State<KaloriChartCard> {
  final GlobalKey _chartKey = GlobalKey();
  OverlayEntry? _tooltipEntry;
  int? _touchedGroupIndex;

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  void _removeTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  void _showTooltipAt(Offset localPos, String text) {
    _removeTooltip();

    final box = _chartKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final global = box.localToGlobal(localPos);

    _tooltipEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: global.dx - 30,
        top: global.dy - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.darkGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_tooltipEntry!);
    Future.delayed(const Duration(seconds: 2), _removeTooltip);
  }

  @override
  Widget build(BuildContext context) {
    try {
      initializeDateFormatting('id_ID', null);
    } catch (_) {}

    // 1) Range Senin–Minggu minggu ini
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday =
        today.subtract(Duration(days: (today.weekday - DateTime.monday)));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
    final weekIso =
        weekDates.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();

    // 2) Index data by date
    final Map<String, Map<String, dynamic>> byDate = {};
    for (final e in widget.data) {
      final k = (e['date'] as String?) ?? '';
      if (k.isNotEmpty) byDate[k] = e;
    }

    // 3) Bentuk 7 item fix Sen–Ming
    final List<Map<String, dynamic>> weeklyData = [];
    for (final key in weekIso) {
      final raw = byDate[key];
      final consumed = (raw?['calories'] as num?)?.toDouble() ?? 0.0;
      final recommended = (raw?['recommended'] as num?)?.toDouble() ?? 0.0;
      final deficit =
          (raw?['deficit'] as num?)?.toDouble() ?? (recommended - consumed);
      final isBeforeAccount = (raw?['isBeforeAccount'] == true) ||
          (raw?['is_before_account'] == true);

      weeklyData.add({
        'date': key,
        'calories': consumed,
        'recommended': recommended,
        'deficit': deficit,
        'isBeforeAccount': isBeforeAccount,
      });
    }

    // 4) Skala & rata-rata rekomendasi (tanpa “paksa bagi 7” kalau data belum ada)
    double maxY = 0.0;
    double sumRecommended = 0.0;
    int countRecommended = 0;
    double lastNonZeroRecommended = 0.0;

    for (final e in weeklyData) {
      final consumed = (e['calories'] as double);
      final recRaw = (e['recommended'] as double);
      final isBefore = e['isBeforeAccount'] == true;

      if (consumed > maxY) maxY = consumed;
      if (recRaw > maxY) maxY = recRaw;

      if (isBefore) continue;

      final recEff = recRaw > 0
          ? recRaw
          : (lastNonZeroRecommended > 0 ? lastNonZeroRecommended : 0.0);
      if (recEff > 0) {
        sumRecommended += recEff;
        countRecommended += 1;
        lastNonZeroRecommended = recEff;
      }
    }

    // buffer + baseline skala
    maxY = ((maxY + 400).clamp(1200.0, double.infinity)).toDouble();

    final double avgRecommended =
        countRecommended > 0 ? (sumRecommended / countRecommended) : 0.0;

    // 5) Satu rod per hari (konsumsi), background rod = rekomendasi
    final List<BarChartGroupData> barGroups =
        List.generate(weeklyData.length, (i) {
      final item = weeklyData[i];
      final consumed = (item['calories'] as double);
      final recommended = (item['recommended'] as double);
      final before = item['isBeforeAccount'] == true;

      final bool isTouched = _touchedGroupIndex == i;

      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: consumed,
            width: isTouched ? 26 : 24,
            borderRadius: BorderRadius.circular(6),
            borderSide: isTouched
                ? const BorderSide(color: Colors.white, width: 1.2)
                : BorderSide.none,
            gradient: LinearGradient(
              colors: [
                (before
                    ? Colors.grey.withOpacity(0.25)
                    : AppColors.primary.withOpacity(isTouched ? 1.0 : 0.85)),
                (before ? Colors.grey.withOpacity(0.35) : AppColors.primary),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: recommended,
              color: Colors.grey.withOpacity(0.45),
            ),
          ),
        ],
      );
    });

    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 33),
            AspectRatio(
              aspectRatio: 1.2,
              child: BarChart(
                // POSISIONAL DULU, key kemudian:
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false, // kita pakai tooltip custom
                    touchExtraThreshold: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 200,
                    ),
                    touchCallback: (event, response) {
                      if (event is FlPointerExitEvent ||
                          event is FlTapUpEvent ||
                          event is FlPanEndEvent) {
                        setState(() => _touchedGroupIndex = null);
                        _removeTooltip();
                        return;
                      }

                      final spot = response?.spot;
                      if (spot == null) return;

                      final i = spot.touchedBarGroupIndex;
                      setState(() => _touchedGroupIndex = i);

                      final row = weeklyData[i];
                      final dateStr = (row['date'] as String?) ?? '';
                      DateTime? dt;
                      try {
                        dt = DateTime.parse(dateStr);
                      } catch (_) {}
                      final tanggal = (dt != null)
                          ? DateFormat('EEEE, d MMM yyyy', 'id_ID').format(dt)
                          : dateStr;

                      final bool isBefore = (row['isBeforeAccount'] == true);
                      final double consumed =
                          ((row['calories'] ?? 0) as num).toDouble();
                      final double recommended =
                          ((row['recommended'] ?? 0) as num).toDouble();

                      final text = isBefore
                          ? 'Belum ada progres'
                          : '$tanggal\n'
                              '• Konsumsi: ${consumed.toInt()} Kkal\n'
                              '• Rekomendasi: ${recommended.toInt()} Kkal';

                      final Offset localPos =
                          event.localPosition ?? Offset.zero;
                      _showTooltipAt(localPos, text);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: (maxY / 4).clamp(200.0, 800.0).toDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value <= 0) return const SizedBox();
                          return Text(
                            value.toInt().toString(),
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
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= weeklyData.length)
                            return const SizedBox();
                          final ds = weeklyData[i]['date'] as String;
                          DateTime? d;
                          try {
                            d = DateTime.parse(ds);
                          } catch (_) {}
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              d != null
                                  ? DateFormat('EEE', 'id_ID').format(d)
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
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 0.5,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: avgRecommended.isFinite ? avgRecommended : 0.0,
                        dashArray: const [5, 5],
                        color: AppColors.primary.withOpacity(0.7),
                        strokeWidth: 1.5,
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 6, bottom: 6),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                          labelResolver: (line) =>
                              'Rata-rata Rekomendasi: ${line.y.toInt()}',
                        ),
                      ),
                    ],
                  ),
                ),
                key: _chartKey, // <- key DITEMPATKAN SETELAH data (named arg)
                swapAnimationDuration: const Duration(milliseconds: 300),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),
            const SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                _LegendDot(color: AppColors.primary, label: 'Konsumsi'),
                SizedBox(width: 12),
                _LegendDot(color: Colors.grey, label: 'Rekomendasi'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 22),
        ),
        const SizedBox(width: 11),
        const Text(
          'Kalori Harian',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
          ),
        ),
        const Spacer(),
        if (widget.onViewDetail != null)
          TextButton.icon(
            onPressed: widget.onViewDetail,
            label: const Text('Lihat detail',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        if (widget.onDownload != null) ...[
          const SizedBox(width: 6),
          IconButton(
            onPressed: widget.onDownload,
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            tooltip: 'Unduh',
            splashRadius: 20,
          ),
        ],
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.darkGrey)),
      ],
    );
  }
}
