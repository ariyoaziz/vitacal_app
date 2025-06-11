// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal
import 'package:intl/date_symbol_data_local.dart'; // Untuk inisialisasi data lokal

/// Widget untuk menampilkan grafik berat badan.
/// Menerima data berat badan melalui properti 'data'.
class CardBeratGrafik extends StatelessWidget {
  // Data berat badan yang akan ditampilkan pada grafik.
  // Diharapkan berupa List of Map dengan format:
  // [{"date": "YYYY-MM-DD", "weight": VALUE_BERAT}]
  final List<Map<String, dynamic>> data;

  const CardBeratGrafik({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Pastikan data lokal diinisialisasi untuk format hari
    initializeDateFormatting('id_ID', null);

    // Ambil hanya 7 data terakhir, jika data kurang dari 7, ambil semua yang ada.
    // .reversed.take(7).toList().reversed.toList() adalah cara untuk mengambil N elemen terakhir.
    final List<Map<String, dynamic>> displayedData =
        data.length > 7 ? data.sublist(data.length - 7) : List.from(data);

    // Memastikan ada data untuk ditampilkan, jika tidak, tampilkan placeholder.
    if (displayedData.isEmpty) {
      return Card(
        color: AppColors.screen,
        // Radius kartu konsisten 24, elevation 2
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2, // Menaikkan elevation untuk kesan kedalaman
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
                  'Tidak ada data berat badan tersedia.',
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
            10) // Kurangi 5 untuk margin bawah
        .floorToDouble();
    double maxY = (displayedData
                .map((e) => (e['weight'] as num).toDouble())
                .reduce((value, element) => value > element ? value : element) +
            10) // Tambah 5 untuk margin atas
        .ceilToDouble();

    if (minY < 0) minY = 0; // Memastikan minY tidak kurang dari 0

    return Card(
      color: AppColors.screen,
      // Radius kartu konsisten 24, elevation 2
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2, // Menaikkan elevation untuk kesan kedalaman
      child: Padding(
        padding:
            const EdgeInsets.all(24), // Padding yang lebih besar dan konsisten
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24), // Spasi setelah header

            // Grafik Berat Badan
            AspectRatio(
              aspectRatio: 1.2, // Aspek rasio sedikit disesuaikan
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 0.5,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey
                          .withOpacity(0.2), // Garis grid vertikal lebih halus
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: (maxY - minY) /
                            5, // Interval dinamis Y axis (membagi menjadi 4 interval)
                        getTitlesWidget: (value, meta) {
                          if (value == minY || value == maxY) {
                            return Text(
                                ''); // Tidak menampilkan label min/max agar tidak tumpang tindih
                          }
                          return Text(
                            '${value.toInt()} Kg',
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
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors
                                        .darkGrey), // Warna teks tanggal
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
                  borderData: FlBorderData(show: false), // Hapus border grafik
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      // Gradien warna garis
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          Colors.green.shade600
                        ], // Warna gradien garis
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 5, // Ukuran titik
                          color: AppColors.screen, // Warna titik (putih)
                          strokeWidth: 2,
                          strokeColor: AppColors.primary, // Warna border titik
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(
                                0.2), // Area bawah garis transparan
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  // Tooltip sentuh
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.darkGrey
                          .withOpacity(0.9), // Warna tooltip gelap
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final int index = spot.spotIndex;
                          final dateString =
                              displayedData[index]['date'] as String;
                          final dateTime = DateTime.parse(dateString);
                          final formattedDate =
                              DateFormat('EEEE, d MMM', 'id_ID').format(
                                  dateTime); // Format tanggal lengkap di tooltip

                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} Kg\n$formattedDate', // Tampilkan berat dan tanggal
                            const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // Warna teks tooltip putih
                            ),
                            textAlign: TextAlign.center,
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches:
                        true, // Biarkan FlChart menangani sentuhan default
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi helper untuk header kartu
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1), // Background ikon halus
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.monitor_weight_rounded,
              color: AppColors.primary, size: 24), // Ukuran ikon konsisten
        ),
        const SizedBox(width: 10),
        const Text(
          'Grafik Berat Badan', // Judul lebih spesifik
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const Spacer(),
        // Tombol untuk melihat lebih banyak data, jika diperlukan
        TextButton(
          onPressed: () {
            print('Lihat Riwayat Berat Badan diklik');
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
