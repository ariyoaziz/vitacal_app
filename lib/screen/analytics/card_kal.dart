import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';

class KaloriChartCard extends StatefulWidget {
  const KaloriChartCard({super.key});

  @override
  State<KaloriChartCard> createState() => _KaloriChartCardState();
}

class _KaloriChartCardState extends State<KaloriChartCard> {
  final List<double> kalori = [1900, 2100, 1500, 1650, 2300, 1700, 2200];
  final List<String> hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  String selectedDay = 'Sen';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 28),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightgreen,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      const Text('Hari ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDay,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => selectedDay = newValue);
                            }
                          },
                          icon: Icon(Icons.keyboard_arrow_down,
                              size: 20, color: Colors.black87),
                          dropdownColor: AppColors.screen,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          items: hari.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                        interval: 500,
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
                          if (index >= 0 && index < hari.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(hari[index],
                                  style: const TextStyle(fontSize: 12)),
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
                  maxY: 3500,
                  barGroups: List.generate(kalori.length, (index) {
                    final isSelected = hari[index] == selectedDay;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: kalori[index],
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: isSelected
                                ? [AppColors.primary, AppColors.primary]
                                : [AppColors.lightgreen, AppColors.lightgreen],
                          ),
                        ),
                      ],
                      showingTooltipIndicators: isSelected ? [0] : [],
                    );
                  }),
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: 2000,
                      color: Colors.grey.shade500,
                      strokeWidth: 1,
                      dashArray: [4, 4],
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
