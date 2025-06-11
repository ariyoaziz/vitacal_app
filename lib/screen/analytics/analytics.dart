// lib/screen/analytics/analytics.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/models/userdetail_model.dart';
import 'package:vitacal_app/screen/analytics/card_beratgrafik.dart';
import 'package:vitacal_app/screen/analytics/card_kal.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/screen/home/kalender.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';

import 'package:vitacal_app/screen/analytics/card_berat.dart';
import 'package:vitacal_app/screen/analytics/card_bmi.dart';

import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_state.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/services/userdetail_service.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  // Dummy data sebaiknya di-mock atau diambil dari service/repository,
  // bukan langsung di-init di State jika tujuannya untuk mocking data bloc.
  // Namun, untuk contoh ini, saya biarkan sesuai struktur Anda.
  final List<Map<String, dynamic>> _dummyWeightHistory =
      UserDetailService.getDummyWeightHistory();
  final List<Map<String, dynamic>> _dummyCalorieData =
      UserDetailService.getDummyCalorieData();

  @override
  void initState() {
    super.initState();
    // Memuat data user detail saat widget pertama kali dibuat
    context.read<UserDetailBloc>().add(LoadUserDetail());
  }

  Future<void> _refreshData() async {
    // Memicu event LoadUserDetail untuk refresh data
    context.read<UserDetailBloc>().add(LoadUserDetail());
    // Beri sedikit delay untuk feedback visual pada RefreshIndicator
    await Future.delayed(const Duration(milliseconds: 500));
    // Memastikan widget masih terpasang sebelum memanggil setState/lainnya
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    // Penggunaan MediaQuery untuk padding global, tidak untuk setiap elemen.
    // Fixed padding value lebih disarankan untuk konsistensi desain.
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    const double iconSize = 24.0; // Ukuran ikon standar

    return Scaffold(
      // Menggunakan warna solid sebagai pengganti withOpacity untuk background
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          backgroundColor: AppColors.screen,
          strokeWidth: 3,
          displacement: 60,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            // Padding global yang konsisten
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0, // Fixed padding
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan ikon (konsisten dengan halaman Profil)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          SvgPicture.asset("assets/icons/logo.svg", height: 35),
                      onPressed: () {/* No action for logo */},
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/calender.svg",
                              height: iconSize),
                          onPressed: () => showKalenderDialog(context),
                        ),
                        const SizedBox(width: 11),
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/notif.svg",
                              height: iconSize),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Notifikasi()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 33),

                // Judul Halaman "Analytics"
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/analytics.svg",
                        height: 28), // Ukuran ikon disesuaikan
                    const SizedBox(width: 11),
                    const Text(
                      "Analytics",
                      style: TextStyle(
                          fontSize: 22, // Ukuran font judul lebih besar
                          fontWeight: FontWeight.w700, // Lebih tebal
                          color: AppColors.darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 33),

                // Menggunakan BlocConsumer untuk mendengarkan state UserDetailBloc
                BlocConsumer<UserDetailBloc, UserDetailState>(
                  listener: (context, state) {
                    if (state is UserDetailError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error: ${state.message}'),
                            backgroundColor: Colors.red),
                      );
                    } else if (state is UserDetailUpdateSuccess) {
                      // Tampilkan dialog sukses otomatis setelah update berhasil
                      CustomAlertDialog.show(
                        // Pastikan 'CustomAlertDialog' adalah nama kelas yang benar, bukan 'CostumAlertDialog'
                        context: context,
                        title: "Pembaruan Berhasil!",
                        message: "Data profil Anda telah berhasil diperbarui.",
                        type: DialogType.success,
                        showButton: false, // Tidak ada tombol OK
                        autoDismissDuration: const Duration(
                            seconds: 2), // Menghilang setelah 2 detik
                      );
                    }
                  },
                  builder: (context, state) {
                    // Menangani semua state yang membawa userDetail (Loaded, AddSuccess, UpdateSuccess)
                    UserDetailModel? userDetail;
                    if (state is UserDetailLoaded) {
                      userDetail = state.userDetail;
                    } else if (state is UserDetailAddSuccess) {
                      userDetail = state.userDetail;
                    } else if (state is UserDetailUpdateSuccess) {
                      userDetail = state.userDetail;
                    }

                    if (state is UserDetailLoading ||
                        state is UserDetailInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (userDetail != null) {
                      // Hitung BMI hanya jika userDetail tersedia
                      double heightInMeter = userDetail.tinggiBadan / 100;
                      double bmi = userDetail.beratBadan /
                          (heightInMeter * heightInMeter);

                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Sejajarkan di atas
                            children: [
                              Expanded(
                                child: BeratCard(
                                  label: "Berat Sekarang",
                                  icon: "assets/icons/weight_sekarang.svg",
                                  value: userDetail.beratBadan,
                                  onUpdate: (value) {
                                    // Mengirim event UpdateUserDetail untuk berat_badan
                                    context.read<UserDetailBloc>().add(
                                          UpdateUserDetail(
                                              updates: {'berat_badan': value}),
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(
                                  width: 16), // Spasi antar kartu lebih besar
                              Expanded(
                                child: BeratCard(
                                  label: "Tinggi Badan",
                                  icon:
                                      "assets/icons/weight_sekarang.svg", // Ganti dengan ikon tinggi badan jika ada
                                  value: userDetail.tinggiBadan,
                                  onUpdate: (value) {
                                    // Mengirim event UpdateUserDetail untuk tinggi_badan
                                    context.read<UserDetailBloc>().add(
                                          UpdateUserDetail(
                                              updates: {'tinggi_badan': value}),
                                        );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24), // Spasi antar baris kartu
                          BmiCard(bmi: bmi),
                          const SizedBox(height: 24), // Spasi setelah BMI Card
                          KaloriChartCard(data: _dummyCalorieData),
                          const SizedBox(
                              height: 24), // Spasi setelah Kalori Card
                          CardBeratGrafik(data: _dummyWeightHistory),
                        ],
                      );
                    } else if (state is UserDetailError) {
                      // Tampilan error yang lebih informatif
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat data: ${state.message}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }
                    // Fallback jika state tidak terduga (misal UserDetailInitial tanpa data)
                    return const Center(
                      child: Text(
                          'Tidak ada data detail pengguna untuk ditampilkan.'),
                    );
                  },
                ),
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.75, // Batasi lebar teks
                    child: Text(
                      "Yuk, cek kalorimu dan terus melangkah menuju hidup sehat!",
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
