import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/analytics/analytics.dart';
import 'package:vitacal_app/screen/camera/camera.dart';
import 'package:vitacal_app/screen/home/home.dart';
import 'package:vitacal_app/screen/profile/profile.dart';
import 'package:vitacal_app/screen/search/search.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/screen/widgets/navabar.dart'; // Pastikan path ini benar
// Hapus import yang tidak terpakai:
// import 'package:vitacal_app/screen/widgets/dialog.dart'; // Ini mungkin file lama Anda

class MainPage extends StatefulWidget {
  final bool
      showSuccessDialog; // Parameter opsional untuk menampilkan dialog sukses
  const MainPage({super.key, this.showSuccessDialog = false});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Home(),
    Search(),
    Camera(),
    Analytics(),
    Profile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false, // Tidak bisa ditutup sembarangan
          builder: (BuildContext dialogContext) {
            return CustomAlertDialog(
              title: 'Login Berhasil!',
              message: 'Selamat datang kembali di VitaCal!',
              type: DialogType.success,
              showButton: false, // Tampilkan tombol
              autoDismissDuration: const Duration(seconds: 2),
              onButtonPressed: () {
                // Opsional: Lakukan sesuatu setelah dialog ditutup
                print("Dialog login berhasil ditutup.");
              },
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // <--- Tambahkan Scaffold di sini
      body: Stack(
        children: [
          // Konten halaman yang sedang aktif
          _pages[_selectedIndex],
          // Bottom Navigation Bar
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
