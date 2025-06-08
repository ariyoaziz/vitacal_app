// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';
import 'package:vitacal_app/blocs/auth/auth_state.dart';
import 'package:vitacal_app/screen/auth/login.dart';
import 'package:vitacal_app/screen/auth/otp/otp_registrasi.dart'; // Pastikan path ini benar
import 'package:vitacal_app/screen/detail_user_input/detailuser_input_nama.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';

import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Registrasi extends StatefulWidget {
  const Registrasi({super.key});

  @override
  State<Registrasi> createState() => _RegistrasiState();
}

class _RegistrasiState extends State<Registrasi> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol daftar ditekan
  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      // Memicu validasi pada semua TextFormField
      // Periksa kecocokan password
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Password dan Konfirmasi Password tidak cocok nih!')),
        );
        return;
      }

      // Kirim event RegisterUserEvent ke AuthBloc
      context.read<AuthBloc>().add(
            RegisterUserEvent(
              username:
                  _usernameController.text.trim(), // Pastikan trim untuk input
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
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
                top: screenHeight * 0.05,
                bottom: screenHeight * 0.05,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  // Mengatur status loading
                  if (state is AuthLoading) {
                    setState(() {
                      _isLoading = true; // Tampilkan loading overlay
                    });
                  } else {
                    setState(() {
                      _isLoading = false; // Sembunyikan loading overlay
                    });
                  }

                  // Penanganan state registrasi berhasil
                  if (state is AuthRegisterSuccess) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return CustomAlertDialog(
                          title: "Yeay, Akunmu Berhasil Dibuat!",
                          message:
                              "Kode OTP sudah dikirim ke WhatsApp kamu untuk verifikasi. Yuk, segera cek!",
                          type: DialogType.success,
                          showButton: false,
                          autoDismissDuration: const Duration(seconds: 3),
                          onButtonPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpRegistrasi(
                                  userId: state.userId,
                                  phoneNumber: state.phoneNumber,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  // Penanganan state OTP terverifikasi (ini seharusnya jarang terpicu di layar ini)
                  else if (state is AuthOtpVerified) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return CustomAlertDialog(
                          title: "Verifikasi Berhasil!",
                          message:
                              "Akunmu berhasil diverifikasi. Selamat datang di VitaCal!",
                          buttonText: "Masuk",
                          type: DialogType.success,
                          showButton: true,
                          onButtonPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailuserInputNama(
                                      userId: int.parse(state.user.userId
                                          as String))), // Gunakan state.user.userId
                            );
                          },
                        );
                      },
                    );
                  }
                  // Penanganan state error umum
                  else if (state is AuthError) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    String
                        dialogTitle; // Tidak perlu inisialisasi default di sini
                    String dialogMessage;
                    DialogType dialogType;

                    final cleanMessage = state.message.trim();

                    if (cleanMessage.contains("sudah terdaftar")) {
                      dialogTitle = "Akunmu Sudah Terdaftar Nih!";
                      dialogMessage =
                          "Sepertinya email, username, atau nomor telepon ini sudah terpakai. Yuk, coba login atau daftar pakai data lain!";
                      dialogType =
                          DialogType.warning; // Tipe peringatan (kuning/oranye)
                    } else if (cleanMessage
                        .contains("Gagal terhubung ke server")) {
                      dialogTitle = "Jaringanmu Bermasalah?";
                      dialogMessage =
                          "Gagal terhubung ke server. Pastikan koneksi internetmu stabil dan coba lagi ya!";
                      dialogType = DialogType.error;
                    } else if (cleanMessage
                            .contains("data tidak boleh kosong") ||
                        cleanMessage.contains("harus diisi")) {
                      dialogTitle = "Input Belum Lengkap!";
                      dialogMessage =
                          "Yuk, isi semua data yang diperlukan dengan lengkap ya!";
                      dialogType = DialogType.warning;
                    } else {
                      // Ini adalah catch-all untuk semua error yang tidak cocok dengan kondisi di atas
                      dialogTitle = "Ada Error Nih!";
                      dialogMessage =
                          "Terjadi masalah tak terduga di aplikasi. Kami sedang memperbaikinya. Mohon coba lagi nanti ya!";
                      dialogType = DialogType.error;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Dialog tidak bisa ditutup sembarangan
                      builder: (BuildContext dialogContext) {
                        return CustomAlertDialog(
                          title: dialogTitle,
                          message:
                              dialogMessage, // Gunakan pesan yang sudah di-custom
                          buttonText: "Oke", // Teks tombol lebih user-friendly
                          type: dialogType, // Tipe dialog (error/warning)
                          showButton:
                              true, // Selalu tampilkan tombol OK untuk error/warning
                          onButtonPressed: () {
                            print(
                                "Pengguna klik 'Oke' untuk error/warning registrasi");
                          },
                        );
                      },
                    );
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
                                "Ayo Gabung,",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                "dan Mulai Hidup Sehat!",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Username',
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
                                      return 'Username tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 33),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Email',
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
                                        'assets/icons/email.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    if (!value.contains('@') ||
                                        !value.contains('.')) {
                                      return 'Email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 33),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Nomor Telepon',
                                    hintText: 'Nomor Telepon',
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
                                        'assets/icons/phone.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nomor telepon tidak boleh kosong';
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
                                    if (value.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 33),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
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
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi password tidak boleh kosong';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Password tidak cocok';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              const Text(
                                "Siap capai tujuan sehatmu?",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 11),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Klik ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Daftar Sekarang",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " dan mulai perjalanan\n",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "barumu bersama ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Vita",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Cal!",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.greenGradient,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _onRegisterPressed,
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
                                      "Daftar Sekarang",
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
                              const Text(
                                "Udah punya akun? wah, tinggal masuk aja!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 5),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
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
                                  color: Colors.black.withOpacity(
                                      0.0), // Background tetap transparan (0.0 opacity)
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
