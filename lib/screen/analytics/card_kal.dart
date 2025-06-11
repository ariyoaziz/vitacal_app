// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

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
    initializeDateFormatting('id_ID', null);

    // Ambil hanya 7 hari terakhir dari data untuk tampilan mingguan
    // Jika data tidak lebih dari 7, ambil semua yang ada
    final List<Map<String, dynamic>> weeklyData =
        data.length > 7 ? data.sublist(data.length - 7) : List.from(data);

    // Memastikan ada data untuk ditampilkan, jika tidak, tampilkan placeholder.
    if (weeklyData.isEmpty) {
      return Card(
        color: AppColors.screen,
        // Radius kartu konsisten 24, elevation 2
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(
              24), // Padding yang lebih besar dan konsisten
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
                  style: TextStyle(
                      color: AppColors.darkGrey.withOpacity(0.7),
                      fontSize: 14), // Gaya teks disesuaikan
                  textAlign: TextAlign.center,
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
        // showingTooltipIndicators: [], // Dihapus untuk menggunakan touchTooltipData
      );
    });

    // Menentukan nilai maksimal Y untuk grafik dari weeklyData
    // Menambahkan sedikit buffer di atas nilai tertinggi
    double maxY = weeklyData
        .map((e) => (e['calories'] as num).toDouble())
        .reduce((value, element) => value > element ? value : element);
    if (maxY < 1000)
      maxY =
          1000; // Pastikan minimal maxY agar skala tidak terlalu rapat untuk nilai kecil
    maxY += 500; // Buffer 500 kalori di atas nilai tertinggi

    return Card(
      color: AppColors.screen,
      // Radius kartu konsisten 24, elevation 2
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.all(24), // Padding yang lebih besar dan konsisten
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            // Bar Chart
            AspectRatio(
              aspectRatio: 1.2, // Aspek rasio sedikit disesuaikan
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
                      getTooltipColor: (_) => AppColors.darkGrey
                          .withOpacity(0.9), // Warna tooltip gelap
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        // Mengambil tanggal dari data asli untuk tooltip
                        final dateString =
                            weeklyData[groupIndex]['date'] as String;
                        final dateTime = DateTime.parse(dateString);
                        final formattedDate = DateFormat('EEEE, d MMM', 'id_ID')
                            .format(
                                dateTime); // Format tanggal lengkap di tooltip

                        return BarTooltipItem(
                          '${rod.toY.toInt()} Kkal\n$formattedDate', // Tampilkan kalori dan tanggal
                          const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white, // Warna teks tooltip putih
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY / 4)
                            .roundToDouble(), // Interval sumbu Y otomatis dibagi 4
                        getTitlesWidget: (value, meta) {
                          if (value == 0)
                            return const Text(''); // Jangan tampilkan 0
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey), // Warna teks sumbu
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30, // Ruang lebih untuk label hari
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < weeklyData.length) {
                            final dateString =
                                weeklyData[index]['date'] as String;
                            final dateTime = DateTime.parse(dateString);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('EE', 'id_ID').format(
                                    dateTime), // Output: Sen, Sel, Rab, dst.
                                style: const TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppColors.darkGrey), // Warna teks hari
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
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false, // Hanya garis horizontal
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(
                            0.2), // Garis grid horizontal lebih halus
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false), // Hapus border grafik
                  maxY: maxY,
                  barGroups: barGroups,
                  // Garis target horizontal
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: 2000, // Contoh target kalori
                      color: AppColors.primary
                          .withOpacity(0.7), // Warna garis target
                      strokeWidth: 1.5,
                      dashArray: [5, 5], // Garis putus-putus
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
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

  // Widget header untuk Kalori Harian
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
            color: AppColors.darkGrey, // Warna teks konsisten
          ),
        ),
        const Spacer(),
        // Tombol untuk melihat lebih banyak data, jika diperlukan
        TextButton(
          onPressed: () {
            print('Lihat Riwayat Kalori diklik');
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero, // Hapus padding default
            minimumSize: Size.zero, // Hapus ukuran minimum default
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Area tap kecil
          ),
          child: const Text(
            'Lihat Detail',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
