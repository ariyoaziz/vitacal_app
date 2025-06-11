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

import 'package:vitacal_app/utils/dialog_helpers.dart'; // PENTING: Pastikan import ini benar

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileData());
  }

  Future<void> _refreshData() async {
    context.read<ProfileBloc>().add(const LoadProfileData());
  }

  // Helper function untuk menampilkan baris informasi profil
  Widget _buildInfoRow(String label, String value,
      {bool isBold = false,
      Color? valueColor,
      Widget? trailingWidget,
      VoidCallback? onTap}) {
    return InkWell(
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

                if (profileData.userDetail == null) {
                  return const Center(
                      child: Text('User detail data is missing.'));
                }

                final userDetail = profileData.userDetail!;

                final String formattedUmur = "${userDetail.umur} Tahun";
                final String statusAkun = profileData.verified
                    ? "Terverifikasi"
                    : "Belum Diverifikasi";
                final Color statusAkunColor =
                    profileData.verified ? AppColors.primary : Colors.red;

                String tanggalAkunDibuat = 'Tidak tersedia';
                try {
                  DateTime createdAt =
                      DateTime.parse(profileData.userCreatedAt);
                  tanggalAkunDibuat = DateFormat('d MMMM yyyy',
                          'id_ID') // FIX: Format tahun yang benar
                      .format(createdAt);
                } catch (e) {
                  print('Error parsing userCreatedAt: $e');
                }

                print('DEBUG PROFILE: ProfileModel Loaded: $profileData');
                print(
                    'DEBUG PROFILE: UserDetail Data: ${profileData.userDetail}');
                print('DEBUG PROFILE: BMI Data: ${profileData.bmiData}');
                print(
                    'DEBUG PROFILE: Profile Rekomendasi Kalori Data: ${profileData.profileRekomendasiKalori}');

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
                                      print('Ubah Foto Profil diklik');
                                    },
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundImage:
                                          userDetail.profileImageBytes != null
                                              ? MemoryImage(
                                                  userDetail.profileImageBytes!)
                                              : const AssetImage(
                                                      'assets/images/user.png')
                                                  as ImageProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        print('Ubah Nama/Umur diklik');
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userDetail.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              color: AppColors.darkGrey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            profileData.username,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
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
                                '${userDetail.beratBadan.toStringAsFixed(1)} Kg',
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () {
                                  // REMOVED await and newValue assignment
                                  showUpdateValueDialog(
                                    // Direct call
                                    context: context,
                                    title: 'Ubah Berat Badan',
                                    initialValue: userDetail.beratBadan,
                                    minValue: 30.0,
                                    maxValue: 200.0,
                                    unit: 'Kg',
                                    onSave: (value) {
                                      print('Berat Badan Disimpan: $value Kg');

                                      _refreshData();
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Tinggi Badan',
                                '${userDetail.tinggiBadan.toStringAsFixed(1)} cm',
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () {
                                  // REMOVED await and newValue assignment
                                  showUpdateValueDialog(
                                    // Direct call
                                    context: context,
                                    title: 'Ubah Tinggi Badan',
                                    initialValue: userDetail.tinggiBadan,
                                    minValue: 100.0,
                                    maxValue: 250.0,
                                    unit: 'cm',
                                    onSave: (value) {
                                      print('Tinggi Badan Disimpan: $value cm');

                                      _refreshData();
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Jenis Kelamin',
                                userDetail.jenisKelamin.toDisplayString(),
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () async {
                                  // Keep await here, as showUpdateEnumDialog returns a value
                                  final JenisKelamin? newValue =
                                      await showUpdateEnumDialog<JenisKelamin>(
                                    context: context,
                                    title: 'Ubah Jenis Kelamin',
                                    initialValue: userDetail.jenisKelamin,
                                    values: JenisKelamin.values,
                                    displayString: (jk) => jk.toDisplayString(),
                                  );
                                  if (newValue != null) {
                                    // Only refresh if a new value was actually selected
                                    print(
                                        'Jenis Kelamin baru dari dialog: ${newValue.toDisplayString()}');

                                    _refreshData();
                                  }
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Aktivitas',
                                userDetail.aktivitas.toDisplayString(),
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () async {
                                  // Keep await here
                                  final Aktivitas? newValue =
                                      await showUpdateEnumDialog<Aktivitas>(
                                    context: context,
                                    title: 'Ubah Tingkat Aktivitas',
                                    initialValue: userDetail.aktivitas,
                                    values: Aktivitas.values,
                                    displayString: (akt) =>
                                        akt.toDisplayString(),
                                  );
                                  if (newValue != null) {
                                    // Only refresh if a new value was actually selected
                                    print(
                                        'Aktivitas baru dari dialog: ${newValue.toDisplayString()}');

                                    _refreshData();
                                  }
                                },
                              ),
                              const SizedBox(height: 11),
                              const Divider(
                                  height: 1,
                                  color: Color.fromARGB(25, 0, 0, 0)),
                              const SizedBox(height: 11),
                              _buildInfoRow(
                                'Tujuan',
                                userDetail.tujuan?.toDisplayString() ??
                                    'Tidak ditetapkan',
                                isBold: true,
                                trailingWidget: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onTap: () async {
                                  // Keep await here
                                  final Tujuan? newValue =
                                      await showUpdateEnumDialog<Tujuan>(
                                    context: context,
                                    title: 'Ubah Tujuan',
                                    initialValue: userDetail.tujuan,
                                    values: Tujuan.values,
                                    displayString: (t) => t.toDisplayString(),
                                  );
                                  if (newValue != null) {
                                    // Only refresh if a new value was actually selected
                                    print(
                                        'Tujuan baru dari dialog: ${newValue.toDisplayString()}');

                                    _refreshData();
                                  }
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
                              // Mengakses BMI dari profileData.bmiData
                              if (profileData.bmiData != null) ...[
                                _buildInfoRow(
                                  'Status BMI',
                                  profileData.bmiData!.status,
                                  isBold: true,
                                ),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                                _buildInfoRow(
                                  'Nilai BMI',
                                  profileData.bmiData!.bmiValue
                                      .toStringAsFixed(2),
                                  isBold: true,
                                ),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                              ],
                              // Mengakses Rekomendasi Kalori dari profileData.profileRekomendasiKalori
                              if (profileData.profileRekomendasiKalori !=
                                  null) ...[
                                _buildInfoRow(
                                  'Kalori Harian',
                                  '${profileData.profileRekomendasiKalori!.numericRekomendasiKalori} Kkal',
                                  isBold: true,
                                ),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                                _buildInfoRow(
                                  'BMR',
                                  profileData.profileRekomendasiKalori!.bmr
                                      .toInt()
                                      .toString(),
                                  isBold: true,
                                ),
                                const SizedBox(height: 11),
                                const Divider(
                                    height: 1,
                                    color: Color.fromARGB(25, 0, 0, 0)),
                                const SizedBox(height: 11),
                                _buildInfoRow(
                                  'TDEE',
                                  profileData.profileRekomendasiKalori!.tdee
                                      .toInt()
                                      .toString(),
                                  isBold: true,
                                ),
                              ],
                              // Pesan jika tidak ada data analisis kesehatan
                              if (profileData.bmiData == null &&
                                  profileData.profileRekomendasiKalori == null)
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
