// ignore_for_file: deprecated_member_use, duplicate_ignore, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';

enum DialogType { success, error, info }

class CustomDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    DialogType type = DialogType.info,
    bool autoDismiss = false,
    Duration dismissDuration = const Duration(seconds: 2),
    bool showOkButton = false,
    String okButtonText = 'OK',
    VoidCallback? onOkPressed,
  }) {
    Color dialogColor;
    IconData dialogIcon;

    switch (type) {
      case DialogType.success:
        dialogColor = AppColors.primary;
        dialogIcon = Icons.check;
        break;
      case DialogType.error:
        dialogColor = Colors.red;
        dialogIcon = Icons.close;
        break;
      case DialogType.info:
      // ignore: unreachable_switch_default
      default:
        dialogColor = Colors.blue;
        dialogIcon = Icons.info_outline;
        break;
    }

    final dialog = Dialog(
      backgroundColor: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = 320; // Maksimal lebar dialog (bisa disesuaikan)
          double width = constraints.maxWidth > maxWidth
              ? maxWidth
              : constraints.maxWidth * 0.9;

          return Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: dialogColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(dialogIcon, color: dialogColor, size: 40),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                if (showOkButton) ...[
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        if (Navigator.of(context, rootNavigator: true)
                            .canPop()) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        if (onOkPressed != null) {
                          onOkPressed();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: dialogColor,
                      ),
                      child: Text(
                        okButtonText, // <-- gunakan variabel ini
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    final future = showGeneralDialog(
      context: context,
      barrierDismissible: !showOkButton && !autoDismiss,
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => dialog,
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );

    if (autoDismiss) {
      Future.delayed(dismissDuration, () {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (onOkPressed != null) {
          onOkPressed();
        }
      });
    }

    return future;
  }
}
