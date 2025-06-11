// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_usia.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart';
import 'package:vitacal_app/models/enums.dart';

class DetailuserGender extends StatefulWidget {
  final UserDetailFormData formData;

  const DetailuserGender({super.key, required this.formData});

  @override
  State<DetailuserGender> createState() => _DetailuserGenderState();
}

class _DetailuserGenderState extends State<DetailuserGender> {
  final double _progressValue = 0.33;
  JenisKelamin? _selectedGender;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _genderErrorMessage;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.formData.jenisKelamin;
  }

  void _onNextPressed() {
    setState(() {
      _genderErrorMessage = null;
    });

    if (_selectedGender == null) {
      setState(() {
        _genderErrorMessage = "Eits, jangan lupa pilih jenis kelaminmu ya!";
      });
      return;
    }

    final updatedFormData = widget.formData.copyWith(
      jenisKelamin: _selectedGender,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailuserUsia(formData: updatedFormData),
      ),
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
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.65,
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
                ],
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pilih Gender Kamu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Kami ingin mengenal Anda lebih baik untuk menjadikan aplikasi VitaCal dipersonalisasi.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Pilihan Gender (Laki-laki)
                      _buildGenderOption(
                        context,
                        label: "Laki-laki",
                        gender: JenisKelamin.lakiLaki,
                        icon: Icons.male,
                        isSelected: _selectedGender == JenisKelamin.lakiLaki,
                        onTap: () {
                          setState(() {
                            _selectedGender = JenisKelamin.lakiLaki;
                            _genderErrorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Pilihan Gender (Perempuan)
                      _buildGenderOption(
                        context,
                        label: "Perempuan",
                        gender: JenisKelamin.perempuan,
                        icon: Icons.female,
                        isSelected: _selectedGender == JenisKelamin.perempuan,
                        onTap: () {
                          setState(() {
                            _selectedGender = JenisKelamin.perempuan;
                            _genderErrorMessage = null;
                          });
                        },
                      ),

                      if (_genderErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            _genderErrorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
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

  // Widget helper untuk Pilihan Gender (Laki-laki/Perempuan)
  Widget _buildGenderOption(
    BuildContext context, {
    required String label,
    required JenisKelamin gender,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
          side: isSelected
              ? const BorderSide(color: AppColors.primary, width: 2)
              : BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        // PERBAIKAN: Warna background saat terpilih agar sama dengan picker usia
        color: isSelected ? AppColors.lightPrimary : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.darkGrey,
                size: 28,
              ),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
