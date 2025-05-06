import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:vitacal_app/themes/colors.dart';

class BmiCard extends StatelessWidget {
  final double bmi;

  const BmiCard({super.key, required this.bmi});

  String getBmiStatus(double bmi) {
    if (bmi < 16.0) return 'Sangat Kurus';
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Berlebih';
    return 'Obesitas';
  }

  Color getBmiColor(double bmi) {
    if (bmi < 16.0) return Colors.orange.shade700;
    if (bmi < 18.5) return Colors.yellow.shade700;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final status = getBmiStatus(bmi);
    final color = getBmiColor(bmi);

    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "BMI (Kg/M2)",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 10,
                  maximum: 35,
                  showLabels: true,
                  showTicks: false,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.2,
                    thicknessUnit: GaugeSizeUnit.factor,
                    cornerStyle: CornerStyle.bothCurve,
                    gradient: SweepGradient(
                      colors: [
                        Colors.orange.shade400, // Sangat Kurus
                        Colors.yellow.shade400, // Kurus
                        Colors.green.shade500, // Normal
                        Colors.orange.shade700, // Berlebih
                        Colors.red.shade600, // Obesitas
                      ],
                      stops: const [
                        0.0, // end Sangat Kurus
                        0.303, // end Kurus
                        0.532, // end Normal
                        0.707, // end Berlebih
                        1.0 // end Obesitas
                      ],
                    ),
                  ),
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: bmi,
                      needleColor: Colors.black,
                      needleLength: 0.6,
                      needleStartWidth: 0,
                      needleEndWidth: 10,
                      knobStyle: KnobStyle(
                        color: Colors.black,
                        borderColor: Colors.white,
                        borderWidth: 0.01,
                        knobRadius: 0.1,
                        sizeUnit: GaugeSizeUnit.factor,
                      ),
                      tailStyle: TailStyle(
                        length: 0.20,
                        width: 5,
                        color: Colors.black,
                        lengthUnit: GaugeSizeUnit.factor,
                      ),
                      enableAnimation: true,
                      animationType: AnimationType.easeOutBack,
                      animationDuration: 1000,
                    ),
                  ],
                ),
              ],
            ),
            const Text("BMI Kamu", style: TextStyle(fontSize: 18)),
            Text(
              bmi.toStringAsFixed(1),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              getBmiStatus(bmi),
              style: TextStyle(fontSize: 16, color: color),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildLegend()
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: const [
        _LegendRow("Sangat Kurus", "< 16.0", Colors.orange),
        _LegendRow("Kurus", "16.0 – 18.4", Colors.yellow),
        _LegendRow("Berat Badan Normal", "18.5 – 24.9", Colors.green),
        _LegendRow(
            "Berlebihan Berat Badan", "25.0 – 29.9", Colors.orangeAccent),
        _LegendRow("Obesitas", "≥ 30.0", Colors.red),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _LegendRow(this.label, this.range, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ),
          Text(range,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }
}
