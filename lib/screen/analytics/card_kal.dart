// lib/screen/analytics/card_kal.dart
// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, unused_local_variable, no_leading_underscores_for_local_identifiers

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

    // hitung global posisi
    final Offset global = box.localToGlobal(localPos);
    final Size screen = MediaQuery.of(context).size;

    // perkiraan dimensi tooltip
    const double tipW = 240;
    const double tipH = 60; // rata-rata; cukup buat 2–3 baris
    const double pad = 12;

    // clamp agar tidak keluar layar
    double left = global.dx - tipW * 0.5;
    double top = global.dy - 140;

    if (left < pad) left = pad;
    if (left + tipW > screen.width - pad) left = screen.width - tipW - pad;
    if (top < pad) top = global.dy + 16; // kalau ke-atas mepet, taruh di bawah

    _tooltipEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: left,
        top: top,
        width: tipW,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.darkGrey,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_tooltipEntry!);
    Future.delayed(const Duration(milliseconds: 1600), _removeTooltip);
  }

  @override
  Widget build(BuildContext context) {
    try {
      initializeDateFormatting('id_ID', null);
    } catch (_) {}

    // 1) Range Sen–Min minggu ini
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
    final weekIso =
        weekDates.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();

    // 2) ambil entry terakhir per tanggal
    final Map<String, Map<String, dynamic>> lastEntryByDate = {};
    for (final e in widget.data) {
      final k = (e['date'] as String?) ?? '';
      if (k.isEmpty) continue;
      lastEntryByDate[k] = e; // last-write-wins
    }

    // 3) carry-forward rekomendasi
    final List<Map<String, dynamic>> weeklyData = [];
    double lastRecommended = 0.0;
    bool accountActive = false;

    for (final key in weekIso) {
      final raw = lastEntryByDate[key];

      final double consumed = (raw?['calories'] as num?)?.toDouble() ?? 0.0;
      final double? recSnap = (raw?['recommended'] as num?)?.toDouble();

      if (recSnap != null && recSnap > 0) {
        lastRecommended = recSnap;
        accountActive = true;
      }

      final double recommendedToday = accountActive ? lastRecommended : 0.0;
      final double deficit = recommendedToday - consumed;

      weeklyData.add({
        'date': key,
        'calories': consumed,
        'recommended': recommendedToday,
        'deficit': deficit,
        'isBeforeAccount': !accountActive,
      });
    }

    // 4) hitung maxY dan rata2 rekomendasi (skip sebelum aktif)
    double maxY = 0.0;
    double sumRec = 0.0;
    int cntRec = 0;

    for (final e in weeklyData) {
      final c = (e['calories'] as double);
      final r = (e['recommended'] as double);
      final before = e['isBeforeAccount'] == true;

      if (c > maxY) maxY = c;
      if (r > maxY) maxY = r;
      if (!before && r > 0) {
        sumRec += r;
        cntRec += 1;
      }
    }

    // bulatkan ke atas kelipatan 200 (biar grid rapi)
    double _ceilTo200(double v) {
      if (v <= 0) return 1200;
      final int step = 200;
      final int k = ((v + step) / step).floor();
      return (k * step).toDouble();
    }

    maxY = _ceilTo200(maxY);
    if (maxY < 1200) maxY = 1200; // baseline
    final avgRecommended = cntRec > 0 ? (sumRec / cntRec) : 0.0;

    // 5) bar data
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
            width: isTouched ? 24 : 22,
            borderRadius: BorderRadius.circular(6),
            borderSide: isTouched
                ? const BorderSide(color: Colors.white, width: 1.1)
                : BorderSide.none,
            gradient: LinearGradient(
              colors: [
                before
                    ? Colors.grey.withOpacity(.25)
                    : AppColors.primary.withOpacity(isTouched ? 1 : .9),
                before
                    ? Colors.grey.withOpacity(.35)
                    : AppColors.primary.withOpacity(isTouched ? 1 : .95),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: recommended,
              color: Colors.grey.withOpacity(0.18),
            ),
          ),
        ],
      );
    });

    final bool allZero = weeklyData.every((e) =>
        (e['calories'] as double) <= 0 && (e['recommended'] as double) <= 0);

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
            _buildHeader(context),
            const SizedBox(height: 33),
            if (allZero) ...[
              _emptyState(),
            ] else ...[
              AspectRatio(
                aspectRatio: 1.35,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barGroups: barGroups,
                    barTouchData: BarTouchData(
                      enabled: true,
                      handleBuiltInTouches: false,
                      touchExtraThreshold: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 160,
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
                          interval: (maxY / 4).clamp(200.0, 800.0),
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
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= weeklyData.length) {
                              return const SizedBox();
                            }
                            final ds = weeklyData[i]['date'] as String;
                            DateTime? d;
                            try {
                              d = DateTime.parse(ds);
                            } catch (_) {}
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
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
                        color: Colors.grey.withOpacity(0.18),
                        strokeWidth: 0.6,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        if (avgRecommended > 0)
                          HorizontalLine(
                            y: avgRecommended,
                            dashArray: const [5, 5],
                            color: AppColors.primary.withOpacity(0.75),
                            strokeWidth: 1.3,
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              padding:
                                  const EdgeInsets.only(right: 6, bottom: 6),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                              labelResolver: (line) =>
                                  'Rata-rata rekomendasi: ${line.y.toInt()}',
                            ),
                          ),
                      ],
                    ),
                  ),
                  key: _chartKey,
                  swapAnimationDuration: const Duration(milliseconds: 280),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
              ),
              const SizedBox(height: 21),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  _LegendDot(color: AppColors.primary, label: ' Konsumsi'),
                  SizedBox(width: 12),
                  _LegendDot(color: Colors.grey, label: ' Rekomendasi'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(.05)),
      ),
      child: Column(
        children: const [
          Icon(Icons.insights_outlined, color: AppColors.mediumGrey, size: 28),
          SizedBox(height: 10),
          Text(
            'Belum ada data minggu ini',
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tambahkan makanan untuk melihat progres harianmu.',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
          TextButton(
            onPressed: widget.onViewDetail,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Lihat detail',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 0),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.darkGrey)),
      ],
    );
  }
}
