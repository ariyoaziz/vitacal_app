// lib/widgets/custom_alert_dialog.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';

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

 
  static Future<void> show({
  
    required BuildContext context,
    String title = "Info Penting",
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
    DialogType type = DialogType.error,
    bool showButton = true,
    Duration? autoDismissDuration,
  }) async {
    
    print('DEBUG DIALOG: CustomAlertDialog.show() dipanggil!');
    print('DEBUG DIALOG: Pesan: "$message"');
    print('DEBUG DIALOG: Stack Trace:');
    print(StackTrace.current); // Cetak stack trace penuh
    return showDialog<void>(
      // <<< ENSURE showDialog returns void as well
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CustomAlertDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
          type: type,
          showButton: showButton,
          autoDismissDuration: autoDismissDuration,
        );
      },
    );
  }

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack);

    _animationController.forward();

    if (widget.autoDismissDuration != null && !widget.showButton) {
      Future.delayed(widget.autoDismissDuration!, () {
        if (mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            widget.onButtonPressed?.call();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getDialogColor() {
    switch (widget.type) {
      case DialogType.success:
        return AppColors.primary;
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
          Positioned(
            left: 16.0,
            right: 16.0,
            top: 0.0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CircleAvatar(
                backgroundColor: _getDialogColor(),
                radius: 40.0,
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
                        AppColors.screen, BlendMode.srcIn),
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
