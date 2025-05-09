import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';
import 'package:vitacal_app/screen/home/kalender.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: AppColors.screen.withOpacity(0.98),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/logo.svg", height: 35),
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
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 1,
                color: AppColors.screen,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Foto profil bundar
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: AssetImage(
                                'assets/images/user.png'), // Ganti dengan foto profil
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Ariyo Aziz Pratama',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '17 Tahun',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 33),
                      const Divider(height: 1),
                      const SizedBox(height: 33),
                      _buildInfoRow('Email', 'ariyoaziz.pratama@gmail.com',
                          isBold: true),
                      const SizedBox(height: 11),
                      _buildInfoRow('Nomor', '+62 85878743545', isBold: true),
                      const SizedBox(height: 11),
                      _buildInfoRow('Status Akun', 'Verifikasi', isBold: true),
                      const SizedBox(height: 11),
                      _buildInfoRow('Tujuan', 'Meningkatkan berat badan',
                          isBold: true),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              const Text(
                " Detail Pribadi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: 21),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 1,
                color: AppColors.screen,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Berat Badan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '45 Kg',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tinggi Badan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '1600 cm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tanggal Ulang Tahun',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '12 Januari 2008',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Jenis Kelamin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Laki-laki',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Jenis Aktivitas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sedentari',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              const Text(
                " Sesuikan Target",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: 21),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 1,
                color: AppColors.screen,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Berat Badan
                      const Text(
                        'Berat Badan',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '45 Kg',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),

                      // Tinggi Badan
                      const Text(
                        'Kalori Harian',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '2.500 Kal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),

                      // Tanggal Ulang Tahun
                      const Text(
                        'Protein Harian',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '65 Gr',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),

                      // Jenis Kelamin
                      const Text(
                        'Karbohidrat Harian',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '70 Gr',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      const SizedBox(height: 11),

                      // Jenis Aktivitas
                      const Text(
                        'Lemak Harian',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '20 Gr',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Lihat Detail
                      GestureDetector(
                        onTap: () {
                          // Tambahkan navigasi atau fungsi lainnya di sini
                        },
                        child: Center(
                          child: Text(
                            'Lihat Detail',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              const Text(
                " Privasi dan Keamanan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: 21),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 1,
                color: AppColors.screen,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: SvgPicture.asset(
                          'assets/icons/ubah_pw.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
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
                          // Aksi ubah password
                        },
                      ),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      ListTile(
                        leading: SvgPicture.asset(
                          'assets/icons/keluar.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
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
                          // Aksi logout
                        },
                      ),
                      Divider(
                          height: 1,
                          // ignore: deprecated_member_use
                          color: AppColors.darkGrey.withOpacity(0.1)),
                      ListTile(
                        leading: SvgPicture.asset(
                          'assets/icons/delete_akun.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
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
                          // Aksi hapus akun
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 50),
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
                        // Aksi ketika teks syarat dan ketentuan ditekan
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
        ),
      ),
    );
  }
}

Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(color: Colors.black87),
      ),
      Text(
        value,
        style: TextStyle(
          color: value.toLowerCase() == 'verifikasi'
              ? AppColors.lightgreen
              : Colors.grey,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ],
  );
}
