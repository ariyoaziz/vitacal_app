import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';

class CardBeratGrafik extends StatefulWidget {
  const CardBeratGrafik({super.key});

  @override
  State<CardBeratGrafik> createState() => _CardBeratGrafikState();
}

class _CardBeratGrafikState extends State<CardBeratGrafik> {
  String selectedRange = 'Minggu';

  final List<String> rangeOptions = ['Minggu', 'Bulan'];

  final List<FlSpot> beratMinggu = [
    FlSpot(1, 60),
    FlSpot(2, 61),
    FlSpot(3, 61.5),
    FlSpot(4, 60.5),
    FlSpot(5, 62.2),
    FlSpot(6, 63),
    FlSpot(7, 62.5),
  ];

  final List<FlSpot> beratBulan = [
    FlSpot(1, 60),
    FlSpot(2, 61),
    FlSpot(3, 62),
    FlSpot(4, 63),
  ];

  List<String> getBottomTitles() {
    return selectedRange == 'Minggu'
        ? ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
        : ['1', '2', '3', '4'];
  }

  List<FlSpot> getChartData() {
    return selectedRange == 'Minggu' ? beratMinggu : beratBulan;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                const Text(
                  'Berat Badan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.lightgreen,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRange,
                      icon:
                          const Icon(Icons.expand_more, color: Colors.black87),
                      dropdownColor: AppColors.screen,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      borderRadius: BorderRadius.circular(11),
                      onChanged: (newValue) {
                        setState(() {
                          selectedRange = newValue!;
                        });
                      },
                      items: rangeOptions.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Grafik
            AspectRatio(
              aspectRatio: 0.8,
              child: LineChart(
                LineChartData(
                  minY: 20,
                  maxY: 150,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 10, // Tampilkan semua label Y
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
                          List<String> labels = getBottomTitles();
                          int index = value.toInt() - 1;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              (index >= 0 && index < labels.length)
                                  ? labels[index]
                                  : '',
                              style: const TextStyle(fontSize: 12),
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
                    LineChartBarData(
                      spots: getChartData(),
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
                            // ignore: deprecated_member_use
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
}
