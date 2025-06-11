import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';

// Enum untuk tipe dialog (Sukses, Peringatan, Error)
enum DialogType {
  success,
  warning,
  error,
}

// Widget utama CustomAlertDialog
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
    this.title = "Info Penting", // Default title
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.type = DialogType.error, // Default type
    this.showButton = true, // Default to show button
    this.autoDismissDuration,
  });

  // Static method untuk menampilkan dialog dengan mudah
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

    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Dialog tidak bisa ditutup dengan mengetuk di luar
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
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          widget.onButtonPressed?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper untuk mendapatkan warna dialog berdasarkan tipe
  Color _getDialogColor() {
    switch (widget.type) {
      case DialogType.success:
        return AppColors.primary;
      case DialogType.warning:
        return AppColors.warningOrange;
      case DialogType.error:
        return AppColors.errorRed;
    }
  }

  // Helper untuk mendapatkan path ikon SVG berdasarkan tipe
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
    // double screenWidth = MediaQuery.of(context).size.width; // Tidak digunakan langsung

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          // PERBAIKAN: Menggunakan Stack sebagai root child untuk menumpuk ikon
          clipBehavior: Clip
              .none, // Penting agar ikon bisa menonjol keluar dari batas Stack
          alignment: Alignment.topCenter, // Pusatkan child di bagian atas
          children: <Widget>[
            // Konten Dialog (Card/Container utama)
            Container(
              padding: const EdgeInsets.only(
                top: 70.0, // Memberi ruang di bagian atas untuk ikon
                bottom: 20.0,
                left: 24.0,
                right: 24.0,
              ),
              margin: const EdgeInsets.only(
                  top:
                      45.0), // Margin untuk menggeser dialog ke bawah agar ikon ada ruang
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
              child: Column(
                // Column untuk menata Judul, Pesan, dan Tombol
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: _getDialogColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  if (widget.showButton) const SizedBox(height: 24.0),
                  if (widget.showButton)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onButtonPressed?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getDialogColor(),
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.buttonText ?? "Oke",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Ikon Bulat (Positioned di atas Container konten dialog)
            Positioned(
              top: 0, // Posisi top 0 agar ikon berada di atas Container
              child: CircleAvatar(
                backgroundColor: _getDialogColor(),
                radius: 45.0, // Radius ikon
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(
                            0, 0, 0, 0.2), // Mengganti withOpacity
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    _getIconPath(),
                    width: 50, // Ukuran ikon SVG
                    height: 50,
                    colorFilter: const ColorFilter.mode(
                        AppColors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
