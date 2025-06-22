import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  final String? buttonText; // Teks untuk tombol utama (positif/aksi)
  final VoidCallback? onButtonPressed; // Callback untuk tombol utama
  final DialogType type;
  final bool showButton; // Menentukan apakah tombol utama ditampilkan
  final Duration? autoDismissDuration; // Durasi untuk auto-dismiss
  final String?
      secondaryButtonText; // <<< BARU: Teks untuk tombol sekunder (batal/negatif)
  final VoidCallback?
      onSecondaryButtonPressed; // <<< BARU: Callback untuk tombol sekunder

  const CustomAlertDialog({
    super.key,
    this.title = "Info Penting",
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.type = DialogType.error,
    this.showButton = true,
    this.autoDismissDuration,
    this.secondaryButtonText, // <<< SERTAKAN DI KONSTRUKTOR
    this.onSecondaryButtonPressed, // <<< SERTAKAN DI KONSTRUKTOR
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
    String? secondaryButtonText, // <<< SERTAKAN DI STATIC SHOW
    VoidCallback? onSecondaryButtonPressed, // <<< SERTAKAN DI STATIC SHOW
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
          secondaryButtonText: secondaryButtonText, // <<< TERUSKAN PARAMETER
          onSecondaryButtonPressed:
              onSecondaryButtonPressed, // <<< TERUSKAN PARAMETER
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

    // Logika auto-dismiss: Hanya jika tidak ada tombol dan durasi diberikan
    // Sekarang, juga pastikan tidak ada tombol sekunder
    if (widget.autoDismissDuration != null &&
        !widget.showButton &&
        widget.secondaryButtonText == null) {
      Future.delayed(widget.autoDismissDuration!, () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          widget.onButtonPressed
              ?.call(); // Panggil callback tombol utama jika di-dismiss otomatis
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
        return AppColors.warningOrange;
      case DialogType.error:
        return AppColors.errorRed;
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
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
                  // >>>>>> LOGIKA TOMBOL DI SINI <<<<<<
                  // Tampilkan SizedBox dan Row tombol jika ada tombol utama ATAU tombol sekunder
                  if (widget.showButton || widget.secondaryButtonText != null)
                    const SizedBox(height: 24.0),
                  if (widget.showButton || widget.secondaryButtonText != null)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Pusatkan tombol
                      children: [
                        // Tombol Sekunder (Batal)
                        if (widget.secondaryButtonText != null)
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Tutup dialog
                                widget.onSecondaryButtonPressed
                                    ?.call(); // Panggil callback sekunder
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.darkGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                      color: AppColors.lightGrey, width: 1),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                widget.secondaryButtonText!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        // Jarak antara tombol jika keduanya ada
                        if (widget.showButton &&
                            widget.secondaryButtonText != null)
                          const SizedBox(width: 16),
                        // Tombol Utama (Aksi)
                        if (widget.showButton)
                          Expanded(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                  // >>>>>> AKHIR LOGIKA TOMBOL <<<<<<
                ],
              ),
            ),
            // Ikon Bulat (Positioned di atas Container konten dialog)
            Positioned(
              top: 0,
              child: CircleAvatar(
                backgroundColor: _getDialogColor(),
                radius: 45.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
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
