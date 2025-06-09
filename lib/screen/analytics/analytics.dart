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
  final List<Map<String, dynamic>> _dummyWeightHistory =
      UserDetailService.getDummyWeightHistory();
  final List<Map<String, dynamic>> _dummyCalorieData =
      UserDetailService.getDummyCalorieData();

  @override
  void initState() {
    super.initState();
    context.read<UserDetailBloc>().add(LoadUserDetail());
  }

  Future<void> _refreshData() async {
    context.read<UserDetailBloc>().add(LoadUserDetail());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screen.withOpacity(0.98),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          backgroundColor: AppColors.screen,
          strokeWidth: 3,
          displacement: 60,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          SvgPicture.asset("assets/icons/logo.svg", height: 35),
                      onPressed: () {},
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/calender.svg",
                              height: 24),
                          onPressed: () => showKalenderDialog(context),
                        ),
                        const SizedBox(width: 11),
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/notif.svg",
                              height: 24),
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
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/analytics.svg"),
                    const SizedBox(width: 11),
                    const Text(
                      "Analytics",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 33),
                BlocConsumer<UserDetailBloc, UserDetailState>(
                  listener: (context, state) {
                    if (state is UserDetailError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error: ${state.message}'),
                            backgroundColor: Colors.red),
                      );
                    } else if (state is UserDetailUpdateSuccess) {
                      // <<< PERBAIKAN DI SINI: Hanya jika UserDetailUpdateSuccess >>>
                      // Tampilkan dialog sukses otomatis hanya setelah update berhasil
                      CustomAlertDialog.show(
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
                      // <<< PERBAIKAN DI SINI: Tangani juga UserDetailUpdateSuccess >>>
                      userDetail = state.userDetail;
                    }

                    if (state is UserDetailLoading ||
                        state is UserDetailInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (userDetail != null) {
                      // Sekarang cukup cek jika userDetail tidak null
                      double heightInMeter = userDetail.tinggiBadan / 100;
                      double bmi = userDetail.beratBadan /
                          (heightInMeter * heightInMeter);

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: BeratCard(
                                  label: "Berat Sekarang",
                                  icon: "assets/icons/weight_sekarang.svg",
                                  value: userDetail.beratBadan,
                                  onUpdate: (value) {
                                    // DEBUG: Tambahkan print untuk melacak event
                                    print(
                                        'DEBUG: Mengirim event UpdateUserDetail untuk berat_badan: $value');
                                    context.read<UserDetailBloc>().add(
                                          UpdateUserDetail(
                                              updates: {'berat_badan': value}),
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: BeratCard(
                                  label: "Tinggi Badan",
                                  icon: "assets/icons/weight_sekarang.svg",
                                  value: userDetail.tinggiBadan,
                                  onUpdate: (value) {
                                    // DEBUG: Tambahkan print untuk melacak event
                                    print(
                                        'DEBUG: Mengirim event UpdateUserDetail untuk tinggi_badan: $value');
                                    context.read<UserDetailBloc>().add(
                                          UpdateUserDetail(
                                              updates: {'tinggi_badan': value}),
                                        );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 33),
                          BmiCard(bmi: bmi),
                        ],
                      );
                    } else if (state is UserDetailError) {
                      return Center(
                          child: Text('Gagal memuat data: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 33),
                KaloriChartCard(data: _dummyCalorieData),
                const SizedBox(height: 33),
                CardBeratGrafik(data: _dummyWeightHistory),
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
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
