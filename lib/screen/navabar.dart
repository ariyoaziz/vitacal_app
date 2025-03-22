import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/themes/colors.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 70, // Meningkatkan tinggi navbar
            decoration: const BoxDecoration(
              color: AppColors.screen,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 0.5,
                  spreadRadius: 0.5,
                )
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: AppColors.screen, // Ganti warna yang diinginkan
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/home.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 0 ? AppColors.primary : Colors.grey,
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
                      _selectedIndex == 1 ? AppColors.primary : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Search',
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox.shrink(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/analytics.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 3 ? Colors.green : Colors.grey,
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
                      _selectedIndex == 4 ? AppColors.primary : Colors.grey,
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
          bottom: 25, // Diturunkan lagi biar makin proporsional
          left: MediaQuery.of(context).size.width / 2 - 32,
          child: GestureDetector(
            onTap: () {
              _onItemTapped(2);
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/add.svg',
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(
                    AppColors.screen,
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
