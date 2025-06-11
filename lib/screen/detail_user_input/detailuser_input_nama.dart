// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_gender.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart';

class DetailuserInputNama extends StatefulWidget {
  final int userId;

  const DetailuserInputNama({super.key, required this.userId});

  @override
  State<DetailuserInputNama> createState() => _DetailuserInputNamaState();
}

class _DetailuserInputNamaState extends State<DetailuserInputNama> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double _progressValue = 0.17;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi saat tombol "Lanjut" ditekan - FUNGSI INI TIDAK DIUBAH
  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      final formData = UserDetailFormData(
        userId: widget.userId,
        nama: _nameController.text.trim(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailuserGender(formData: formData),
        ),
      );
    }
  }

  // Widget Helper untuk Input Decoration
  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      // PERBAIKAN: Menggunakan AppColors.mediumGrey untuk label dan hint
      labelStyle: const TextStyle(color: AppColors.mediumGrey),
      hintStyle: const TextStyle(color: AppColors.mediumGrey),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        borderRadius: BorderRadius.circular(12), // Radius konsisten
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: suffixIcon,
      fillColor: Colors.white,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // Konsisten dengan halaman auth
            vertical: screenHeight * 0.05, // Spasi vertikal yang nyaman
          ),
          child: Column(
            children: [
              // Garis Progress
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: screenWidth * 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 10,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Judul
                          const Text(
                            "Masukan Nama Kamu",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28, // Ukuran font judul konsisten
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Deskripsi
                          const Text(
                            "Hai, Kami ingin mengenal Anda untuk menjadikan aplikasi VitaCal dipersonalisasi untuk Anda.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15, // Ukuran font deskripsi konsisten
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Input Nama
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: _buildInputDecoration(
                                labelText: 'Nama Lengkap',
                                hintText: 'Masukkan nama lengkap kamu',
                              ),
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.darkGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Lanjut
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.greenGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Lanjut",
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
    );
  }
}
