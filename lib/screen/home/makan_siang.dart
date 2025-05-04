import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';

class MakanSiang extends StatefulWidget {
  const MakanSiang({super.key});

  @override
  State<MakanSiang> createState() => _MakanSiangState();
}

class _MakanSiangState extends State<MakanSiang> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.greenGradient),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Tombol back di kiri
                Positioned(
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                // Judul di tengah
                const Center(
                  child: Text(
                    'Makan Siang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('Makan Siang Page'),
      ),
    );
  }
}
