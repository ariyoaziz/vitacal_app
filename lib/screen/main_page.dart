// lib/screen/main_page.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vitacal_app/screen/analytics/analytics.dart';
import 'package:vitacal_app/screen/camera/camera.dart';
import 'package:vitacal_app/screen/home/home.dart';
import 'package:vitacal_app/screen/profile/profile.dart';
import 'package:vitacal_app/screen/search/search.dart';
import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/screen/widgets/navabar.dart';

import 'package:vitacal_app/main.dart' as app_main;

// Bloc untuk sinkronisasi lintas-halaman
import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';

import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_state.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';

import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_bloc.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_event.dart';

class MainPage extends StatefulWidget {
  final bool showSuccessDialog;
  const MainPage({super.key, this.showSuccessDialog = false});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _refreshGlobal() {
    // Muat ulang detail & riwayat untuk menyegarkan semua halaman yang pakai bloc ini
    context.read<UserDetailBloc>().add(LoadUserDetail());
    context.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Setiap masuk tab Analytics, pastikan data terbaru
    if (index == 3) {
      _refreshGlobal();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomAlertDialog.show(
          context: context,
          title: 'Login Berhasil!',
          message: 'Selamat datang kembali di VitaCal!',
          type: DialogType.success,
          showButton: false,
          autoDismissDuration: const Duration(seconds: 2),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Home(),
      const Search(),
      Camera(
        cameras: app_main.cameras,
        isSelected: _selectedIndex == 2,
      ),
      const Analytics(),
      const Profile(),
    ];

    return MultiBlocListener(
      listeners: [
        // Jika profil berubah (berhasil update/muat), segarkan data global
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              curr is ProfileLoaded ||
              curr is ProfileSuccess ||
              curr is ProfileNoChange,
          listener: (context, state) {
            _refreshGlobal();
          },
        ),

        // Jika user detail sukses diupdate, segarkan riwayat (kalori/berat)
        BlocListener<UserDetailBloc, UserDetailState>(
          listenWhen: (prev, curr) => curr is UserDetailUpdateSuccess,
          listener: (context, state) {
            context.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: pages,
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
      ),
    );
  }
}
