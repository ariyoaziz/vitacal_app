// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';
import 'package:vitacal_app/screen/auth/forgot_password.dart';
import 'package:vitacal_app/screen/auth/otp/otp_registrasi.dart';
import 'package:vitacal_app/screen/auth/registrasi.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_input_nama.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';

import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter/gestures.dart';

import 'package:vitacal_app/screen/main_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isDialogShowing = false; // Flag untuk mencegah duplikasi dialog

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginUserEvent(
              identifier: _identifierController.text.trim(),
              password: _passwordController.text,
            ),
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
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.1,
                bottom: screenHeight * 0.05,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) async {
                  // Mengatur status loading
                  if (state is AuthLoading) {
                    setState(() {
                      _isLoading = true;
                    });
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                  }

                  // Mencegah duplikasi dialog
                  if (_isDialogShowing) {
                    return;
                  }

                  // Penanganan state login berhasil
                  if (state is AuthLoginSuccess) {
                    setState(() {
                      _isDialogShowing = true;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(
                          showSuccessDialog: true,
                        ),
                      ),
                    ).then((_) {
                      if (mounted) {
                        setState(() {
                          _isDialogShowing = false;
                        });
                      }
                    });
                  }
                  // Penanganan state error login
                  else if (state is AuthError) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _isDialogShowing = true;
                    setState(() {});

                    String dialogTitle = "Login Gagal!";
                    String dialogMessage = state.message;
                    DialogType dialogType = DialogType.error;

                    bool navigateToOtpRegistrasi = false;
                    bool navigateToProfileCompletion = false;

                    // Ambil userId dan phoneNumber langsung dari AuthError state
                    final int? userIdFromState = state.userId;
                    final String? phoneNumberFromState = state.phoneNumber;

                    final cleanMessage = state.message.trim();

                    if (cleanMessage.contains("User tidak ditemukan")) {
                      dialogTitle = "Akun Tidak Ditemukan!";
                      dialogMessage =
                          "Username, email, atau nomor telepon tidak terdaftar.";
                      dialogType = DialogType.error;
                    } else if (cleanMessage.contains("Password salah")) {
                      dialogTitle = "Password Salah!";
                      dialogMessage =
                          "Password yang kamu masukkan tidak cocok. Coba lagi ya!";
                      dialogType = DialogType.error;
                    } else if (cleanMessage
                        .contains("Akun belum diverifikasi")) {
                      dialogTitle = "Akun Belum Diverifikasi!";
                      dialogMessage =
                          "Akunmu belum diverifikasi. Mohon cek OTP di WhatsApp untuk verifikasi.";
                      dialogType = DialogType.warning;
                      navigateToOtpRegistrasi = true;
                      // userIdFromState dan phoneNumberFromState sudah diambil dari state
                    } else if (cleanMessage
                        .contains("Profil Anda belum lengkap")) {
                      dialogTitle = "Lengkapi Profil Anda!";
                      dialogMessage =
                          "Profil Anda belum lengkap. Mohon lengkapi data diri Anda untuk dapat login.";
                      dialogType = DialogType.warning;
                      navigateToProfileCompletion = true;
                    } else if (cleanMessage
                        .contains("Gagal terhubung ke server")) {
                      dialogTitle = "Jaringanmu Bermasalah?";
                      dialogMessage =
                          "Gagal terhubung ke server. Pastikan koneksi internetmu stabil dan coba lagi ya!";
                      dialogType = DialogType.error;
                    } else if (cleanMessage.contains("wajib diisi")) {
                      dialogTitle = "Input Belum Lengkap!";
                      dialogMessage = "Mohon isi identifier dan password ya!";
                      dialogType = DialogType.warning;
                    } else {
                      dialogTitle = "Ada Error Nih!";
                      dialogMessage =
                          "Terjadi masalah tak terduga. Mohon coba lagi nanti ya!";
                      dialogType = DialogType.error;
                    }

                    // Menampilkan CustomAlertDialog
                    await showDialog(
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

                    // Reset flag setelah dialog ditutup
                    if (mounted) {
                      setState(() {
                        _isDialogShowing = false;
                      });
                    }

                    // --- Logika navigasi setelah dialog ditutup ---
                    if (navigateToOtpRegistrasi) {
                      // Pastikan userId dan phoneNumber tidak null sebelum navigasi
                      if (userIdFromState != null &&
                          phoneNumberFromState != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtpRegistrasi(
                              userId:
                                  userIdFromState, // Menggunakan userId dari AuthError state
                              phoneNumber:
                                  phoneNumberFromState, // Menggunakan phoneNumber dari AuthError state
                            ),
                          ),
                        );
                      } else {
                        // Tampilkan SnackBar jika informasi tidak lengkap (misal: backend tidak mengirimkan data ini)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Tidak dapat melanjutkan verifikasi. Informasi pengguna tidak lengkap atau backend tidak menyediakan data.")),
                        );
                      }
                    } else if (navigateToProfileCompletion) {
                      // --- PERBAIKAN: Navigasi ke DetailuserInputNama ---
                      // Pastikan userIdFromState tidak null sebelum navigasi
                      if (userIdFromState != null) {
                        Navigator.pushReplacement(
                          // Menggunakan pushReplacement sesuai permintaan
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailuserInputNama(
                              userId:
                                  userIdFromState, // Meneruskan userId dari AuthError state
                            ),
                          ),
                        );
                      } else {
                        // Jika userId tidak tersedia dan UserDetailScreen memerlukannya
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Tidak dapat melanjutkan ke lengkapi profil. Informasi user ID tidak tersedia.")),
                        );
                      }
                    }
                  }
                },
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Stack(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Hore, Ketemu Lagi!",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              SizedBox(
                                child: SvgPicture.asset(
                                  'assets/icons/logo1.svg',
                                ),
                              ),
                              const Text(
                                "Sahabat Nutrisi Sehatmu!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.08),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: TextFormField(
                                  controller: _identifierController,
                                  decoration: InputDecoration(
                                    labelText:
                                        'Username / Email / Nomor Telepon',
                                    hintText: 'Masukkan identifiermu',
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
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: SvgPicture.asset(
                                        'assets/icons/user.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Identifier tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 33),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Password',
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
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
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
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPassword(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Lupa kata sandi? Tenang, kami bantu!',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 33),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.greenGradient,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Belum punya akun? ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkGrey,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Daftar yuk!',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Registrasi()),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isLoading)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !_isLoading,
                              child: AnimatedOpacity(
                                opacity: _isLoading ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  color: Colors.black.withOpacity(0.0),
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
