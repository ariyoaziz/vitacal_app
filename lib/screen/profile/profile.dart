import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';
import 'package:vitacal_app/screen/home/kalender.dart';

import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';
import 'package:vitacal_app/models/enums.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileData());
  }

  Future<void> _refreshData() async {
    context.read<ProfileBloc>().add(LoadProfileData());
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
  }

  // Helper function untuk menampilkan baris informasi profil
  Widget _buildInfoRow(String label, String value,
      {bool isBold = false,
      Color? valueColor,
      Widget? trailingWidget,
      VoidCallback? onTap}) {
    return InkWell(
      // Menggunakan InkWell untuk efek ripple saat diklik
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black87),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: valueColor ??
                        (isBold ? AppColors.darkGrey : Colors.grey),
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (trailingWidget != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: trailingWidget,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24.0;
    // const Icon arrowRightIcon = Icon(Icons.chevron_right, color: Colors.grey); // Ikon panah tetap didefinisikan

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                final profileData = state.profileData;
                final String formattedUmur = "${profileData.umur} Tahun";
                final String statusAkun = profileData.verified
                    ? "Terverifikasi"
                    : "Belum Diverifikasi";
                final Color statusAkunColor =
                    profileData.verified ? AppColors.primary : Colors.red;

                String tanggalAkunDibuat = 'Tidak tersedia';
                try {
                  DateTime createdAt =
                      DateTime.parse(profileData.userCreatedAt);
                  // Perbaiki format tanggal untuk bahasa Indonesia
                  tanggalAkunDibuat =
                      DateFormat('d MMMM yyyy', 'id_ID').format(createdAt);
                } catch (e) {
                  print('Error parsing userCreatedAt: $e');
                }

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header dengan ikon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset("assets/icons/logo.svg",
                                height: 35),
                            onPressed: () {/* No action for logo */},
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
                                        builder: (context) =>
                                            const Notifikasi()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 33),
                      // --- KARTU 1: Profil Utama & Info Akun ---
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 1,
                        color: AppColors.screen,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Aksi ubah foto profil
                                      print('Ubah Foto Profil diklik');
                                    },
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundImage: profileData
                                                  .profileImageBytes !=
                                              null
                                          ? MemoryImage(
                                              profileData.profileImageBytes!)
                                          : const AssetImage(
                                                  'assets/images/user.png')
                                              as ImageProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        // TODO: Aksi ubah nama/umur (navigasi ke edit profil)
                                        print('Ubah Nama/Umur diklik');
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profileData.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              color: AppColors.darkGrey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedUmur,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 33),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 33),
                              // Detail Akun
                              _buildInfoRow('Email', profileData.email,
                                  isBold: true),
                              const SizedBox(height: 11),
                              _buildInfoRow('Nomor', profileData.phone,
                                  isBold: true),
                              const SizedBox(height: 11),
                              _buildInfoRow('Status Akun', statusAkun,
                                  isBold: true, valueColor: statusAkunColor),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                  'Tanggal Akun Dibuat', tanggalAkunDibuat,
                                  isBold: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 33),

                      // --- Judul Kartu 2: Detail Pribadi & Target ---
                      const Text(
                        "Detail Pribadi & Target",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- KARTU 2: Detail Pribadi & Target ---
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 1,
                        color: AppColors.screen,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Berat Badan',
                                '${profileData.beratBadan.toStringAsFixed(1)} Kg',
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors
                                        .grey), // Menggunakan const untuk ikon
                                onTap: () {
                                  print('Ubah Berat Badan diklik');
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Tinggi Badan',
                                '${profileData.tinggiBadan.toStringAsFixed(1)} cm',
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () {
                                  print('Ubah Tinggi Badan diklik');
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Jenis Kelamin',
                                profileData.jenisKelamin.toDisplayString(),
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () {
                                  print('Ubah Jenis Kelamin diklik');
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Aktivitas',
                                profileData.aktivitas.toDisplayString(),
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () {
                                  print('Ubah Aktivitas diklik');
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Tujuan',
                                profileData.tujuan?.toDisplayString() ??
                                    'Tidak ditetapkan',
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () {
                                  print('Ubah Tujuan diklik');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 33),

                      // --- Judul Kartu 3: Analisis Kesehatan ---
                      const Text(
                        "Analisis Kesehatan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- KARTU 3: Analisis Kesehatan (BMI & Rekomendasi Kalori) ---
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 1,
                        color: AppColors.screen,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (profileData.bmiData != null) ...[
                                _buildInfoRow(
                                    'Status BMI', profileData.bmiData!.status,
                                    isBold: true),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                                _buildInfoRow(
                                    'Nilai BMI',
                                    profileData.bmiData!.bmiValue
                                        .toStringAsFixed(2),
                                    isBold: true),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                              ],
                              if (profileData.rekomendasiKalori != null) ...[
                                _buildInfoRow('Kalori Harian',
                                    '${profileData.rekomendasiKalori!.numericRekomendasiKalori.toInt()} Kkal',
                                    isBold: true),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                                _buildInfoRow(
                                    'BMR',
                                    profileData.rekomendasiKalori!.bmr
                                        .toInt()
                                        .toString(),
                                    isBold: true),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                                _buildInfoRow(
                                    'TDEE',
                                    profileData.rekomendasiKalori!.tdee
                                        .toInt()
                                        .toString(),
                                    isBold: true),
                              ],
                              if (profileData.bmiData == null &&
                                  profileData.rekomendasiKalori == null)
                                const Center(
                                  child: Text(
                                    'Data analisis kesehatan tidak tersedia.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 33),

                      // --- KARTU 4: Privasi dan Keamanan ---
                      const Text(
                        "Privasi dan Keamanan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 1,
                        color: AppColors.screen,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                // trailing: arrowRightIcon, // Dihapus
                                onTap: () {
                                  print('Ganti Kata Sandi diklik');
                                },
                              ),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
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
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                // trailing: arrowRightIcon, // Dihapus
                                onTap: () {
                                  print('Keluar diklik');
                                },
                              ),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
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
                                // trailing: arrowRightIcon, // Dihapus
                                onTap: () {
                                  print('Hapus Akun diklik');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Dengan melanjutkan, Anda menyetujui",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                print('Syarat dan Ketentuan diklik');
                              },
                              child: const Text(
                                "Syarat & Ketentuan serta Kebijakan Privasi",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              } else if (state is ProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat profil: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
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
              return const Center(
                child: Text('Tidak ada data profil untuk ditampilkan.'),
              );
            },
          ),
        ),
      ),
    );
  }
}
