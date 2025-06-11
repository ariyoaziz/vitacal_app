// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:vitacal_app/themes/colors.dart';

class BmiCard extends StatelessWidget {
  final double bmi;

  const BmiCard({super.key, required this.bmi});

  // Fungsi getBmiStatus agar SAMA PERSIS dengan backend Flask
  String getBmiStatus(double bmi) {
    if (bmi < 18.5)
      return "Berat badan kurang";
    else if (bmi <= 24.9)
      return "Berat badan normal";
    else if (bmi <= 29.9)
      return "Pre-obesitas";
    else if (bmi <= 34.9)
      return "Obesitas kelas I";
    else if (bmi <= 39.9)
      return "Obesitas kelas II";
    else
      return "Obesitas kelas III"; // bmi >= 40.0
  }

  // Fungsi getBmiColor agar sesuai dengan 6 status di atas
  Color getBmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.orange.shade700; // Untuk "Berat badan kurang"
    } else if (bmi <= 24.9) {
      return Colors.green; // Untuk "Berat badan normal"
    } else if (bmi <= 29.9) {
      return Colors.orange; // Untuk "Pre-obesitas"
    } else if (bmi <= 34.9) {
      return Colors.red; // Untuk "Obesitas kelas I"
    } else if (bmi <= 39.9) {
      return Colors.red.shade700; // Untuk "Obesitas kelas II"
    } else {
      // bmi >= 40.0
      return Colors.red.shade900; // Untuk "Obesitas kelas III"
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getBmiStatus(bmi);
    final color = getBmiColor(bmi);

    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Indeks Massa Tubuh (BMI)",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey),
            ),
            const SizedBox(height: 24),

            // Bagian Gauge BMI
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 5,
                  maximum: 45,
                  interval: 5,
                  minorTicksPerInterval: 4,
                  showLabels: true,
                  showTicks: true,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.2,
                    thicknessUnit: GaugeSizeUnit.factor,
                    cornerStyle: CornerStyle.bothCurve,
                    gradient: SweepGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.yellow.shade400,
                        Colors.green.shade500,
                        Colors.orange.shade700,
                        Colors.red.shade700,
                      ],
                      stops: const [0.0, 0.25, 0.45, 0.707, 1.0],
                    ),
                  ),
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: bmi.clamp(5.0, 45.0),
                      needleColor: Colors.black,
                      needleLength: 0.7,
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
                  // Teks di tengah gauge
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      // --- PERBAIKAN DI SINI: Sesuaikan positionFactor untuk memindahkan ke bawah ---
                      angle: 90,
                      positionFactor:
                          1, // Nilai yang lebih besar akan memindahkan ke bawah (0.1 adalah paling tengah)
                      widget: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // MainAxisAlignment.center tetap bagus
                        children: [
                          // Tambahkan teks "BMI Kamu" di sini
                          const Text(
                            "BMI Kamu",
                            style: TextStyle(
                                fontSize: 18,
                                color:
                                    AppColors.darkGrey), // Sesuaikan gaya teks
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bmi.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGrey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            status,
                            style: TextStyle(
                                fontSize: 16,
                                color: color,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 33),

            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 20),

            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _LegendRow("Berat badan kurang", "< 18.5", Colors.orange.shade700),
        _LegendRow("Berat badan normal", "18.5 – 24.9", Colors.green),
        _LegendRow("Pre-obesitas", "25.0 – 29.9", Colors.orange),
        _LegendRow("Obesitas kelas I", "30.0 – 34.9", Colors.red),
        _LegendRow("Obesitas kelas II", "35.0 – 39.9", Colors.red.shade700),
        _LegendRow("Obesitas kelas III", "≥ 40.0", Colors.red.shade900),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 14, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          Text(range,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
