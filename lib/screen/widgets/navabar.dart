// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Menghitung lebar layar untuk penempatan FAB
    final double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior:
          Clip.none, // Penting agar Floating Action Button bisa menonjol keluar
      children: [
        // Latar Belakang Bottom Navigation Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 75, // Tinggi sedikit diperbesar untuk estetika
            decoration: BoxDecoration(
              color: AppColors.screen, // Warna latar belakang konsisten
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.08), // Bayangan lebih halus dan modern
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 0), // Tidak ada offset vertikal
                ),
              ],
              // Jika ingin sedikit radius di sudut atas:
              // borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors
                  .transparent, // Transparan agar warna container terlihat
              elevation: 0, // Tanpa elevation default dari BottomNavigationBar
              currentIndex: selectedIndex,
              onTap: onItemTapped,
              type: BottomNavigationBarType
                  .fixed, // Memastikan semua item terlihat
              selectedItemColor: AppColors.primary, // Warna item terpilih
              unselectedItemColor:
                  AppColors.mediumGrey, // Warna item tidak terpilih (konsisten)
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600, // Label terpilih lebih tebal
                fontSize: 12, // Ukuran font label
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight
                    .w500, // Label tidak terpilih sedikit lebih tebal dari normal
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/home.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 0
                          ? AppColors.primary
                          : AppColors.mediumGrey, // Warna ikon konsisten
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/search.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 1
                          ? AppColors.primary
                          : AppColors.mediumGrey, // Warna ikon konsisten
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Search',
                ),
                // Item placeholder untuk Floating Action Button
                const BottomNavigationBarItem(
                  icon: SizedBox.shrink(), // Icon kosong
                  label: '', // Label kosong
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/analytics.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 3
                          ? AppColors.primary
                          : AppColors.mediumGrey, // Warna ikon konsisten
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/profile.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 4
                          ? AppColors.primary
                          : AppColors.mediumGrey, // Warna ikon konsisten
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),

        // Floating Add Button (Tombol Tengah)
        Positioned(
          bottom: 25, // Sedikit lebih tinggi dari sebelumnya
          left: screenWidth / 2 - 32, // Pusat di tengah layar
          child: GestureDetector(
            onTap: () {
              onItemTapped(2); // Memilih indeks 2 (item tengah)
            },
            child: Container(
              width: 64, // Ukuran tombol
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary, // Warna primer
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                        0.4), // Bayangan lebih kuat dari warna primer
                    blurRadius: 15, // Blur lebih besar
                    spreadRadius: 3, // Spread lebih besar
                    offset: const Offset(0, 5), // Offset ke bawah
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/add.svg',
                  width: 32, // Ukuran ikon diperbesar sedikit
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white, // Warna ikon putih murni
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
