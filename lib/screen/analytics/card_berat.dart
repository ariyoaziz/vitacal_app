import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/screen/analytics/showdialog_berat.dart';

class BeratCard extends StatelessWidget {
  final String label;
  final String icon;
  final double value;
  final void Function(double) onUpdate;

  const BeratCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      elevation: 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(icon, height: 14),
                    const SizedBox(width: 11),
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 21),
                Text(
                  "${value.toStringAsFixed(2)} kg",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showUpdateBeratDialog(
                  context: context,
                  title: label,
                  initialValue: value,
                  minValue: 10.0,
                  maxValue: 200.0,
                  onSave: onUpdate,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(21)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
              ),
              child: const Text(
                "Perbaharui",
                style: TextStyle(
                    color: AppColors.screen, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
