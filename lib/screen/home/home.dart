// lib/screen/home/home.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import screen dan bloc terkait
import 'package:vitacal_app/screen/home/kalender.dart';
import 'package:vitacal_app/screen/home/lainnya.dart';
import 'package:vitacal_app/screen/home/makan_malam.dart';
import 'package:vitacal_app/screen/home/makan_pagi.dart';
import 'package:vitacal_app/screen/home/makan_siang.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';

// Import tema, models, dan blocs
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/kalori_model.dart'; // Menggunakan kalori_model.dart
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart'; // Menggunakan kalori_bloc.dart
import 'package:vitacal_app/blocs/kalori/kalori_event.dart'; // Menggunakan kalori_event.dart
import 'package:vitacal_app/blocs/kalori/kalori_state.dart'; // Menggunakan kalori_state.dart

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = -1; // Indeks untuk menandai hari yang dipilih
  // Mapping nama hari
  final Map<String, String> shortDays = {
    "Monday": "Sen",
    "Tuesday": "Sel",
    "Wednesday": "Rab",
    "Thursday": "Kam",
    "Friday": "Jum",
    "Saturday": "Sab",
    "Sunday": "Min",
  };

  late List<DateTime> weekDates; // Daftar tanggal dari Senin sampai Minggu

  KaloriModel?
      _currentKaloriModel; // Menyimpan data kalori yang sedang ditampilkan

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); // Inisialisasi lokal Indonesia

    // Cari Senin terdekat sebelum atau sama dengan hari ini
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    // Buat daftar 7 hari dari Senin ke Minggu
    weekDates =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    // Set `selectedIndex` agar sesuai dengan tanggal hari ini
    selectedIndex = weekDates.indexWhere((date) =>
        DateFormat("yyyy-MM-dd").format(date) ==
        DateFormat("yyyy-MM-dd").format(today));

    // Panggil event untuk mengambil data saat initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerFetchKaloriData(); // Hanya memicu fetch data
    });
  }

  // Fungsi untuk memicu pengambilan data kalori
  Future<void> _triggerFetchKaloriData() async {
    print(
        'Home: Memicu FetchKaloriData event. Mengasumsikan pengguna sudah login.');
    context.read<KaloriBloc>().add(const FetchKaloriData());
  }

  // Fungsi yang dipanggil saat pull-to-refresh
  Future<void> _refreshData() async {
    print('Home: Refreshing data by dispatching FetchKaloriData event...');
    context.read<KaloriBloc>().add(const FetchKaloriData());
    // Beri waktu sebentar agar BLoC sempat memproses dan emit state
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
  }

  // Helper function untuk mengonversi string snake_case ke Title Case untuk tampilan UI
  String _formatSnakeCaseToTitleCase(String snakeCaseString) {
    if (snakeCaseString.isEmpty) return '';
    return snakeCaseString
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  // Widget helper untuk membuat kartu makan
  Widget _buildMealCard(
      String title, IconData icon, Color iconColor, Widget destinationPage) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destinationPage));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 372,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.screen,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey)),
                    const SizedBox(height: 5),
                    Text(
                        "Total: 0 Kkal", // Tetap 0 Kkal karena data belum diintegrasikan
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkGrey.withOpacity(0.8))),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.darkGrey, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = 24.0;

    return Scaffold(
      backgroundColor: AppColors.screen.withOpacity(0.98),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          backgroundColor: AppColors.screen,
          strokeWidth: 3,
          displacement: 60,
          child: BlocConsumer<KaloriBloc, KaloriState>(
            listener: (context, state) {
              if (state is KaloriError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: Colors.red),
                );
              } else if (state is KaloriSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green),
                );
                setState(() {
                  _currentKaloriModel = null; // Set null jika data dihapus
                });
              } else if (state is KaloriLoaded) {
                setState(() {
                  _currentKaloriModel = state.kaloriModel;
                });
              }
            },
            builder: (context, state) {
              int kaloriSudahDikonsumsiHariIni = 0;
              int kaloriYangMasihBisaDikonsumsi = 0;
              int totalRekomendasiKalori = 0;

              double progressValue = 0.0;
              bool isLoading = false;
              List<TextSpan> displayMessageSpans = [];

              if (state is KaloriLoading) {
                isLoading = true;
                displayMessageSpans
                    .add(const TextSpan(text: "Memuat data kalori..."));
              } else if (state is KaloriLoaded) {
                // Pastikan _currentKaloriModel tidak null sebelum mengakses
                if (_currentKaloriModel != null) {
                  totalRekomendasiKalori =
                      _currentKaloriModel!.numericRekomendasiKalori;
                  kaloriYangMasihBisaDikonsumsi =
                      totalRekomendasiKalori - kaloriSudahDikonsumsiHariIni;
                  if (kaloriYangMasihBisaDikonsumsi < 0) {
                    kaloriYangMasihBisaDikonsumsi = 0;
                  }

                  progressValue = totalRekomendasiKalori > 0
                      ? kaloriYangMasihBisaDikonsumsi / totalRekomendasiKalori
                      : 0.0;
                  if (progressValue < 0) {
                    progressValue = 0;
                  }
                  if (progressValue > 1) {
                    progressValue = 1;
                  }

                  // --- PERBAIKAN DI SINI: Menggunakan _formatSnakeCaseToTitleCase ---
                  if (_currentKaloriModel!.tujuan.isNotEmpty) {
                    displayMessageSpans.add(
                      const TextSpan(
                        text: "",
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    );
                    displayMessageSpans.add(
                      TextSpan(
                        text: _formatSnakeCaseToTitleCase(
                            _currentKaloriModel!.tujuan), // Menggunakan helper
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                    displayMessageSpans.add(
                      const TextSpan(
                        text: ". Mari konsisten capai pola makan yang sehat!",
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    );
                  } else {
                    displayMessageSpans.add(
                      const TextSpan(
                        text: "Yuk, siap jaga pola makan!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                } else {
                  // Fallback jika KaloriLoaded tetapi _currentKaloriModel null (jarang terjadi)
                  displayMessageSpans
                      .add(const TextSpan(text: "Data kalori tidak tersedia."));
                }
              } else if (state is KaloriError) {
                displayMessageSpans.add(TextSpan(
                    text: state.message,
                    style: const TextStyle(color: Colors.red)));
              } else if (state is KaloriSuccess) {
                // Ini adalah KaloriSuccess, bukan KaloriAddSuccess
                displayMessageSpans.add(TextSpan(text: state.message));
                // _currentKaloriModel sudah di-set null di listener
              } else if (state is KaloriInitial) {
                displayMessageSpans.add(const TextSpan(
                    text: "Memuat data awal atau tidak ada data kalori."));
              } else {
                displayMessageSpans
                    .add(const TextSpan(text: "Selamat datang di VitaCal!"));
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.05,
                    ),
                    child: Column(
                      children: [
                        // Header dengan ikon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                "assets/icons/logo.svg",
                                height: 35.0,
                              ),
                              onPressed: () {},
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: SvgPicture.asset(
                                    "assets/icons/calender.svg",
                                    height: iconSize,
                                  ),
                                  onPressed: () {
                                    showKalenderDialog(context);
                                  },
                                ),
                                const SizedBox(width: 11),
                                IconButton(
                                  icon: SvgPicture.asset(
                                    "assets/icons/notif.svg",
                                    height: iconSize,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Notifikasi(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 33),

                        // Tanggal utama (tanggal hari ini)
                        Align(
                          alignment:
                              Alignment.centerLeft, // Menggeser tanggal ke kiri
                          child: Text(
                            DateFormat("d MMMM yyyy", 'id_ID').format(DateTime
                                .now()), // Menggunakan 'yyyy' untuk tahun
                            style: const TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 33),

                        // Row hari dan tanggal dalam kotak dengan border
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: weekDates.asMap().entries.map((entry) {
                              int index = entry.key;
                              DateTime date = entry.value;

                              bool isSelected = selectedIndex == index;
                              bool isToday =
                                  DateFormat("yyyy-MM-dd").format(date) ==
                                      DateFormat("yyyy-MM-dd")
                                          .format(DateTime.now());

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(21),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isToday
                                              ? AppColors.primary
                                              : Colors.black.withOpacity(0.5)),
                                      width: isToday ? 1.2 : 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        shortDays[
                                            DateFormat("EEEE").format(date)]!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.7)
                                              : AppColors.darkGrey
                                                  .withOpacity(0.7),
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat("d").format(date),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.darkGrey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 33),

                        // Area Pesan Ringkas
                        SizedBox(
                          width: 280,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: displayMessageSpans,
                              style: const TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 33),

                        // Indikator Lingkaran Kalori (Menampilkan Kalori Rekomendasi)
                        Container(
                          width: 372,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(33),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 33),
                              isLoading // Menggunakan isLoading dari state BLoC
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : _currentKaloriModel == null
                                      ? Column(
                                          children: [
                                            Text(
                                              (state is KaloriError)
                                                  ? state.message
                                                  : "Data kalori tidak tersedia.",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Trigger event untuk fetch data ulang
                                                context.read<KaloriBloc>().add(
                                                    const FetchKaloriData());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.secondary),
                                              child: const Text(
                                                  'Coba Hitung Kalori Ulang',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        )
                                      : Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 170,
                                              height: 170,
                                              child: CircularProgressIndicator(
                                                value: progressValue,
                                                backgroundColor: Colors.white
                                                    .withOpacity(0.2),
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                                strokeWidth: 15,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.bolt,
                                                    color: Colors.amber,
                                                    size: 28),
                                                const SizedBox(height: 5),
                                                FittedBox(
                                                  child: Text(
                                                    '$totalRekomendasiKalori', // Menampilkan total rekomendasi
                                                    style: const TextStyle(
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                const SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    "Kalori Harian Direkomendasikan", // Teks disesuaikan
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                              const SizedBox(height: 50),
                              // Bagian untuk Kalori yang Sudah Dikonsumsi (Data Sementara)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant,
                                      color: Colors.amber,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$kaloriSudahDikonsumsiHariIni Kkal', // Menampilkan kalori yang sudah dikonsumsi
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: AppColors.cream,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Kalori yang sudah dikonsumsi", // Teks disesuaikan
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 33),

                              // Detail Makro Nutrien (Disesuaikan menjadi 0g)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.fitness_center,
                                          color: AppColors.screen, size: 24),
                                      const SizedBox(height: 5),
                                      Text("Protein",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w400)),
                                      const SizedBox(height: 5),
                                      const Text("0g",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.cream,
                                              fontWeight: FontWeight
                                                  .bold)), // DIUBAH: 0g
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.local_fire_department,
                                          color: AppColors.screen, size: 24),
                                      const SizedBox(height: 5),
                                      Text("Lemak",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w400)),
                                      const SizedBox(height: 5),
                                      const Text("0g",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.cream,
                                              fontWeight: FontWeight
                                                  .bold)), // DIUBAH: 0g
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.restaurant_menu,
                                          color: AppColors.screen, size: 24),
                                      const SizedBox(height: 5),
                                      Text("Karbohidrat",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w400)),
                                      const SizedBox(height: 5),
                                      const Text("0g",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.cream,
                                              fontWeight: FontWeight
                                                  .bold)), // DIUBAH: 0g
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Tombol "Hapus Rekomendasi Kalori" Dihapus
                            ],
                          ),
                        ),

                        // Bagian Makan Pagi, Siang, Malam, Lainnya
                        const SizedBox(height: 33),
                        _buildMealCard("Makan Pagi", Icons.sunny_snowing,
                            Colors.deepOrangeAccent, const MakanPagi()),
                        const SizedBox(height: 21),
                        _buildMealCard("Makan Siang", Icons.wb_sunny_rounded,
                            Colors.orange, const MakanSiang()),
                        const SizedBox(height: 21),
                        _buildMealCard("Makan Malam", Icons.nightlight_round,
                            Colors.blueAccent, const MakanMalam()),
                        const SizedBox(height: 21),
                        _buildMealCard("Lainnya", Icons.fastfood,
                            AppColors.primary, const Lainnya()),
                        const SizedBox(height: 100),
                      ],
                    )),
              );
            },
          ),
        ),
      ),
    );
  }
}
