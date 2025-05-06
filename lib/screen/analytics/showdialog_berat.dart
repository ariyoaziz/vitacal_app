import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';

Future<void> showUpdateBeratDialog({
  required BuildContext context,
  required String title,
  required void Function(double value) onSave,
  required double initialValue,
  required double minValue,
  required double maxValue,
}) async {
  double selectedValue = initialValue;

  await showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: Colors.white,
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                title: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                      maxWidth: 350,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "${selectedValue.toStringAsFixed(2)} kg", // Menampilkan dengan dua angka desimal
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor:
                                AppColors.primary.withOpacity(0.3),
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withOpacity(0.2),
                            valueIndicatorColor: AppColors.primary,
                            showValueIndicator: ShowValueIndicator
                                .always, // Menampilkan indikator nilai
                          ),
                          child: Slider(
                            value: selectedValue,
                            min: minValue,
                            max: maxValue,
                            divisions: (maxValue - minValue).toInt(),
                            label:
                                "${selectedValue.toStringAsFixed(2)} kg", // Pastikan label menggunakan format ini
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onSave(selectedValue);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
