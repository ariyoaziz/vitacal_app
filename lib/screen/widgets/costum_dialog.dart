// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';

// Enum untuk menentukan tipe dialog (sukses, peringatan, error)
enum DialogType {
  success,
  warning,
  error,
}

class CustomAlertDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final DialogType type;
  final bool showButton;
  final Duration? autoDismissDuration;

  const CustomAlertDialog({
    super.key,
    this.title = "Info Penting",
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.type = DialogType.error,
    this.showButton = true,
    this.autoDismissDuration,
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog>
    with SingleTickerProviderStateMixin {
  // <--- Tambahkan SingleTickerProviderStateMixin
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi AnimationController untuk ikon
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Durasi animasi ikon
    );
    _scaleAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack); // Efek memantul

    _animationController.forward(); // Mulai animasi ikon saat dialog muncul

    // Jika autoDismissDuration diatur dan tombol tidak ditampilkan, tutup otomatis
    if (widget.autoDismissDuration != null && !widget.showButton) {
      Future.delayed(widget.autoDismissDuration!, () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onButtonPressed?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // Pastikan controller di-dispose
    super.dispose();
  }

  Color _getDialogColor() {
    switch (widget.type) {
      case DialogType.success:
        return AppColors.primary; // Menggunakan primary untuk sukses
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
        return Colors.red;
    }
  }

  String _getIconPath() {
    switch (widget.type) {
      case DialogType.success:
        return 'assets/icons/success.svg';
      case DialogType.warning:
        return 'assets/icons/warning.svg';
      case DialogType.error:
        return 'assets/icons/error.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 60.0,
              bottom: widget.showButton ? 16.0 : 0.0,
              left: 16.0,
              right: 16.0,
            ),
            margin: const EdgeInsets.only(top: 45.0),
            decoration: BoxDecoration(
              color: AppColors.screen,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenWidth * 0.7,
                maxWidth: screenWidth * 0.8,
                minHeight: 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: _getDialogColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  if (widget.showButton) const SizedBox(height: 24.0),
                  if (widget.showButton)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onButtonPressed?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getDialogColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          widget.buttonText ?? "Oke",
                          style: const TextStyle(
                              color: AppColors.screen, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Posisi untuk ikon di atas dialog
          Positioned(
            left: 16.0,
            right: 16.0,
            top: 0.0,
            child: ScaleTransition(
              // <--- MODIFIKASI: Animasi ScaleTransition
              scale: _scaleAnimation, // Gunakan animation controller
              child: CircleAvatar(
                backgroundColor: _getDialogColor(),
                radius: 40.0, // Ukuran ikon (disesuaikan sedikit)
                // --- Tambahkan shadow yang lebih jelas ke CircleAvatar ---
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    _getIconPath(),
                    width: 50,
                    height: 50,
                    colorFilter: const ColorFilter.mode(
                        AppColors.screen, BlendMode.srcIn), // Warna ikon
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
