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
    // Tentukan unit & batas nilai berdasarkan label
    final _Meta meta = _metaFromLabel(label);

    return Card(
      color: AppColors.screen,
      surfaceTintColor: Colors.transparent, // hindari tint di Material 3
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        side: BorderSide(color: Colors.black.withOpacity(0.04), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Konten utama
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                // Icon + Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(icon, height: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nilai + Unit (proporsi enak dibaca)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: RichText(
                    key: ValueKey('${value.toStringAsFixed(1)} ${meta.unit}'),
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        TextSpan(
                          text: ' ${meta.unit}',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            // ignore: deprecated_member_use
                            color: AppColors.darkGrey.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Tombol Perbaharui
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.screen,
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
              label: const Text(
                'Perbaharui',
                style: TextStyle(
                  color: AppColors.screen,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              onPressed: () {
                showUpdateValueDialog(
                  context: context,
                  title: label,
                  initialValue: value,
                  minValue: meta.min,
                  maxValue: meta.max,
                  unit: meta.unit,
                  onSave: (newValue) => onUpdate(newValue),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk mapping label -> unit & range
  _Meta _metaFromLabel(String label) {
    switch (label) {
      case 'Berat Sekarang':
      case 'Tujuan Berat':
        return const _Meta(unit: 'kg', min: 10.0, max: 200.0);
      case 'Tinggi Badan':
        return const _Meta(unit: 'cm', min: 50.0, max: 250.0);
      default:
        return const _Meta(unit: '', min: 0.0, max: 100.0);
    }
  }
}

class _Meta {
  final String unit;
  final double min;
  final double max;
  const _Meta({required this.unit, required this.min, required this.max});
}
