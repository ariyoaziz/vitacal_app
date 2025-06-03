import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/analytics/analytics.dart';
import 'package:vitacal_app/screen/camera/camera.dart';
import 'package:vitacal_app/screen/home/home.dart';
import 'package:vitacal_app/screen/profile/profile.dart';
import 'package:vitacal_app/screen/search/search.dart';
import 'package:vitacal_app/screen/widgets/navabar.dart';
import 'package:vitacal_app/screen/widgets/dialog.dart';

class MainPage extends StatefulWidget {
  final bool showSuccessDialog; // Tambahkan parameter opsional
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
      Future.delayed(Duration.zero, () {
        CustomDialog.show(
          // ignore: use_build_context_synchronously
          context,
          title: 'Login Berhasil',
          message: 'Selamat datang kembali!',
          type: DialogType.success,
          autoDismiss: true,
          dismissDuration: Duration(seconds: 1),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _pages[_selectedIndex],
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ],
    );
  }
}
