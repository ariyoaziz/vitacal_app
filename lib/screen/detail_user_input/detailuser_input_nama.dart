import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_gender.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart';

class DetailuserInputNama extends StatefulWidget {
  // Terima user_id dari halaman sebelumnya (misal dari OtpRegistrasi)
  final int userId; // userId adalah int di backend

  const DetailuserInputNama({super.key, required this.userId});

  @override
  State<DetailuserInputNama> createState() => _DetailuserInputNamaState();
}

class _DetailuserInputNamaState extends State<DetailuserInputNama> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Kunci untuk form
  final double _progressValue = 0.17; // Progres untuk langkah pertama (1/6)

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi saat tombol "Lanjut" ditekan
  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      // Validasi form
      // Simpan data nama ke objek UserDetailFormData sementara
      final formData = UserDetailFormData(
        userId: widget.userId, // Ambil userId dari widget
        nama: _nameController.text.trim(), // Bersihkan spasi
      );

      // Navigasi ke layar berikutnya (DetailuserUsia) dengan membawa data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailuserGender(formData: formData), // Meneruskan data
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              // Garis Progress
              SizedBox(
                width: screenWidth * 0.8,
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Expanded untuk menyesuaikan layout agar tombol tetap di bawah
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      // Gunakan Form untuk validasi input
                      key: _formKey,
                      child: Column(
                        children: [
                          // Judul
                          const Text(
                            "Masukan Nama Kamu",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 11),
                          const Text(
                            "Hai, Kami ingin mengenal Anda untuk menjadikan aplikasi VitaCal dipersonalisasi untuk Anda.",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 33),
                          // Input Nama
                          SizedBox(
                            width: screenWidth * 0.85,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nama',
                                hintText: 'Nama Lengkap',
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
                              ),
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
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
