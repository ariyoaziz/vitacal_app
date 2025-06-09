// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:vitacal_app/themes/colors.dart';

class BmiCard extends StatelessWidget {
  final double bmi;

  const BmiCard({super.key, required this.bmi});

  // --- Fungsi getBmiStatus agar SAMA PERSIS dengan backend Flask ---
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

  // --- Fungsi getBmiColor agar sesuai dengan 6 status di atas ---
  // Menggunakan gradasi warna untuk obesitas
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
  // --- AKHIR PERBAIKAN ---

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
                  minimum: 5,
                  maximum: 45,
                  interval: 5, // Ticks tiap 5 satuan
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
                      value: bmi.clamp(
                          10.0, 35.0), // Clamp BMI value within gauge range
                      needleColor: Colors.black, // Mengembalikan ke warna hitam
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
              bmi.toStringAsFixed(1), // Menampilkan BMI dengan 1 desimal
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              status, // Teks status BMI
              style: TextStyle(
                  fontSize: 16, color: color), // Menggunakan warna yang sesuai
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildLegend() // Membangun legenda
          ],
        ),
      ),
    );
  }

  // --- Helper method untuk membangun legenda BMI sesuai backend ---
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

// Widget untuk satu baris legenda (tidak berubah)
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
