// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_input_nama.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart'; // Perhatikan typo: CustomAlertDialog
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';

class OtpRegistrasi extends StatefulWidget {
  final String phoneNumber;
  final int userId;

  const OtpRegistrasi({
    super.key,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  State<OtpRegistrasi> createState() => _OtpRegistrasiState();
}

class _OtpRegistrasiState extends State<OtpRegistrasi> {
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    super.dispose();
  }

  // Widget helper untuk OTP TextField
  Widget _otpTextField(BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            // Menggunakan Color.fromRGBO untuk mengatasi deprecated member use
            borderSide: BorderSide(
              color: Color.fromRGBO(
                  AppColors.primary.red,
                  AppColors.primary.green,
                  AppColors.primary.blue,
                  0.5), // opacity 0.5
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            // Menggunakan Color.fromRGBO untuk mengatasi deprecated member use
            borderSide: BorderSide(
              color: Color.fromRGBO(
                  AppColors.primary.red,
                  AppColors.primary.green,
                  AppColors.primary.blue,
                  0.5), // opacity 0.5
              width: 1,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  // Fungsi untuk memicu verifikasi OTP - FUNGSI INI TIDAK DIUBAH
  void _onVerifyOtpPressed() {
    String otpCode = controller1.text +
        controller2.text +
        controller3.text +
        controller4.text;

    if (otpCode.length == 4) {
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              userId: widget.userId,
              otpCode: otpCode,
              phoneNumber: widget.phoneNumber,
            ),
          );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const CustomAlertDialog(
            title: "Input Belum Lengkap!",
            message: "Yuk, masukkan 4 digit kode OTP lengkap ya!",
            buttonText: "Oke",
            type: DialogType.warning,
            showButton: true,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.05,
            ),
            // BlocListener membungkus konten yang akan ditampilkan
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                // FUNGSI INI TIDAK DIUBAH
                if (state is AuthLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                }

                if (state is AuthOtpVerified) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return CustomAlertDialog(
                          title: "Verifikasi Berhasil!",
                          message:
                              "Kode OTP Anda telah berhasil diverifikasi. Yuk, lengkapi profilmu!",
                          buttonText: "Lanjut",
                          type: DialogType.success,
                          showButton: true,
                          onButtonPressed: () {
                            Navigator.pushReplacement(
                              dialogContext,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailuserInputNama(userId: widget.userId),
                              ),
                            );
                          },
                        );
                      },
                    );
                  });
                } else if (state is AuthError) {
                  String dialogTitle = "Verifikasi Gagal!";
                  String dialogMessage = state.message;
                  DialogType dialogType = DialogType.error;

                  final cleanMessage = state.message.trim();

                  if (cleanMessage.contains("Kode tidak sesuai")) {
                    dialogTitle = "Kode OTP Salah!";
                    dialogMessage =
                        "Kode OTP yang kamu masukkan tidak cocok. Coba lagi ya!";
                    dialogType = DialogType.error;
                  } else if (cleanMessage
                          .contains("Gagal terhubung ke server") ||
                      cleanMessage.contains("Network Error")) {
                    dialogTitle = "Jaringanmu Bermasalah?";
                    dialogMessage =
                        "Gagal terhubung ke server. Pastikan koneksi internetmu stabil dan coba lagi ya!";
                    dialogType = DialogType.error;
                  } else if (cleanMessage.contains("masalah tak terduga")) {
                    dialogTitle = "Ada Error Nih!";
                    dialogMessage =
                        "Terjadi masalah tak terduga di aplikasi. Kami sedang memperbaikinya. Mohon coba lagi nanti ya!";
                    dialogType = DialogType.error;
                  } else if (cleanMessage
                      .contains("Nomor telepon dan OTP harus diisi")) {
                    dialogTitle = "Input Belum Lengkap!";
                    dialogMessage = "Mohon isi nomor telepon dan kode OTP ya!";
                    dialogType = DialogType.warning;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return CustomAlertDialog(
                        title: dialogTitle,
                        message: dialogMessage,
                        buttonText: "Oke",
                        type: dialogType,
                        showButton: true,
                      );
                    },
                  );
                }
              },
              // Bagian ini adalah child dari BlocListener
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Verifikasi OTP Kamu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: Image.asset(
                      'assets/images/otp.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Masukkan kode 4 digit yang telah kami kirim ke nomor",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.phoneNumber,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _otpTextField(context, controller1),
                      const SizedBox(width: 15),
                      _otpTextField(context, controller2),
                      const SizedBox(width: 15),
                      _otpTextField(context, controller3),
                      const SizedBox(width: 15),
                      _otpTextField(context, controller4),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.greenGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(
                                AppColors.primary.red,
                                AppColors.primary.green,
                                AppColors.primary.blue,
                                0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onVerifyOtpPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Konfirmasi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
