import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_usia.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart'; // Impor model data form
import 'package:vitacal_app/models/enums.dart'; // Impor enum JenisKelamin

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
  String? _genderErrorMessage; // Variabel untuk pesan error validasi kustom

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.formData.jenisKelamin;
  }

  void _onNextPressed() {
    setState(() {
      _genderErrorMessage =
          null; // Reset pesan error setiap kali tombol ditekan
    });

    if (_selectedGender == null) {
      setState(() {
        _genderErrorMessage =
            "Eits, jangan lupa pilih jenis kelaminmu ya!"; // Pesan error yang lebih ramah
      });
      return; // Hentikan navigasi jika validasi gagal
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
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              // Baris untuk Progress dan Tombol Back
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Back
                  Ink(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                        height: 15,
                        width: 15,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                      },
                    ),
                  ),

                  // Garis Progress
                  SizedBox(
                    width: screenWidth * 0.73,
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),

              // Expanded untuk menyesuaikan layout agar button tetap di bawah
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          // Judul
                          const Text(
                            "Pilih Gender Kamu",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          // --- PERBAIKAN: Penempatan Pesan Error di sini ---
                          if (_genderErrorMessage !=
                              null) // Tampilkan hanya jika ada pesan error
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom:
                                      8.0), // Padding atas dan bawah untuk error
                              child: Text(
                                _genderErrorMessage!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          // --- AKHIR PERBAIKAN ---
                          const SizedBox(height: 11),
                          const Text(
                            "Kami ingin mengenal Anda lebih baik untuk menjadikan aplikasi VitaCal dipersonalisasi.",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 33),

                          // Pilihan Gender dengan Card
                          Column(
                            children: [
                              // Laki-laki Option
                              SizedBox(
                                width: screenWidth * 0.85,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGender = JenisKelamin.lakiLaki;
                                      _genderErrorMessage =
                                          null; // Hapus error saat memilih
                                    });
                                  },
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21),
                                      side: _selectedGender ==
                                                  JenisKelamin.lakiLaki &&
                                              _genderErrorMessage != null
                                          ? const BorderSide(
                                              color: Colors.red, width: 2)
                                          : BorderSide.none,
                                    ),
                                    color:
                                        _selectedGender == JenisKelamin.lakiLaki
                                            ? const Color(0xFFF1F0E9)
                                            : Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 15),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.male,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Laki-laki",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Perempuan Option
                              SizedBox(
                                width: screenWidth * 0.85,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGender = JenisKelamin.perempuan;
                                      _genderErrorMessage =
                                          null; // Hapus error saat memilih
                                    });
                                  },
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21),
                                      side: _selectedGender ==
                                                  JenisKelamin.perempuan &&
                                              _genderErrorMessage != null
                                          ? const BorderSide(
                                              color: Colors.red, width: 2)
                                          : BorderSide.none,
                                    ),
                                    color: _selectedGender ==
                                            JenisKelamin.perempuan
                                        ? const Color(0xFFF1F0E9)
                                        : Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 15),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.female,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Perempuan",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Lanjut
              SizedBox(
                width: screenWidth * 0.85,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.greenGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
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
            ],
          ),
        ),
      ),
    );
  }
}
