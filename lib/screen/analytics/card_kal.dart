import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart'; // Pastikan Anda mengimpor warna dari tema Anda

class KaloriChartCard extends StatefulWidget {
  KaloriChartCard({super.key});

  @override
  _KaloriChartCardState createState() => _KaloriChartCardState();
}

class _KaloriChartCardState extends State<KaloriChartCard> {
  final List<double> kalori = const [1900, 2100, 1500, 1650, 2300, 1700, 2200];
  final List<String> hari = ['Mo', 'Tu', 'W', 'Th', 'F', 'Sa', 'Su'];
  String selectedDay = 'Mo'; // Default selected day

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.screen, // Sesuaikan dengan tema warna
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Kalori',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                // Desain dropdown yang lebih kecil tanpa shadow
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100, // Sesuaikan warna
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: selectedDay,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDay = newValue!;
                      });
                    },
                    icon: Icon(Icons.keyboard_arrow_down,
                        size: 20, color: Colors.green.shade700),
                    underline: SizedBox(),
                    style: TextStyle(color: Colors.green.shade700),
                    items: hari.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} Kal',
                          const TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 500,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < hari.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                hari[index],
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
                  barGroups: List.generate(kalori.length, (index) {
                    final isHighlight = hari[index] ==
                        selectedDay; // Menyoroti hari yang dipilih
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: kalori[index],
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          gradient: isHighlight
                              ? LinearGradient(colors: [
                                  Colors.green.shade700,
                                  Colors.green
                                ]) // Warna lebih gelap untuk hari yang dipilih
                              : LinearGradient(colors: [
                                  Colors.green.shade100,
                                  Colors.green.shade300
                                ]),
                        ),
                      ],
                    );
                  }),
                  maxY: 2500,
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: 2000,
                      color: Colors.black45,
                      strokeWidth: 1,
                      dashArray: [5, 5],
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
}
