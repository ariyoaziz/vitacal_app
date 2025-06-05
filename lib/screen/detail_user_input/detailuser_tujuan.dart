import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_state.dart';
import 'package:vitacal_app/models/enums.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/themes/colors.dart';

import 'package:vitacal_app/screen/auth/login.dart'; // <--- Import halaman Login

class DetailuserTujuan extends StatefulWidget {
  final UserDetailFormData formData;

  const DetailuserTujuan({super.key, required this.formData});

  @override
  State<DetailuserTujuan> createState() => _DetailuserTujuanState();
}

class _DetailuserTujuanState extends State<DetailuserTujuan> {
  final double _progressValue = 1.0; // <--- Nilai progress 1.0 (sudah selesai)
  Tujuan? _selectedTujuan;
  String? _tujuanErrorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTujuan = widget.formData.tujuan;
  }

  void _onFinishPressed() {
    setState(() {
      _tujuanErrorMessage = null;
    });

    if (_selectedTujuan == null) {
      setState(() {
        _tujuanErrorMessage = "Pilih tujuanmu dulu ya!";
      });
      return;
    }

    final updatedFormData = widget.formData.copyWith(
      tujuan: _selectedTujuan,
    );

    // --- TAMBAHKAN BARIS DEBUGGING INI ---
    print('--- Data UserDetailFormData sebelum pengiriman ---');
    print('User ID: ${updatedFormData.userId}');
    print('Nama: ${updatedFormData.nama}');
    print('Umur: ${updatedFormData.umur}');
    print('Jenis Kelamin: ${updatedFormData.jenisKelamin?.toApiString()}');
    print('Berat Badan: ${updatedFormData.beratBadan}');
    print('Tinggi Badan: ${updatedFormData.tinggiBadan}');
    print('Aktivitas: ${updatedFormData.aktivitas?.toApiString()}');
    print('Tujuan: ${updatedFormData.tujuan?.toApiString()}');
    print('--------------------------------------------------');
    // --- AKHIR DEBUGGING ---

    if (updatedFormData.nama == null ||
        updatedFormData.umur == null ||
        updatedFormData.jenisKelamin == null ||
        updatedFormData.beratBadan == null ||
        updatedFormData.tinggiBadan == null ||
        updatedFormData.aktivitas == null) {
      setState(() {
        _tujuanErrorMessage =
            "Terjadi kesalahan data. Mohon kembali ke halaman sebelumnya.";
      });
      return;
    }

    context.read<UserDetailBloc>().add(
          AddUserDetail(
            userId: updatedFormData.userId,
            nama: updatedFormData.nama!,
            umur: updatedFormData.umur!,
            jenisKelamin: updatedFormData.jenisKelamin!,
            beratBadan: updatedFormData.beratBadan!,
            tinggiBadan: updatedFormData.tinggiBadan!,
            aktivitas: updatedFormData.aktivitas!,
            tujuan: updatedFormData.tujuan,
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
          child: BlocListener<UserDetailBloc, UserDetailState>(
            listener: (context, state) {
              if (state is UserDetailLoading) {
                setState(() {
                  _isLoading = true;
                });
              } else {
                setState(() {
                  _isLoading = false;
                });
              }

              if (state is UserDetailAddedSuccess) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return CustomAlertDialog(
                      title: "Profilmu Sudah Lengkap!",
                      message:
                          "Yeay, profilmu berhasil disimpan! Silakan login kembali untuk memulai petualangan sehatmu!", // Pesan disesuaikan
                      buttonText:
                          "Oke, Login Sekarang!", // Teks tombol disesuaikan
                      type: DialogType.success,
                      showButton: true,
                      onButtonPressed: () {
                        // --- MODIFIKASI: Navigasi ke halaman Login dan hapus stack navigasi ---
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                          (Route<dynamic> route) =>
                              false, // Hapus semua rute sebelumnya
                        );
                        // --- AKHIR MODIFIKASI ---
                      },
                    );
                  },
                );
              } else if (state is UserDetailError) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    String dialogTitle = "Gagal Menyimpan Profil!";
                    String dialogMessage = state.message;
                    DialogType dialogType = DialogType.error;

                    final cleanMessage = state.message.trim();

                    if (cleanMessage.contains("sudah pernah dibuat")) {
                      dialogTitle = "Profil Sudah Ada Nih!";
                      dialogMessage =
                          "Sepertinya kamu sudah pernah mengisi detail profil. Kamu bisa mengeditnya nanti.";
                      dialogType = DialogType.warning;
                    } else if (cleanMessage.contains("User tidak ditemukan")) {
                      dialogTitle = "Pengguna Tidak Ditemukan!";
                      dialogMessage =
                          "Maaf, data akunmu tidak ditemukan. Coba login ulang ya.";
                      dialogType = DialogType.error;
                    } else if (cleanMessage.contains("Enum tidak valid")) {
                      dialogTitle = "Input Tidak Sesuai!";
                      dialogMessage =
                          "Ada pilihan yang tidak valid. Coba periksa kembali data kamu.";
                      dialogType = DialogType.error;
                    } else if (cleanMessage
                        .contains("Gagal terhubung ke server")) {
                      dialogTitle = "Jaringanmu Bermasalah?";
                      dialogMessage =
                          "Gagal terhubung ke server. Pastikan koneksi internetmu stabil dan coba lagi ya!";
                      dialogType = DialogType.error;
                    } else if (cleanMessage.contains("masalah tak terduga")) {
                      dialogTitle = "Ada Error Nih!";
                      dialogMessage =
                          "Terjadi masalah tak terduga di aplikasi. Kami sedang memperbaikinya. Mohon coba lagi nanti ya!";
                      dialogType = DialogType.error;
                    } else if (cleanMessage.contains("harus diisi") ||
                        cleanMessage.contains("tidak boleh kosong") ||
                        cleanMessage.contains("tidak valid")) {
                      dialogTitle = "Input Belum Lengkap!";
                      dialogMessage =
                          "Mohon lengkapi semua data yang wajib diisi ya!";
                      dialogType = DialogType.warning;
                    }

                    return CustomAlertDialog(
                      title: dialogTitle,
                      message: dialogMessage,
                      buttonText: "Oke",
                      type: dialogType,
                      showButton: true,
                    );
                  },
                );
              }
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.primary, width: 0.5),
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
                              Navigator.pop(context);
                            },
                          ),
                        ),
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
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Apa Tujuan Kamu?",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGrey,
                                ),
                              ),
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
                              Column(
                                children: [
                                  _buildTujuanCard(
                                    label: "Menurunkan Berat Badan",
                                    icon: Icons.remove_circle_outline,
                                    value: Tujuan.menurunkanBeratBadan,
                                    screenWidth: screenWidth,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTujuanCard(
                                    label: "Menambah Berat Badan",
                                    icon: Icons.add_circle_outline,
                                    value: Tujuan.menambahBeratBadan,
                                    screenWidth: screenWidth,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTujuanCard(
                                    label: "Menjaga Berat Badan Ideal",
                                    icon: Icons.balance,
                                    value: Tujuan.menjagaBeratBadanIdeal,
                                    screenWidth: screenWidth,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTujuanCard(
                                    label: "Menaikkan Massa Tubuh",
                                    icon: Icons.fitness_center,
                                    value: Tujuan.menaikanMassaTubuh,
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                              if (_tujuanErrorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 16.0, right: 16.0),
                                  child: Text(
                                    _tujuanErrorMessage!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.85,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: AppColors.greenGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          onPressed: _onFinishPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Selesai",
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
                if (_isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !_isLoading,
                      child: AnimatedOpacity(
                        opacity: _isLoading ? 0.7 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          color: const Color.fromARGB(0, 0, 0, 0),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTujuanCard({
    required String label,
    required IconData icon,
    required Tujuan value,
    required double screenWidth,
  }) {
    return SizedBox(
      width: screenWidth * 0.85,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTujuan = value;
            _tujuanErrorMessage = null;
          });
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
            side: _selectedTujuan == value && _tujuanErrorMessage != null
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
          ),
          color:
              _selectedTujuan == value ? const Color(0xFFF1F0E9) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
