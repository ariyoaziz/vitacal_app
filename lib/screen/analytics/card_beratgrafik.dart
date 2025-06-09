// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal
import 'package:intl/date_symbol_data_local.dart'; // Untuk inisialisasi data lokal

/// Widget untuk menampilkan grafik berat badan.
/// Menerima data berat badan melalui properti 'data'.
class CardBeratGrafik extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const CardBeratGrafik({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);

    final List<Map<String, dynamic>> displayedData =
        data.reversed.take(7).toList().reversed.toList();
    // Jika Anda ingin menampilkan semua data yang tersedia, cukup gunakan 'data' langsung.
    // final List<Map<String, dynamic>> displayedData = data;

    // Memastikan ada data untuk ditampilkan
    if (displayedData.isEmpty) {
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
                  'Tidak ada data berat badan tersedia.',
                  style: TextStyle(color: AppColors.darkGrey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mengonversi displayedData menjadi FlSpot untuk LineChart
    final List<FlSpot> spots = List.generate(displayedData.length, (index) {
      final item = displayedData[index];
      final double weight = (item['weight'] as num).toDouble();
      return FlSpot(
          index.toDouble(), weight); // X-axis sebagai index 0, 1, 2...
    });

    // Menentukan nilai minimal dan maksimal Y untuk grafik secara dinamis
    double minY = (displayedData
                .map((e) => (e['weight'] as num).toDouble())
                .reduce((value, element) => value < element ? value : element) -
            5)
        .floorToDouble(); // Kurangi sedikit untuk margin bawah
    double maxY = (displayedData
                .map((e) => (e['weight'] as num).toDouble())
                .reduce((value, element) => value > element ? value : element) +
            5)
        .ceilToDouble(); // Tambah sedikit untuk margin atas

    if (minY < 0) minY = 0; // Memastikan minY tidak kurang dari 0

    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),

            // Grafik Berat Badan
            AspectRatio(
              aspectRatio: 0.8,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) / 4, // Interval dinamis Y axis
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()} Kg',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayedData.length) {
                            // Ambil tanggal dari data dan format menjadi DD/MM
                            final dateString =
                                displayedData[index]['date'] as String;
                            final dateTime = DateTime.parse(dateString);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd/MM').format(
                                    dateTime), // Output: '09/06', '10/06'
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
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Colors.green.shade600],
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.primary,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.cream,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} Kg',
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
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

  // Fungsi helper untuk header
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.orangeAccent,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(Icons.monitor_weight_rounded,
              color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        // --- PERBAIKAN: Judul yang lebih spesifik ---
        const Text(
          'Berat Badan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // --- AKHIR PERBAIKAN ---
        const Spacer(),
      ],
    );
  }
}
