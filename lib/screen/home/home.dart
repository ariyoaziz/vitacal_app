// lib/screen/home/home.dart

// ignore_for_file: deprecated_member_use, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tetap diimpor, tapi tidak akan mempengaruhi status bar jika tidak digunakan AnnotatedRegion
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
import 'package:vitacal_app/models/kalori_model.dart';
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/kalori/kalori_event.dart';
import 'package:vitacal_app/blocs/kalori/kalori_state.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = -1; // Indeks untuk menandai hari yang dipilih
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

    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    weekDates =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    selectedIndex = weekDates.indexWhere((date) =>
        DateFormat("yyyy-MM-dd").format(date) ==
        DateFormat("yyyy-MM-dd").format(today));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerFetchKaloriData();
    });
  }

  Future<void> _triggerFetchKaloriData() async {
    print(
        'Home: Memicu FetchKaloriData event. Mengasumsikan pengguna sudah login.');
    context.read<KaloriBloc>().add(const FetchKaloriData());
  }

  Future<void> _refreshData() async {
    print('Home: Refreshing data by dispatching FetchKaloriData event...');
    context.read<KaloriBloc>().add(const FetchKaloriData());
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
  }

  String _formatSnakeCaseToTitleCase(String snakeCaseString) {
    if (snakeCaseString.isEmpty) return '';
    return snakeCaseString
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Widget _buildMealCard(
      String title, IconData icon, Color iconColor, Widget destinationPage) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destinationPage));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.screen,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.1),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey)),
                    const SizedBox(height: 5),
                    Text("Total: 0 Kkal",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkGrey.withOpacity(0.7))),
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
    const double iconSize = 24.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      // Hapus AnnotatedRegion dan extendBodyBehindAppBar
      // Konten utama akan berada di dalam SafeArea
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
                _triggerFetchKaloriData();
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
                if (_currentKaloriModel != null) {
                  totalRekomendasiKalori =
                      _currentKaloriModel!.numericRekomendasiKalori;
                  kaloriYangMasihBisaDikonsumsi =
                      totalRekomendasiKalori - kaloriSudahDikonsumsiHariIni;
                  if (kaloriYangMasihBisaDikonsumsi < 0) {
                    kaloriYangMasihBisaDikonsumsi = 0;
                  }

                  progressValue = totalRekomendasiKalori > 0
                      ? kaloriSudahDikonsumsiHariIni / totalRekomendasiKalori
                      : 0.0;
                  if (progressValue < 0) {
                    progressValue = 0;
                  }
                  if (progressValue > 1) {
                    progressValue = 1;
                  }

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
                            _currentKaloriModel!.tujuan),
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
                  displayMessageSpans
                      .add(const TextSpan(text: "Data kalori tidak tersedia."));
                }
              } else if (state is KaloriError) {
                displayMessageSpans.add(TextSpan(
                    text: state.message,
                    style: const TextStyle(color: Colors.red)));
              } else if (state is KaloriSuccess) {
                displayMessageSpans.add(TextSpan(text: state.message));
              } else if (state is KaloriInitial) {
                displayMessageSpans.add(const TextSpan(
                    text: "Memuat data awal atau tidak ada data kalori."));
              } else {
                displayMessageSpans
                    .add(const TextSpan(text: "Selamat datang di VitaCal!"));
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                // Padding di sini akan mengatur jarak konten dari tepi SafeArea
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header dengan ikon (sekarang di dalam SafeArea)
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
                                    builder: (context) => const Notifikasi(),
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
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat("EEEE, d MMMM yyyy", 'id_ID')
                            .format(DateTime.now()),
                        style: const TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
                          bool isToday = DateFormat("yyyy-MM-dd")
                                  .format(date) ==
                              DateFormat("yyyy-MM-dd").format(DateTime.now());

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isToday
                                            ? AppColors.primary
                                            : Colors.grey.withOpacity(0.5)),
                                    width: isToday ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      shortDays[
                                          DateFormat("EEEE").format(date)]!,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.8)
                                            : AppColors.darkGrey,
                                        fontSize: 12.0,
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
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 33),

                    // Area Pesan Ringkas
                    SizedBox(
                      width: screenWidth * 0.75,
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

                    // Indikator Lingkaran Kalori (Menampilkan Kalori Rekomendasi & Konsumsi)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          isLoading
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
                                            context
                                                .read<KaloriBloc>()
                                                .add(const FetchKaloriData());
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.secondary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12))),
                                          child: const Text(
                                              'Coba Hitung Kalori Ulang'),
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
                                            backgroundColor:
                                                Colors.white.withOpacity(0.3),
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
                                                color: Colors.amber, size: 28),
                                            const SizedBox(height: 5),
                                            FittedBox(
                                              child: Text(
                                                '$totalRekomendasiKalori',
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            const SizedBox(
                                              width: 120,
                                              child: Text(
                                                "Kalori Harian Direkomendasikan",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                          const SizedBox(height: 33),
                          // Bagian untuk Kalori yang Sudah Dikonsumsi
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: const Icon(Icons.restaurant,
                                    color: Colors.amber, size: 25),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$kaloriSudahDikonsumsiHariIni Kkal',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: AppColors.cream,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Kalori yang sudah dikonsumsi",
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

                          // Detail Makro Nutrien
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMacroNutrientColumn(
                                  "Protein", Icons.fitness_center, "0g"),
                              _buildMacroNutrientColumn(
                                  "Lemak", Icons.local_fire_department, "0g"),
                              _buildMacroNutrientColumn(
                                  "Karbohidrat", Icons.restaurant_menu, "0g"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bagian Makan Pagi, Siang, Malam, Lainnya
                    const SizedBox(height: 33),
                    _buildMealCard("Makan Pagi", Icons.sunny_snowing,
                        Colors.deepOrangeAccent, const MakanPagi()),
                    const SizedBox(height: 16),
                    _buildMealCard("Makan Siang", Icons.wb_sunny_rounded,
                        Colors.orange, const MakanSiang()),
                    const SizedBox(height: 16),
                    _buildMealCard("Makan Malam", Icons.nightlight_round,
                        Colors.blueAccent, const MakanMalam()),
                    const SizedBox(height: 16),
                    _buildMealCard("Lainnya", Icons.fastfood, AppColors.primary,
                        const Lainnya()),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMacroNutrientColumn(String title, IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.screen, size: 24),
        const SizedBox(height: 5),
        Text(title,
            style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                color: AppColors.cream,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
