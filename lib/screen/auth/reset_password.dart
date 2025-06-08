import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import bloc
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart'; // Import AuthBloc
import 'package:vitacal_app/blocs/auth/auth_event.dart'; // Import AuthEvent
import 'package:vitacal_app/blocs/auth/auth_state.dart'; // Import AuthState
import 'package:vitacal_app/screen/auth/login.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/themes/colors.dart';

class ResetPassword extends StatefulWidget {
  // Menerima nomor telepon dari halaman sebelumnya
  final String phoneNumber;
  final String otpCode;

  const ResetPassword({super.key, required this.phoneNumber, required this.otpCode});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // State untuk indikator loading

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      // Contoh: minimal 6 karakter
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  // Fungsi untuk validasi konfirmasi password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
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
            // Tampilkan dialog error
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return CustomAlertDialog(
                  title: "Reset Password Gagal",
                  message: state.message, // Pesan error dari BLoC
                  type: DialogType.error,
                  buttonText: "Oke",
                );
              },
            );
          }

          if (state is AuthPasswordResetSuccess) {
            // State sukses reset password
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return CustomAlertDialog(
                  title: "Berhasil",
                  message: state.message, // Pesan sukses dari BLoC
                  type: DialogType.success,
                  showButton: true,
                  buttonText: 'Login',
                  onButtonPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const Login()),
                      (route) => false,
                    );
                  },
                );
              },
            );
          }
        },
        child: AbsorbPointer(
          // Mencegah interaksi saat loading
          absorbing: _isLoading,
          child: Stack(
            // Gunakan Stack untuk overlay loading
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
                          "Atur Ulang Kata Sandi",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        // Logo Image
                        SizedBox(
                          child: Image.asset(
                            'assets/images/update_password.png',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "Ubah kata sandimu, karena kamu lupa atau ingin\n",
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: "ganti dengan yang baru",
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        // Input Password Baru
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password Baru',
                              hintText: 'Password Baru',
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
                                  'assets/icons/sandi.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 33),
                        // Input Konfirmasi Password
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText:
                                !_isPasswordVisible, // Menggunakan visibility yang sama
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              hintText: 'Konfirmasi Password',
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
                                  'assets/icons/sandi.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        // Tombol Ubah Kata Sandi
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: AppColors.greenGradient,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isLoading) return; // Mencegah double tap

                                // Validasi input di sisi client
                                final passwordError =
                                    _validatePassword(_passwordController.text);
                                final confirmPasswordError =
                                    _validateConfirmPassword(
                                        _confirmPasswordController.text);

                                if (passwordError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(passwordError)),
                                  );
                                  return;
                                }
                                if (confirmPasswordError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(confirmPasswordError)),
                                  );
                                  return;
                                }

                                // Jika validasi lolos, panggil BLoC
                                context.read<AuthBloc>().add(
                                      ResetPasswordEvent(
                                        phoneNumber: widget.phoneNumber,
                                        otpCode: widget
                                            .otpCode, // <-- Gunakan OTP dari widget
                                        newPassword: _passwordController.text,
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
                              child: _isLoading // Tampilkan loading indicator
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Ubah Kata Sandi",
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
              if (_isLoading) // Overlay loading
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
