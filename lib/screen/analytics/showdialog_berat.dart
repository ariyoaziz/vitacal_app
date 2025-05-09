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
  final TextEditingController depanController = TextEditingController(
    text: initialValue.floor().toString().padLeft(2, '0'),
  );
  final TextEditingController belakangController = TextEditingController(
    text: ((initialValue - initialValue.floor()) * 100)
        .round()
        .toString()
        .padLeft(1, '0'),
  );

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
            titlePadding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1, height: 1, color: Colors.black12),
              ],
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stylishNumberBox(controller: depanController),
                      const SizedBox(width: 6),
                      const Text(
                        ".",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _stylishNumberBox(controller: belakangController),
                      const SizedBox(width: 8),
                      const Text(
                        "kg",
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Masukkan berat badan kamu",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary, width: 1.2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final depan = int.tryParse(depanController.text) ?? 0;
                  final belakang = int.tryParse(belakangController.text) ?? 0;
                  final berat = depan + (belakang / 100);

                  if (berat >= minValue && berat <= maxValue) {
                    onSave(berat);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Berat harus antara ${minValue.toStringAsFixed(2)} dan ${maxValue.toStringAsFixed(2)} kg'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    fontSize: 14,
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
}

Widget _stylishNumberBox({required TextEditingController controller}) {
  return Container(
    width: 65,
    height: 65,
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(14),
      // ignore: deprecated_member_use
      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
    ),
    child: Center(
      child: TextField(
        controller: controller,
        maxLength: 2,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    ),
  );
}
