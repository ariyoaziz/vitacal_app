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

// UserDetail BLoC
import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_state.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';

// Riwayat (kalori & grafik berat)
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_bloc.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_event.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_state.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  double? _pendingBerat;
  double? _pendingTinggi;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // NOTE:
    // Load awal sudah dipicu dari main.dart.
    // Kalau kamu ingin tetap aman, kamu bisa biarkan baris di bawah ini,
    // tapi berpotensi dobel fetch. Maka kita tidak panggil lagi di sini.
    //
    // context.read<UserDetailBloc>().add(LoadUserDetail());
    // context.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
  }

  Future<void> _refreshData() async {
    context.read<UserDetailBloc>().add(LoadUserDetail());
    context.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
    await Future.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24.0;

    return Scaffold(
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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

                // Title
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/analytics.svg", height: 28),
                    const SizedBox(width: 11),
                    const Text(
                      "Analytics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 33),

                // User Detail (Berat/Tinggi & BMI)
                BlocConsumer<UserDetailBloc, UserDetailState>(
                  listener: (context, state) {
                    if (state is UserDetailError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${state.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() {
                        _isUpdating = false;
                        _pendingBerat = null;
                        _pendingTinggi = null;
                      });
                    } else if (state is UserDetailUpdateSuccess) {
                      CustomAlertDialog.show(
                        context: context,
                        title: "Pembaruan Berhasil!",
                        message: "Data profil Anda telah berhasil diperbarui.",
                        type: DialogType.success,
                        showButton: false,
                        autoDismissDuration: const Duration(seconds: 2),
                      );
                      setState(() {
                        _isUpdating = false;
                        _pendingBerat = null;
                        _pendingTinggi = null;
                      });

                      // Opsional: kalau belum diset di main.dart, kita bisa trigger riwayat dari sini juga
                      context
                          .read<RiwayatUserBloc>()
                          .add(const LoadRiwayat(days: 7));
                    }
                  },
                  builder: (context, state) {
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
                    }
                    if (userDetail == null) {
                      return const Center(
                        child: Text(
                            'Tidak ada data detail pengguna untuk ditampilkan.'),
                      );
                    }

                    final beratDisplay =
                        _pendingBerat ?? (userDetail.beratBadan ?? 0.0);
                    final tinggiDisplay =
                        _pendingTinggi ?? (userDetail.tinggiBadan ?? 0.0);

                    final hMeter = tinggiDisplay / 100.0;
                    final bmi = (beratDisplay > 0 && hMeter > 0)
                        ? double.parse((beratDisplay / (hMeter * hMeter))
                            .toStringAsFixed(2))
                        : 0.0;

                    return Stack(
                      children: [
                        Column(
                          children: [
                            // Kartu input Berat & Tinggi
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: BeratCard(
                                    label: "Berat Sekarang",
                                    icon: "assets/icons/weight_sekarang.svg",
                                    value: beratDisplay,
                                    onUpdate: (value) {
                                      setState(() {
                                        _pendingBerat = value;
                                        _isUpdating = true;
                                      });
                                      context.read<UserDetailBloc>().add(
                                          UpdateUserDetail(
                                              updates: {'berat_badan': value}));
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: BeratCard(
                                    label: "Tinggi Badan",
                                    icon: "assets/icons/weight_sekarang.svg",
                                    value: tinggiDisplay,
                                    onUpdate: (value) {
                                      setState(() {
                                        _pendingTinggi = value;
                                        _isUpdating = true;
                                      });
                                      context.read<UserDetailBloc>().add(
                                              UpdateUserDetail(updates: {
                                            'tinggi_badan': value
                                          }));
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // BMI
                            BmiCard(bmi: bmi),
                            const SizedBox(height: 24),

                            // Kalori Harian (Riwayat)
                            BlocBuilder<RiwayatUserBloc, RiwayatUserState>(
                              builder: (context, rState) {
                                if (rState is RiwayatUserLoading ||
                                    rState is RiwayatUserInitial) {
                                  return _loadingCard(title: 'Kalori Harian');
                                } else if (rState is RiwayatUserLoaded) {
                                  return KaloriChartCard(
                                    data: rState.calorieHistory,
                                    onViewDetail: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Fitur Lihat Detail coming soon')),
                                      );
                                    },
                                  );
                                } else if (rState is RiwayatUserError) {
                                  return _errorCard(
                                    title: 'Kalori Harian',
                                    message:
                                        'Gagal memuat data kalori: ${rState.message}',
                                    onRetry: () => context
                                        .read<RiwayatUserBloc>()
                                        .add(const LoadRiwayat(days: 7)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 24),

                            // Grafik Berat (riwayat 7 entri terbaru yang ada)
                            BlocBuilder<RiwayatUserBloc, RiwayatUserState>(
                              builder: (context, rState) {
                                if (rState is RiwayatUserLoading ||
                                    rState is RiwayatUserInitial) {
                                  return _loadingCard(
                                      title: 'Grafik Berat Badan');
                                } else if (rState is RiwayatUserLoaded) {
                                  return CardBeratGrafik(
                                    data: rState.weightHistory,
                                    onViewDetail: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Fitur Lihat Detail coming soon')),
                                      );
                                    },
                                  );
                                } else if (rState is RiwayatUserError) {
                                  return _errorCard(
                                    title: 'Grafik Berat Badan',
                                    message:
                                        'Gagal memuat riwayat berat badan: ${rState.message}',
                                    onRetry: () => context
                                        .read<RiwayatUserBloc>()
                                        .add(const LoadRiwayat(days: 7)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                        if (_isUpdating)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.08),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 50),

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: const Text(
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

  // ===== Helper UI kecil =====

  Widget _loadingCard({required String title}) {
    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _errorCard({
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Card(
      color: AppColors.screen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
