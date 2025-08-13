// lib/screen/auth/forgot_password.dart
// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk SvgPicture
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';
import 'package:vitacal_app/screen/auth/login.dart'; // Halaman login
import 'package:vitacal_app/screen/auth/otp/otp_forgotpassword.dart'; // Halaman OtpForgotpassword
import 'package:vitacal_app/screen/widgets/costum_dialog.dart'; // CustomAlertDialog
import 'package:vitacal_app/themes/colors.dart'; // AppColors
import 'package:flutter/gestures.dart'; // Untuk TapGestureRecognizer

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

  // Fungsi untuk memicu permintaan reset password
  void _onRequestPasswordResetPressed() {
    if (_isLoading) return; // Jangan izinkan double tap saat loading

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak boleh kosong!')),
      );
      return;
    }

    // Memicu event RequestPasswordResetEvent ke AuthBloc
    context.read<AuthBloc>().add(
          RequestPasswordResetEvent(
            phoneNumber: _phoneController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    try {
      final AuthBloc authBlocInstance = context.read<AuthBloc>();
      print(
          'DEBUG FORGOT_PASSWORD: AuthBloc instance found: $authBlocInstance (Type: ${authBlocInstance.runtimeType})');
    } catch (e) {
      print(
          'ERROR FORGOT_PASSWORD: Failed to read AuthBloc in build method: $e');
    }

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          // Mengelola status loading lokal
          setState(() {
            _isLoading = state is AuthLoading;
          });

          if (state is AuthError) {
            // --- LOGIKA PENCEGAHAN DIALOG DUPLIKAT ---
            if (_isDialogShowing) {
              return; // Jika dialog sudah tampil, jangan tampilkan lagi
            }
            if (!mounted) {
              return;
            } // Penting: cek mounted sebelum showDialog
            setState(() {
              _isDialogShowing =
                  true; // Set flag menjadi true saat dialog akan tampil
            });

            // Tampilkan dialog error
            await CustomAlertDialog.show(
              context: context,
              title: "Gagal Mengirim OTP",
              message: state.message,
              type: DialogType.error,
              buttonText: "Oke",
              showButton: true,
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
            if (!mounted) {
              return;
            } // Penting: cek mounted sebelum navigasi
            // Navigasi ke halaman OTP reset password setelah OTP terkirim
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    OtpForgotpassword(phoneNumber: _phoneController.text),
              ),
            );
          }
        },
        child: AbsorbPointer(
          // Mencegah interaksi saat loading
          absorbing: _isLoading,
          child: Stack(
            children: [
              SafeArea(
                // Menjaga konten di dalam area aman perangkat
                child: Center(
                  // Memposisikan konten di tengah layar
                  child: SingleChildScrollView(
                    // Memungkinkan scroll jika konten melebihi layar
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.1,
                      bottom: screenHeight * 0.05,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                    ),
                    child: Column(
                      // Mengatur widget secara vertikal
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
                        SizedBox(height: screenHeight * 0.05), // Spasi vertikal
                        SizedBox(
                          // Mengatur ukuran gambar
                          width: 300,
                          height: 300,
                          child: Image.asset(
                            'assets/images/forgot_password.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 50), // Spasi
                        RichText(
                          // Teks kaya dengan format berbeda
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
                        SizedBox(height: screenHeight * 0.08), // Spasi
                        // --- PERBAIKAN: Sesuaikan ukuran TextField ---
                        SizedBox(
                          width: double
                              .infinity, // Ambil lebar penuh Container/SizedBox
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
                        SizedBox(height: screenHeight * 0.08), // Spasi
                        SizedBox(
                          // Tombol Konfirmasi
                          width: screenWidth * 0.9,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient:
                                  AppColors.greenGradient, // Gradien warna
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _onRequestPasswordResetPressed, // Memanggil fungsi yang benar
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Latar belakang transparan untuk gradien
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
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
                        const SizedBox(height: 33), // Spasi
                        RichText(
                          // Teks login
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
                                          builder: (context) => const Login()),
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
              // Indikator loading overlay
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
