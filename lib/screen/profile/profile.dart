// lib/screen/profile/profile.dart
// ignore_for_file: deprecated_member_use, unused_field, unnecessary_null_comparison, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:vitacal_app/blocs/auth/auth_bloc.dart';
import 'package:vitacal_app/blocs/auth/auth_event.dart';

import 'package:vitacal_app/screen/profile/edit_profile_detail.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';
import 'package:vitacal_app/screen/home/kalender.dart';
import 'package:vitacal_app/screen/onboarding/splash_screen.dart';
import 'package:vitacal_app/screen/auth/forgot_password.dart';

import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/enums.dart';
import 'package:vitacal_app/models/profile_model.dart';
import 'package:vitacal_app/models/kalori_model.dart';
import 'package:vitacal_app/utils/dialog_helpers.dart';

// Blocs
import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/kalori/kalori_state.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_bloc.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_event.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // UX kecil saat update inline
  double? _pendingBerat;
  double? _pendingTinggi;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    try {
      initializeDateFormatting('id_ID', null);
    } catch (_) {}
    // muat profil saat masuk
    context.read<ProfileBloc>().add(const LoadProfileData());
  }

  Future<void> _refreshData() async {
    context.read<ProfileBloc>().add(const LoadProfileData());
    // segarkan yang bergantung
    context.read<UserDetailBloc>().add(LoadUserDetail());
    context.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
  }

  // Divider halus standar
  Widget get _softDivider =>
      const Divider(height: 1, color: Color(0x1A000000)); // 10% black

  // Kartu standar (border tipis + elevation ringan)
  Widget _sectionCard({required Widget child, EdgeInsets? padding}) {
    return Card(
      color: AppColors.screen,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(21),
        side: BorderSide(color: Colors.black.withOpacity(.06), width: 1),
      ),
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: child,
      ),
    );
  }

  // Bar kecil indikator “sedang update”
  Widget _updatingBar() {
    if (!_isUpdating) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: const LinearProgressIndicator(
          minHeight: 3,
          color: AppColors.primary,
          backgroundColor: Color(0x11007BFF),
        ),
      ),
    );
  }

  // Row info dengan trailing opsional
  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    final textStyle = TextStyle(
      color: valueColor ?? (isBold ? AppColors.darkGrey : Colors.grey),
      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: textStyle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: 8),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
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
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                CustomAlertDialog.show(
                  context: context,
                  title: "Terjadi Kesalahan",
                  message: state.message,
                  type: DialogType.error,
                  showButton: false,
                  autoDismissDuration: const Duration(seconds: 3),
                );
              } else if (state is ProfileSuccess) {
                CustomAlertDialog.show(
                  context: context,
                  title: "Berhasil",
                  message: state.message,
                  type: DialogType.success,
                  showButton: false,
                  autoDismissDuration: const Duration(seconds: 2),
                );

                // kalau hapus/keluar, arahkan ke splash
                if (state.message.contains('dihapus') ||
                    state.message.contains('keluar')) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (Route<dynamic> route) => false,
                    );
                  });
                }

                // sinkronkan halaman lain
                context.read<UserDetailBloc>().add(LoadUserDetail());
                context.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));

                setState(() {
                  _isUpdating = false;
                  _pendingBerat = null;
                  _pendingTinggi = null;
                });
              } else if (state is ProfileNoChange) {
                CustomAlertDialog.show(
                  context: context,
                  title: "Informasi",
                  message: state.message,
                  type: DialogType.warning,
                  showButton: false,
                  autoDismissDuration: const Duration(seconds: 2),
                );
                setState(() {
                  _isUpdating = false;
                  _pendingBerat = null;
                  _pendingTinggi = null;
                });
              }
            },
            builder: (context, state) {
              ProfileModel? profileData;

              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                profileData = state.profileData;
              } else if (state is ProfileError ||
                  state is ProfileSuccess ||
                  state is ProfileNoChange) {
                profileData = context.read<ProfileBloc>().currentProfileData;
              }

              if (profileData == null || profileData.userDetail == null) {
                return const Center(
                    child: Text('Tidak ada data profil untuk ditampilkan.'));
              }

              final userDetail = profileData.userDetail!;
              final String formattedUmur = "${userDetail.umur ?? 0} Tahun";
              final bool verified = profileData.verified;
              final String statusAkun =
                  verified ? "Terverifikasi" : "Belum Diverifikasi";
              final Color statusAkunColor =
                  verified ? AppColors.primary : Colors.red;

              // format tanggal akun dibuat
              String tanggalAkunDibuat = 'Tidak tersedia';
              try {
                if (profileData.userCreatedAt != null) {
                  tanggalAkunDibuat = DateFormat('d MMMM y', 'id_ID')
                      .format(profileData.userCreatedAt);
                }
              } catch (_) {}

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: SvgPicture.asset("assets/icons/logo.svg",
                              height: 35),
                          onPressed: () {},
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                  "assets/icons/calender.svg",
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
                                      builder: (_) => const Notifikasi()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // KARTU: Profil & Info Akun
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileDetailPage(
                                    initialNama: userDetail.nama,
                                    initialUmur: userDetail.umur ?? 0,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      userDetail.profileImageBytes != null
                                          ? MemoryImage(
                                              userDetail.profileImageBytes!)
                                          : const AssetImage(
                                                  'assets/images/user.png')
                                              as ImageProvider,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              userDetail.nama,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                                color: AppColors.darkGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(profileData.username,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text(formattedUmur,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _softDivider,
                          const SizedBox(height: 20),
                          _buildInfoRow('Email', profileData.email,
                              isBold: true),
                          const SizedBox(height: 11),
                          _buildInfoRow('Nomor', profileData.phone,
                              isBold: true),
                          const SizedBox(height: 11),
                          _buildInfoRow(
                            'Status Akun',
                            '', // nilai dikosongkan, badge di trailing
                            trailingWidget: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (profileData.verified
                                    ? AppColors.primary.withOpacity(.08)
                                    : Colors.red.withOpacity(.08)),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: (profileData.verified
                                      ? AppColors.primary.withOpacity(.15)
                                      : Colors.red.withOpacity(.15)),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    profileData.verified
                                        ? Icons.verified_rounded
                                        : Icons.error_outline_rounded,
                                    size: 14,
                                    color: profileData.verified
                                        ? AppColors.primary
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    profileData.verified
                                        ? 'Terverifikasi'
                                        : 'Belum Diverifikasi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: profileData.verified
                                          ? AppColors.primary
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 11),
                          _buildInfoRow(
                              'Tanggal Akun Dibuat', tanggalAkunDibuat,
                              isBold: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Detail Pribadi & Target",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 12),

                    // KARTU: Detail & Target
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            'Berat Badan',
                            '${(_pendingBerat ?? userDetail.beratBadan)?.toStringAsFixed(1) ?? 'N/A'} Kg',
                            isBold: true,
                            trailingWidget: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () {
                              showUpdateValueDialog(
                                context: context,
                                title: 'Ubah Berat Badan',
                                initialValue: userDetail.beratBadan ?? 0.0,
                                minValue: 30.0,
                                maxValue: 200.0,
                                unit: 'Kg',
                                onSave: (value) {
                                  setState(() {
                                    _pendingBerat = value;
                                    _isUpdating = true;
                                  });
                                  context
                                      .read<ProfileBloc>()
                                      .add(UpdateBeratBadan(value));
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 11),
                          _softDivider,
                          const SizedBox(height: 11),
                          _buildInfoRow(
                            'Tinggi Badan',
                            '${(_pendingTinggi ?? userDetail.tinggiBadan)?.toStringAsFixed(1) ?? 'N/A'} cm',
                            isBold: true,
                            trailingWidget: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () {
                              showUpdateValueDialog(
                                context: context,
                                title: 'Ubah Tinggi Badan',
                                initialValue: userDetail.tinggiBadan ?? 0.0,
                                minValue: 100.0,
                                maxValue: 250.0,
                                unit: 'cm',
                                onSave: (value) {
                                  setState(() {
                                    _pendingTinggi = value;
                                    _isUpdating = true;
                                  });
                                  context
                                      .read<ProfileBloc>()
                                      .add(UpdateTinggiBadan(value));
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 11),
                          _softDivider,
                          const SizedBox(height: 11),
                          _buildInfoRow(
                            'Jenis Kelamin',
                            userDetail.jenisKelamin.toDisplayString(),
                            isBold: true,
                            trailingWidget: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () async {
                              final JenisKelamin? newValue =
                                  await showUpdateEnumDialog<JenisKelamin>(
                                context: context,
                                title: 'Ubah Jenis Kelamin',
                                initialValue: userDetail.jenisKelamin,
                                values: JenisKelamin.values,
                                displayString: (jk) => jk.toDisplayString(),
                              );
                              if (newValue != null) {
                                setState(() => _isUpdating = true);
                                context
                                    .read<ProfileBloc>()
                                    .add(UpdateJenisKelamin(newValue));
                              }
                            },
                          ),
                          const SizedBox(height: 11),
                          _softDivider,
                          const SizedBox(height: 11),
                          _buildInfoRow(
                            'Aktivitas',
                            userDetail.aktivitas.toDisplayString(),
                            isBold: true,
                            trailingWidget: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () async {
                              final Aktivitas? newValue =
                                  await showUpdateEnumDialog<Aktivitas>(
                                context: context,
                                title: 'Ubah Tingkat Aktivitas',
                                initialValue: userDetail.aktivitas,
                                values: Aktivitas.values,
                                displayString: (a) => a.toDisplayString(),
                              );
                              if (newValue != null) {
                                setState(() => _isUpdating = true);
                                context
                                    .read<ProfileBloc>()
                                    .add(UpdateAktivitas(newValue));
                              }
                            },
                          ),
                          const SizedBox(height: 11),
                          _softDivider,
                          const SizedBox(height: 11),
                          // Tujuan (KaloriBloc → fallback userDetail)
                          BlocBuilder<KaloriBloc, KaloriState>(
                            builder: (context, kaloriState) {
                              KaloriModel? kaloriData;
                              if (kaloriState is KaloriLoaded) {
                                kaloriData = kaloriState.kaloriModel;
                              }
                              final tujuanTxt = kaloriData
                                      ?.tujuanRekomendasiSistem
                                      ?.toDisplayString() ??
                                  userDetail.tujuan?.toDisplayString() ??
                                  'Tidak ditetapkan';
                              return _buildInfoRow('Tujuan', tujuanTxt,
                                  isBold: true);
                            },
                          ),
                          if (userDetail.targetBeratBadan != null) ...[
                            const SizedBox(height: 11),
                            _softDivider,
                            const SizedBox(height: 11),
                            _buildInfoRow(
                              'Target Berat Badan',
                              '${userDetail.targetBeratBadan?.toStringAsFixed(1) ?? 'N/A'} Kg',
                              isBold: true,
                              trailingWidget: const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                              onTap: () {},
                            ),
                          ],
                          _updatingBar(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Analisis Kesehatan",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 12),

                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (profileData.bmiData != null) ...[
                            _buildInfoRow(
                                'Status BMI', profileData.bmiData!.status,
                                isBold: true),
                            const SizedBox(height: 11),
                            _softDivider,
                            const SizedBox(height: 11),
                            _buildInfoRow(
                                'Nilai BMI',
                                profileData.bmiData!.bmiValue
                                    .toStringAsFixed(2),
                                isBold: true),
                            const SizedBox(height: 11),
                            _softDivider,
                            const SizedBox(height: 11),
                          ],
                          if (profileData.rekomendasiKaloriData != null) ...[
                            _buildInfoRow(
                              'Kalori Harian',
                              '${profileData.rekomendasiKaloriData!.rekomendasiKaloriHarian?.round() ?? 0} Kkal',
                              isBold: true,
                            ),
                            const SizedBox(height: 11),
                            _softDivider,
                            const SizedBox(height: 11),
                            _buildInfoRow(
                              'BMR',
                              (profileData.rekomendasiKaloriData!.bmr
                                          ?.toInt() ??
                                      'N/A')
                                  .toString(),
                              isBold: true,
                            ),
                            const SizedBox(height: 11),
                            _softDivider,
                            const SizedBox(height: 11),
                            _buildInfoRow(
                              'TDEE',
                              (profileData.rekomendasiKaloriData!.tdee
                                          ?.toInt() ??
                                      'N/A')
                                  .toString(),
                              isBold: true,
                            ),
                          ],
                          if (profileData.bmiData == null &&
                              profileData.rekomendasiKaloriData == null)
                            const Center(
                              child: Text(
                                'Data analisis kesehatan tidak tersedia.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Tentang Aplikasi",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 12),

                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('VitaCal Versi', 'v1.0.0',
                              isBold: true),
                          const SizedBox(height: 11),
                          _softDivider,
                          const SizedBox(height: 11),
                          _buildInfoRow(
                            'Profil Pembuat',
                            '',
                            trailingWidget: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () {},
                          ),
                          const SizedBox(height: 11),
                          _softDivider,
                          const SizedBox(height: 11),
                          _buildInfoRow(
                            'Laporkan Bug',
                            '',
                            trailingWidget: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () {},
                          ),
                          const SizedBox(height: 11),
                          _softDivider,
                          const SizedBox(height: 11),
                          _buildInfoRow(
                            'Beri Penilaian',
                            '',
                            trailingWidget: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Privasi dan Keamanan",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 12),

                    _sectionCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Column(
                        children: [
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/ubah_pw.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                  Color(0XFF007BFF), BlendMode.srcIn),
                            ),
                            title: const Text(
                              'Ganti Kata Sandi',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey),
                            ),
                            onTap: () {
                              CustomAlertDialog.show(
                                context: context,
                                title: "Ganti Kata Sandi",
                                message:
                                    "Anda akan diarahkan ke halaman untuk mengubah kata sandi Anda. Lanjutkan?",
                                type: DialogType.warning,
                                buttonText: "Lanjutkan",
                                onButtonPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ForgotPassword()),
                                  );
                                },
                                showButton: true,
                                secondaryButtonText: "Batal",
                                onSecondaryButtonPressed: () {},
                              );
                            },
                          ),
                          _softDivider,
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/keluar.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                  Color(0XFFFFA500), BlendMode.srcIn),
                            ),
                            title: const Text(
                              'Keluar',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey),
                            ),
                            onTap: () {
                              CustomAlertDialog.show(
                                context: context,
                                title: "Konfirmasi Keluar",
                                message:
                                    "Apakah Anda yakin ingin keluar dari akun Anda?",
                                type: DialogType.warning,
                                buttonText: "Keluar",
                                onButtonPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(LogoutUserEvent());
                                },
                                secondaryButtonText: "Batal",
                                onSecondaryButtonPressed: () {},
                              );
                            },
                          ),
                          _softDivider,
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/delete_akun.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                  Color(0XFFFF0000), BlendMode.srcIn),
                            ),
                            title: const Text(
                              'Hapus Akun',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0XFFFF0000),
                              ),
                            ),
                            onTap: () {
                              CustomAlertDialog.show(
                                context: context,
                                title: "Konfirmasi Hapus Akun",
                                message:
                                    "Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat dibatalkan.",
                                type: DialogType.error,
                                buttonText: "Hapus Akun",
                                onButtonPressed: () {
                                  context
                                      .read<ProfileBloc>()
                                      .add(const DeleteProfile());
                                },
                                showButton: true,
                                secondaryButtonText: "Batal",
                                onSecondaryButtonPressed: () {},
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 42),
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            "Dengan melanjutkan, Anda menyetujui",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.darkGrey),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Syarat & Ketentuan serta Kebijakan Privasi",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
