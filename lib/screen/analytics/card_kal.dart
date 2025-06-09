// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal
import 'package:intl/date_symbol_data_local.dart'; // Untuk inisialisasi data lokal

/// Widget untuk menampilkan grafik kalori harian.
/// Menerima data kalori melalui properti 'data'.
class KaloriChartCard extends StatelessWidget {
  // Data kalori yang akan ditampilkan pada grafik.
  // Diharapkan berupa List of Map dengan format:
  // [{"date": "YYYY-MM-DD", "calories": VALUE_KALORI}]
  final List<Map<String, dynamic>> data;

  const KaloriChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Pastikan data lokal diinisialisasi untuk format hari
    // Ini biasanya dilakukan di main.dart, tapi aman di sini juga
    // if (!Intl.defaultLocale?.startsWith('id') ?? true) { // Hanya inisialisasi jika belum
    initializeDateFormatting('id_ID', null);
    // }

    // Ambil hanya 7 hari pertama dari data untuk tampilan mingguan
    final List<Map<String, dynamic>> weeklyData = data.take(7).toList();

    // Memastikan ada data untuk ditampilkan, jika tidak, tampilkan placeholder.
    if (weeklyData.isEmpty) {
      // Cek weeklyData yang sudah difilter
      return Card(
        color: AppColors.screen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Text(
                  'Tidak ada data kalori mingguan tersedia.',
                  style: TextStyle(color: AppColors.darkGrey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mengonversi weeklyData menjadi BarChartGroupData
    final List<BarChartGroupData> barGroups =
        List.generate(weeklyData.length, (index) {
      final item = weeklyData[index];
      final double calories = (item['calories'] as num).toDouble();
      final Color barColor = AppColors.primary;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: calories,
            width: 18,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [barColor.withOpacity(0.8), barColor],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
        showingTooltipIndicators: [],
      );
    });

    // Menentukan nilai maksimal Y untuk grafik dari weeklyData
    double maxY = weeklyData
            .map((e) => (e['calories'] as num).toDouble())
            .reduce((value, element) => value > element ? value : element) +
        500;

    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            // Bar Chart
            AspectRatio(
              aspectRatio: 1.1,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      getTooltipColor: (_) => AppColors.cream,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} Kal',
                          const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 500, // Interval pada sumbu Y
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < weeklyData.length) {
                            final dateString =
                                weeklyData[index]['date'] as String;
                            final dateTime = DateTime.parse(dateString);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                // --- PERBAIKAN: Format hari menggunakan locale 'id_ID' ---
                                DateFormat('EE', 'id_ID').format(
                                    dateTime), // Output: Sen, Sel, Rab, dst.
                                // --- AKHIR PERBAIKAN ---
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  maxY: maxY,
                  barGroups: barGroups,
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: 2000,
                      color: Colors.grey.shade500,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 10),
                        labelResolver: (line) => 'Target: ${line.y.toInt()}',
                      ),
                    ),
                  ]),
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
        const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
        const SizedBox(width: 10),
        const Text(
          'Kalori Harian',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
