// lib/screen/auth/otp/otp_registrasi.dart

import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_input_nama.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';

class OtpRegistrasi extends StatefulWidget {
  final String phoneNumber;
  final int userId; // <--- PASTIKAN INI INT

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

  Widget _otpTextField(BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
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

  void _onVerifyOtpPressed() {
    String otpCode = controller1.text +
        controller2.text +
        controller3.text +
        controller4.text;

    if (otpCode.length == 4) {
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              userId: widget.userId, // userId sudah int
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
            padding: EdgeInsets.only(
              top: screenHeight * 0.08,
              bottom: screenHeight * 0.05,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
            ),
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
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
                  print('OTPRegistrasi: Menerima AuthOtpVerified.');
                  print(
                      'OTPRegistrasi: Tipe state.user.userId: ${state.user.userId.runtimeType}');
                  print(
                      'OTPRegistrasi: Nilai state.user.userId: "${state.user.userId}"');

                  int parsedUserId;
                  // PERBAIKAN: Gunakan int.tryParse() pada state.user.userId
                  // dan pastikan ada fallback yang aman jika itu "null" atau string tidak valid.
                  // Default ke 0 jika gagal parse
                  parsedUserId =
                      int.tryParse(state.user.userId.toString()) ?? 0;
                  // Tambahkan validasi jika 0 tidak valid untuk user_id Anda
                  if (parsedUserId == 0 &&
                      // ignore: unnecessary_null_comparison
                      (state.user.userId == null ||
                          state.user.userId.toString() == "null")) {
                    // Jika userId benar-benar null/tidak valid dan jadi 0, ini adalah masalah data
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) {
                        return const CustomAlertDialog(
                          title: "Data Pengguna Tidak Lengkap!",
                          message:
                              "ID pengguna tidak valid. Mohon login ulang.",
                          type: DialogType.error,
                          buttonText: "Oke",
                        );
                      },
                    );
                    return; // Hentikan navigasi jika error
                  }

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
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailuserInputNama(
                                userId:
                                    parsedUserId, // Menggunakan userId yang sudah di-parse dan aman
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
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
                      .contains("Gagal terhubung ke server")) {
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
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Verifikasi OTP Kamu",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      SizedBox(
                        child: Image.asset(
                          'assets/images/otp.png',
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Text(
                        "Masukkan kode 4 digit yang telah kami kirim ke nomor",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),
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
                          const SizedBox(width: 11),
                          _otpTextField(context, controller2),
                          const SizedBox(width: 11),
                          _otpTextField(context, controller3),
                          const SizedBox(width: 11),
                          _otpTextField(context, controller4),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.08),
                      SizedBox(
                        width: screenWidth * 0.8,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AppColors.greenGradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: _onVerifyOtpPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Konfirmasi",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Loading overlay
                  if (_isLoading)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: !_isLoading,
                        child: AnimatedOpacity(
                          opacity: _isLoading ? 0.7 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: const Color.fromARGB(0, 0, 0, 0),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
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
