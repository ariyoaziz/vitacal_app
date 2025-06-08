// lib/screen/auth/otp/otp_forgotpassword.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';
import 'package:vitacal_app/screen/auth/reset_password.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/themes/colors.dart';

class OtpForgotpassword extends StatefulWidget {
  final String phoneNumber;

  const OtpForgotpassword({super.key, required this.phoneNumber});

  @override
  State<OtpForgotpassword> createState() => _OtpForgotpasswordState();
}

class _OtpForgotpasswordState extends State<OtpForgotpassword> {
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
          } else if (value.isEmpty && controller.text.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: BlocListener<AuthBloc, AuthState>(
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

          if (state is AuthError) {
            CustomAlertDialog(
              title: "Verifikasi Gagal",
              message: state.message,
              type: DialogType.error,
              buttonText: "Oke",
            );
          }

          // --- PERBAIKAN DI SINI ---
          if (state is AuthPasswordResetOtpVerified) {
            // This state now carries otpCode
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPassword(
                  phoneNumber: state.phoneNumber,
                  otpCode: state.otpCode, // <--- PASS THE OTP CODE HERE
                ),
              ),
            );
          }
        },
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.08,
                      bottom: screenHeight * 0.05,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                    ),
                    child: Column(
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
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "Masukan kode 4 digit yang kami kirim ke nomor\n",
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "whatsapp kamu, untuk verifikasi password\n",
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
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
                              onPressed: () {
                                if (_isLoading) return;

                                String otp = controller1.text +
                                    controller2.text +
                                    controller3.text +
                                    controller4.text;

                                if (otp.length == 4) {
                                  // Call AuthBloc to verify the OTP
                                  context.read<AuthBloc>().add(
                                        VerifyResetOtpEvent(
                                          // Use the correct event for reset OTP verification
                                          otpCode: otp,
                                          phoneNumber: widget.phoneNumber,
                                        ),
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Mohon masukkan OTP lengkap!'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
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
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
