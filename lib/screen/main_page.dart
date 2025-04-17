import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/analytics/analytics.dart';
import 'package:vitacal_app/screen/camera/camera.dart';
import 'package:vitacal_app/screen/home/home.dart';
import 'package:vitacal_app/screen/profile/profile.dart';
import 'package:vitacal_app/screen/search/search.dart';
import 'package:vitacal_app/screen/widget/navabar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
