// lib/utils/dialog_helpers.dart
// Mengandung fungsi-fungsi helper untuk menampilkan berbagai dialog

// ignore_for_file: no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';
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
  // Menginisialisasi bagian bulat dan desimal dari nilai awal
  double clampedInitialValue = initialValue.clamp(minValue, maxValue);

  double _currentWholePart = clampedInitialValue.floorToDouble();
  double _currentDecimalPart =
      ((clampedInitialValue - _currentWholePart) * 10).roundToDouble();

  // Membuat daftar angka untuk picker bagian bulat
  final List<int> wholeNumbersList = List<int>.generate(
    (maxValue.floor() - minValue.floor() + 1),
    (index) => minValue.floor() + index,
  );
  // Membuat daftar angka untuk picker bagian desimal (0-9)
  final List<int> decimalNumbersList = List<int>.generate(10, (index) => index);

  // Menginisialisasi controller untuk setiap picker
  FixedExtentScrollController wholePartController = FixedExtentScrollController(
    initialItem: wholeNumbersList.isNotEmpty
        ? wholeNumbersList.indexOf(_currentWholePart.toInt())
        : 0,
  );
  FixedExtentScrollController decimalPartController =
      FixedExtentScrollController(
    initialItem: decimalNumbersList.isNotEmpty
        ? decimalNumbersList.indexOf(_currentDecimalPart.toInt())
        : 0,
  );

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (stfContext, setState) {
          Widget _buildNumberPickerWheel({
            required FixedExtentScrollController controller,
            required List<int> items,
            required ValueChanged<int> onSelectedItemChanged,
            required double itemHeight,
            required double itemWidth,
            required int selectedValue, // Nilai yang sedang dipilih
            bool isDecimalPart = false, // True jika ini untuk bagian desimal
          }) {
            return Container(
              width: itemWidth,
              height: itemHeight * 3, // Tinggi yang menampilkan 3 item
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Latar belakang abu-abu muda
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: itemHeight,
                perspective: 0.005,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: onSelectedItemChanged,
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
                      // Picker untuk bagian depan koma
                      _buildNumberPickerWheel(
                        controller: wholePartController,
                        items: wholeNumbersList,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _currentWholePart =
                                wholeNumbersList[index].toDouble();
                          });
                        },
                        itemHeight: 65,
                        itemWidth: 80,
                        selectedValue: _currentWholePart.toInt(),
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
                      // Picker untuk bagian belakang koma
                      _buildNumberPickerWheel(
                        controller: decimalPartController,
                        items: decimalNumbersList,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _currentDecimalPart =
                                decimalNumbersList[index].toDouble();
                          });
                        },
                        itemHeight: 65,
                        itemWidth: 65,
                        selectedValue: _currentDecimalPart.toInt(),
                        isDecimalPart: true,
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

                  print('DIALOG SAVE DEBUG: finalValue: $finalValue');
                  print('DIALOG SAVE DEBUG: minValue: $minValue');
                  print('DIALOG SAVE DEBUG: maxValue: $maxValue');
                  print('DIALOG SAVE DEBUG: unit: $unit');
                  print(
                      'DIALOG SAVE DEBUG: Kondisi validasi: ${finalValue >= minValue && finalValue <= maxValue}');

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
  required String Function(T value)
      displayString, // Fungsi untuk mengubah Enum ke string tampilan
}) async {
  T? selectedValue = initialValue;

  return await showDialog<T>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
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
