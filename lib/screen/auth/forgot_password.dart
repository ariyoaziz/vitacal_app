import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';
import 'package:vitacal_app/screen/auth/login.dart';
import 'package:vitacal_app/screen/auth/otp/otp_forgotpassword.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter/gestures.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isDialogShowing = false; // Flag untuk mencegah dialog duplikat

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          // Tambahkan 'async' karena showDialog bersifat async
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
            // --- LOGIKA PENCEGAHAN DIALOG DUPLIKAT ---
            if (_isDialogShowing) {
              return; // Jika dialog sudah tampil, jangan tampilkan lagi
            }
            setState(() {
              _isDialogShowing =
                  true; // Set flag menjadi true saat dialog akan tampil
            });

            // Tampilkan dialog error
            await CustomAlertDialog.show(
              // Gunakan 'await' agar kode selanjutnya menunggu dialog ditutup
              context: context,
              title: "Gagal Mengirim OTP",
              message: state.message,
              type: DialogType.error,
              buttonText: "Oke",
            );

            // --- RESET FLAG SETELAH DIALOG DITUTUP ---
            if (mounted) {
              // Pastikan widget masih ada di tree
              setState(() {
                _isDialogShowing = false; // Reset flag setelah dialog ditutup
              });
            }
            // ------------------------------------------
          }

          if (state is AuthPasswordResetOtpSent) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OtpForgotpassword(phoneNumber: _phoneController.text),
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
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.1,
                        bottom: screenHeight * 0.05,
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Lupa Kata Sandi?",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Image.asset(
                              'assets/images/forgot_password.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 50),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "Masukan nomor whatsapp yang terdaftar.\n",
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "Kami akan mengirimkan kode untuk reset kata sandi.",
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.08),
                          SizedBox(
                            width: screenWidth * 0.8,
                            child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Phone Number',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.primary, width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.primary, width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/phone.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
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

                                  if (_phoneController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Nomor telepon tidak boleh kosong!')),
                                    );
                                    return;
                                  }

                                  context.read<AuthBloc>().add(
                                        RequestPasswordResetEvent(
                                          phoneNumber: _phoneController.text,
                                        ),
                                      );
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
                                        "Lanjut",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 33),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Sudah ingat kata sandimu? ',
                              style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: 'Masuk disini!',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Login()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
