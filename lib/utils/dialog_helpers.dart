// lib/utils/dialog_helpers.dart
// ignore_for_file: no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart'; // Pastikan AppColors diimpor
// Untuk Enum seperti JenisKelamin, Aktivitas, Tujuan

// --- FUNGSI HELPER: showUpdateValueDialog (untuk angka desimal seperti Berat/Tinggi) ---
Future<void> showUpdateValueDialog({
  required BuildContext context,
  required String title,
  required void Function(double value) onSave,
  required double initialValue,
  required double minValue,
  required double maxValue,
  required String unit,
}) async {
  double _currentWholePart =
      initialValue.clamp(minValue, maxValue).floorToDouble();
  double _currentDecimalPart =
      ((initialValue.clamp(minValue, maxValue) - _currentWholePart) * 10)
          .roundToDouble();

  final List<int> wholeNumbersList = List<int>.generate(
    (maxValue.floor() - minValue.floor() + 1),
    (index) => minValue.floor() + index,
  );
  final List<int> decimalNumbersList = List<int>.generate(10, (index) => index);

  FixedExtentScrollController wholePartController = FixedExtentScrollController(
    initialItem: wholeNumbersList.indexOf(_currentWholePart.toInt()),
  );
  FixedExtentScrollController decimalPartController =
      FixedExtentScrollController(
    initialItem: decimalNumbersList.indexOf(_currentDecimalPart.toInt()),
  );

  // Lebar picker akan disesuaikan berdasarkan persentase lebar layar
  final double screenWidth = MediaQuery.of(context).size.width;
  final double pickerColumnWidth =
      screenWidth * 0.22; // Sekitar 22% dari lebar layar
  final double pickerItemHeight = 55; // Tinggi setiap item di picker

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (stfContext, setState) {
          Widget _buildNumberPickerWheel({
            required FixedExtentScrollController controller,
            required List<int> items,
            required ValueChanged<int> onSelectedItemChanged,
            required int selectedValue, // Nilai yang sedang dipilih
            bool isDecimalPart = false,
            double width = 80, // Default width for a picker wheel
          }) {
            return Container(
              width: width,
              height: pickerItemHeight * 3, // Tinggi yang menampilkan 3 item
              decoration: BoxDecoration(
                color: AppColors.screen, // Menggunakan AppColors.screen
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: pickerItemHeight,
                perspective: 0.005,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    onSelectedItemChanged(
                        index); // Meneruskan index yang dipilih
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= items.length) {
                      return null;
                    }
                    final item = items[index];
                    final bool isSelected = item == selectedValue;

                    return Center(
                      child: AnimatedDefaultTextStyle(
                        style: TextStyle(
                          fontSize: isSelected ? 26 : 20,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkGrey,
                        ),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Text(
                          isDecimalPart
                              ? item.toString().padLeft(1, '0')
                              : '$item',
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: AppColors
                .screen, // Menggunakan AppColors.screen untuk dialog background
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
              width: screenWidth * 0.7, // Lebar konten dialog sekitar 70% layar
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberPickerWheel(
                        controller: wholePartController,
                        items: wholeNumbersList,
                        onSelectedItemChanged: (index) {
                          _currentWholePart =
                              wholeNumbersList[index].toDouble();
                        },
                        selectedValue: _currentWholePart.toInt(),
                        width:
                            pickerColumnWidth, // Menggunakan lebar yang konsisten
                      ),
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
                      _buildNumberPickerWheel(
                        controller: decimalPartController,
                        items: decimalNumbersList,
                        onSelectedItemChanged: (index) {
                          _currentDecimalPart =
                              decimalNumbersList[index].toDouble();
                        },
                        selectedValue: _currentDecimalPart.toInt(),
                        isDecimalPart: true,
                        width: pickerColumnWidth *
                            0.7, // Bagian desimal mungkin sedikit lebih kecil
                      ),
                      const SizedBox(width: 8),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Pilih ${title.toLowerCase()}",
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
                onPressed: () => Navigator.of(stfContext).pop(),
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
                  final double finalValue =
                      _currentWholePart + (_currentDecimalPart / 10.0);

                  if (finalValue >= minValue && finalValue <= maxValue) {
                    onSave(finalValue);
                    Navigator.of(stfContext).pop();
                  } else {
                    ScaffoldMessenger.of(stfContext).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Nilai harus antara ${minValue.toStringAsFixed(1)} dan ${maxValue.toStringAsFixed(1)} $unit'),
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

// --- FUNGSI HELPER: showUpdateEnumDialog (untuk Enum seperti Jenis Kelamin, Aktivitas, Tujuan) ---
Future<T?> showUpdateEnumDialog<T extends Enum>({
  required BuildContext context,
  required String title,
  required T? initialValue,
  required List<T> values,
  required String Function(T value) displayString,
}) async {
  T? selectedValue = initialValue;

  return await showDialog<T>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.screen, // Menggunakan AppColors.screen
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
        content: StatefulBuilder(
          builder: (stfContext, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: values.map((T value) {
                return RadioListTile<T>(
                  title: Text(displayString(value)),
                  value: value,
                  groupValue: selectedValue,
                  onChanged: (T? newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                  activeColor: AppColors.primary, // Warna saat terpilih
                );
              }).toList(),
            );
          },
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(initialValue), // Kembali ke nilai awal jika batal
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
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
            onPressed: () => Navigator.of(dialogContext)
                .pop(selectedValue), // Kembalikan nilai yang dipilih
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
}
