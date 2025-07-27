// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/analytics/analytics.dart';
import 'package:vitacal_app/screen/camera/camera.dart';
import 'package:vitacal_app/screen/home/home.dart';
import 'package:vitacal_app/screen/profile/profile.dart';
import 'package:vitacal_app/screen/search/search.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/screen/widgets/navabar.dart';

import 'package:vitacal_app/main.dart' as app_main;

class MainPage extends StatefulWidget {
  final bool showSuccessDialog;
  const MainPage({super.key, this.showSuccessDialog = false});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Inisialisasi _pages di initState
    // Perhatikan bagaimana Camera widget sekarang menerima parameter isSelected
    _pages = [
      const Home(),
      const Search(),
      // >>> Perubahan Penting di Sini <<<
      // Camera widget kini menerima parameter `isSelected`
      // yang akan true jika _selectedIndex adalah 2 (indeks tab kamera)
      Camera(
        cameras: app_main.cameras,
        isSelected: false, // Default awal, akan diupdate di build
      ),
      const Analytics(),
      const Profile()
    ];

    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomAlertDialog.show(
          context: context,
          title: 'Login Berhasil!',
          message: 'Selamat datang kembali di VitaCal!',
          type: DialogType.success,
          showButton: false,
          autoDismissDuration: const Duration(seconds: 2),
          onButtonPressed: () {
            print("Dialog login berhasil ditutup.");
          },
        );
        print("DEBUG MAINPAGE: Dialog sukses login dipicu.");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // >>> Perubahan Penting di Sini <<<
    // Kita perlu membangun ulang list _pages dengan isSelected yang benar
    // setiap kali _selectedIndex berubah.
    final updatedPages = [
      const Home(),
      const Search(),
      Camera(
        cameras: app_main.cameras,
        isSelected: _selectedIndex == 2, // isSelected true jika ini tab kamera
      ),
      const Analytics(),
      const Profile()
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: updatedPages, // Gunakan updatedPages di sini
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
