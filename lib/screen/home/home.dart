// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:vitacal_app/models/profile_model.dart';
import 'package:vitacal_app/models/enums.dart'; // Diperlukan untuk Tujuan.toDisplayString() dan TingkatAktivitas.toDisplayString()

// Import blocs
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/kalori/kalori_event.dart';
import 'package:vitacal_app/blocs/kalori/kalori_state.dart';

import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_event.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = -1;
  final Map<String, String> shortDays = {
    "Monday": "Sen",
    "Tuesday": "Sel",
    "Wednesday": "Rab",
    "Thursday": "Kam",
    "Friday": "Jum",
    "Saturday": "Sab",
    "Sunday": "Min",
  };

  late List<DateTime> weekDates;
  late DateTime
      _selectedDate; // Tanggal yang sedang dipilih (untuk tanggal utama)

  KaloriModel? _currentKaloriModel;
  ProfileModel? _currentProfileModel;

  int kaloriSudahDikonsumsiHariIni = 0; // Contoh nilai default

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    _selectedDate =
        DateTime.now(); // Inisialisasi tanggal yang dipilih dengan hari ini
    _generateWeekDates(
        _selectedDate); // Generate week dates berdasarkan tanggal yang dipilih

    // Set selectedIndex agar sesuai dengan _selectedDate (hari ini)
    selectedIndex = weekDates.indexWhere((date) =>
        DateFormat("yyyy-MM-dd").format(date) ==
        DateFormat("yyyy-MM-dd").format(_selectedDate));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerFetchKaloriData(); // Panggil ini untuk mendapatkan data kalori awal
      context.read<ProfileBloc>().add(
          const LoadProfileData()); // Panggil ini untuk mendapatkan data profil awal
    });
  }

  // Tambahkan fungsi ini di dalam kelas _HomeState Anda
  String _getCalorieAdjustmentText(int recommendedCalories, double tdee) {
    int adjustment = (recommendedCalories - tdee).round();
    if (adjustment > 0) {
      return "ditambah ${adjustment.abs()} Kkal";
    } else if (adjustment < 0) {
      return "dikurangi ${adjustment.abs()} Kkal";
    } else {
      return "tanpa penyesuaian";
    }
  }

  // Metode untuk menghasilkan daftar tanggal dalam seminggu
  void _generateWeekDates(DateTime centralDate) {
    DateTime startOfWeek;
    // Memastikan startOfWeek adalah Senin (weekday 1)
    if (centralDate.weekday == DateTime.sunday) {
      // Jika hari Minggu, kurangi 6 hari untuk mendapatkan Senin sebelumnya
      startOfWeek = centralDate.subtract(const Duration(days: 6));
    } else {
      startOfWeek =
          centralDate.subtract(Duration(days: centralDate.weekday - 1));
    }

    weekDates =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // Metode untuk mengubah tanggal yang dipilih
  void _onDateSelected(DateTime newDate, int index) {
    setState(() {
      _selectedDate = newDate;
      selectedIndex = index;
    });
  }

  Future<void> _triggerFetchKaloriData() async {
    print(
        'Home: Memicu FetchKaloriData event. Mengasumsikan pengguna sudah login.');
    context.read<KaloriBloc>().add(const FetchKaloriData());
  }

  Future<void> _refreshData() async {
    print(
        'Home: Refreshing data by dispatching FetchKaloriData and LoadProfileData events...');

    // Reset _selectedDate dan selectedIndex ke hari ini
    setState(() {
      _selectedDate = DateTime.now();
      _generateWeekDates(
          _selectedDate); // Regenerate week dates for current week
      selectedIndex = weekDates.indexWhere((date) =>
          DateFormat("yyyy-MM-dd").format(date) ==
          DateFormat("yyyy-MM-dd").format(_selectedDate));
    });

    // Pemicu ulang data dari BLoC
    context.read<KaloriBloc>().add(const FetchKaloriData());
    context.read<ProfileBloc>().add(const LoadProfileData());
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
                    Text(
                        "Total: 0 Kkal", // Placeholder, perlu diisi data aktual
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

    final DateTime? userCreatedAtDateFromModel =
        _currentProfileModel?.userCreatedAt;

// Pastikan _selectedDate juga sudah didefinisikan di State Anda.

    bool isDateBeforeAccountCreation = userCreatedAtDateFromModel !=
            null && // <<< Gunakan variabel yang benar
        _selectedDate.isBefore(DateTime(
            userCreatedAtDateFromModel.year, // <<< Gunakan variabel yang benar
            userCreatedAtDateFromModel.month,
            userCreatedAtDateFromModel.day));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          backgroundColor: AppColors.screen,
          strokeWidth: 3,
          displacement: 60,
          child: MultiBlocListener(
            listeners: [
              BlocListener<KaloriBloc, KaloriState>(
                listener: (context, state) {
                  if (state is KaloriError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error Kalori: ${state.message}'),
                          backgroundColor: Colors.red),
                    );
                  } else if (state is KaloriSuccess) {
                    // KaloriSuccess biasanya berarti suatu operasi berhasil, bukan pemuatan data
                    // Jika ini berarti data baru tersedia, Anda mungkin perlu memicu FetchKaloriData lagi
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //       content: Text(state.message),
                    //       backgroundColor: Colors.green),
                    // );
                    _triggerFetchKaloriData(); // Panggil ulang untuk memuat data setelah sukses (misal: simpan data makanan)
                  } else if (state is KaloriLoaded) {
                    setState(() {
                      _currentKaloriModel = state.kaloriModel;
                      print(
                          'DEBUG HOME: KaloriModel Loaded: $_currentKaloriModel');
                      if (_currentKaloriModel != null) {
                        print(
                            'DEBUG HOME: Rekomendasi Kalori: ${_currentKaloriModel!.numericRekomendasiKalori}');
                        print('DEBUG HOME: BMR: ${_currentKaloriModel!.bmr}');
                        print('DEBUG HOME: TDEE: ${_currentKaloriModel!.tdee}');
                        print(
                            'DEBUG HOME: Tujuan Text (dari KaloriModel): ${_currentKaloriModel!.tujuanRekomendasiSistem}');
                      }
                    });
                  }
                },
              ),
              BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileError) {
                    print('DEBUG HOME: ProfileError: ${state.message}');
                  } else if (state is ProfileLoaded) {
                    setState(() {
                      _currentProfileModel = state.profileData;
                      print(
                          'DEBUG HOME: ProfileModel Loaded: $_currentProfileModel');
                      if (_currentProfileModel?.userDetail != null) {
                        print(
                            'DEBUG HOME: Tujuan (dari ProfileModel): ${_currentProfileModel!.userDetail!.tujuan?.toDisplayString()}');
                        print(
                            'DEBUG HOME: Tingkat Aktivitas (dari ProfileModel): ${_currentProfileModel!.userDetail!.aktivitas.toDisplayString()}');
                      }
                    });
                  }
                },
              ),
            ],
            child: BlocBuilder<KaloriBloc, KaloriState>(
              builder: (context, kaloriState) {
                int totalRekomendasiKalori = 0;
                double progressValue = 0.0;
                bool isLoading = false;
                List<TextSpan> displayMessageSpans = [];

                if (kaloriState is KaloriLoading) {
                  isLoading = true;
                  displayMessageSpans
                      .add(const TextSpan(text: "Memuat data kalori..."));
                } else if (_currentKaloriModel != null) {
                  totalRekomendasiKalori =
                      _currentKaloriModel!.numericRekomendasiKalori;

                  // PENTING: kaloriSudahDikonsumsiHariIni masih placeholder.
                  // Anda perlu memuat nilai ini dari backend atau BLoC makanan.
                  // Misalnya:
                  // if (_currentMealDataModel != null) {
                  //   kaloriSudahDikonsumsiHariIni = _currentMealDataModel.totalKaloriDikonsumsi;
                  // }

                  progressValue = totalRekomendasiKalori > 0
                      ? kaloriSudahDikonsumsiHariIni / totalRekomendasiKalori
                      : 0.0;
                  if (progressValue < 0) {
                    progressValue = 0;
                  }
                  if (progressValue > 1) {
                    progressValue = 1;
                  }

                  String tujuanDisplayString = _currentProfileModel
                          ?.userDetail?.tujuan
                          ?.toDisplayString() ??
                      '';

                  if (isDateBeforeAccountCreation) {
                    displayMessageSpans.add(
                      const TextSpan(
                        text: "Data tidak tersedia sebelum akun dibuat.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    );
                    displayMessageSpans.add(
                      const TextSpan(
                        text:
                            "\nInformasi kalori dan target hanya tersedia mulai dari tanggal akun Anda terdaftar.",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                    );
                  } else if (totalRekomendasiKalori > 0) {
                    displayMessageSpans.add(
                      const TextSpan(
                        text: "Target kalori harian Anda adalah ",
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    );
                    displayMessageSpans.add(
                      TextSpan(
                        text: "$totalRekomendasiKalori Kkal",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );

                    if (tujuanDisplayString.isNotEmpty) {
                      displayMessageSpans.add(
                        const TextSpan(
                          text: " untuk ",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      );
                      displayMessageSpans.add(
                        TextSpan(
                          text:
                              _formatSnakeCaseToTitleCase(tujuanDisplayString),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                      displayMessageSpans.add(
                        const TextSpan(
                          text:
                              " Anda! Mari konsisten capai pola makan yang sehat.",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      );
                    } else {
                      displayMessageSpans.add(
                        const TextSpan(
                          text: ". Mari konsisten capai pola makan yang sehat!",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      );
                    }
                  } else {
                    displayMessageSpans.add(
                      const TextSpan(
                        text: "Yuk, siap jaga pola makan sehatmu!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                    displayMessageSpans.add(
                      const TextSpan(
                        text:
                            "\nLengkapi data profilmu untuk dapat rekomendasi kalori harian.",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                    );
                  }
                } else if (kaloriState is KaloriError) {
                  displayMessageSpans.add(TextSpan(
                      text: kaloriState.message,
                      style: const TextStyle(color: Colors.red)));
                } else if (kaloriState is KaloriSuccess) {
                  displayMessageSpans.add(TextSpan(text: kaloriState.message));
                } else if (kaloriState is KaloriInitial) {
                  displayMessageSpans.add(const TextSpan(
                      text: "Memuat data awal atau tidak ada data kalori."));
                } else {
                  displayMessageSpans
                      .add(const TextSpan(text: "Selamat datang di VitaCal!"));
                }
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                            const Notifikasi()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 33),

                      // Tanggal utama (tanggal yang dipilih)
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat("EEEE, d MMMM yyyy", 'id_ID').format(
                              _selectedDate), // PERBAIKAN: Format tahun 'yyyy'
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

                            bool isSelected = DateFormat("yyyy-MM-dd")
                                    .format(date) ==
                                DateFormat("yyyy-MM-dd").format(_selectedDate);
                            bool isToday = DateFormat("yyyy-MM-dd")
                                    .format(date) ==
                                DateFormat("yyyy-MM-dd").format(DateTime.now());

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _onDateSelected(date, index),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
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
                            // --- Judul Kartu Utama (Dengan Efek Gradient/Visual) ---
                            Align(
                              alignment: Alignment.center,
                              child: ShaderMask(
                                // Untuk efek gradient pada teks
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.white,
                                      AppColors.cream.withOpacity(0.8)
                                    ], // Gradient dari putih ke cream
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  "Progres Kalori",
                                  style: TextStyle(
                                    fontSize: 20, // Lebih besar untuk penekanan
                                    color: Colors
                                        .white, // Warna dasar untuk ShaderMask
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // --- Garis Pemisah Setelah Judul ---
                            Divider(
                              color: Colors.white.withOpacity(0.3),
                              thickness: 1,
                              height: 0,
                            ),
                            const SizedBox(height: 25),

                            // --- Konten Utama Berdasarkan Kondisi ---
                            isLoading
                                ? Center(
                                    child: Column(
                                      children: [
                                        const CircularProgressIndicator(
                                            color: Colors.white),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Memuat data kalori...",
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                  )
                                : isDateBeforeAccountCreation
                                    ? Center(
                                        child: Column(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                color: Colors.white, size: 40),
                                            const SizedBox(height: 15),
                                            const Text(
                                              "Data tidak tersedia untuk tanggal ini.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Informasi kalori hanya tersedia mulai dari tanggal akun Anda terdaftar.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _currentKaloriModel == null ||
                                            totalRekomendasiKalori <= 0
                                        ? Center(
                                            child: Column(
                                              children: [
                                                const Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.white,
                                                    size: 40),
                                                const SizedBox(height: 15),
                                                const Text(
                                                  "Data kalori tidak tersedia.",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  (kaloriState is KaloriError)
                                                      ? kaloriState.message
                                                      : "Silakan lengkapi profil Anda atau coba hitung ulang.",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      fontSize: 13),
                                                ),
                                                const SizedBox(height: 15),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    print(
                                                        'Tombol "Coba Hitung Kalori Ulang" diklik');
                                                    context.read<KaloriBloc>().add(
                                                        const FetchKaloriData());
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppColors.secondary,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12))),
                                                  child: const Text(
                                                      'Coba Hitung Kalori Ulang'),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              // Lingkaran Progres & Rekomendasi
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    height: 200,
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: progressValue,
                                                      backgroundColor: Colors
                                                          .white
                                                          .withOpacity(0.4),
                                                      valueColor:
                                                          const AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                      strokeWidth: 20,
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(Icons.bolt,
                                                          color: Colors.amber,
                                                          size: 28),
                                                      const SizedBox(height: 5),
                                                      FittedBox(
                                                        child: Text(
                                                          '$totalRekomendasiKalori',
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                36, // Angka lebih besar
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
                                                          "Kalori Harian Direkomendasikan",
                                                          textAlign:
                                                              TextAlign.center,
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
                                              const SizedBox(height: 33),

                                              // Kalori Sudah Dikonsumsi
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                    ),
                                                    child: const Icon(
                                                        Icons.restaurant,
                                                        color: Colors.amber,
                                                        size: 25),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '$kaloriSudahDikonsumsiHariIni Kkal',
                                                    style: const TextStyle(
                                                      fontSize:
                                                          24, // Angka lebih besar
                                                      color: AppColors.cream,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "Kalori yang sudah dikonsumsi",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height: 33), // Jarak sebelum detail BMR/TDEE

                      // *** KARTU BARU: Detail BMR, TDEE, Penjelasan & TINGKAT AKTIVITAS ***
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.screen,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Analisis Kalori Harian", // Perhatikan penggunaan judulnya yang tetap ini
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors
                                      .darkGrey, // Warna gelap untuk kontras
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12), // Jarak setelah judul

                            // --- Garis Pemisah Setelah Judul ---
                            Divider(
                              color: AppColors.darkGrey
                                  .withOpacity(0.2), // Warna garis yang halus
                              thickness: 1,
                              height:
                                  0, // Tinggi 0 agar tidak menambah ruang ekstra
                            ),
                            const SizedBox(
                                height:
                                    25), // Jarak yang lebih besar setelah divider

                            // Row untuk BMR dan TDEE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSimplifiedInfoColumnOnWhite(
                                  "BMR",
                                  _currentKaloriModel != null
                                      ? "${_currentKaloriModel!.bmr?.round() ?? 'N/A'} Kkal" // <<< PERBAIKAN DI SINI
                                      : "N/A",
                                  Icons.calculate,
                                ),
                                _buildSimplifiedInfoColumnOnWhite(
                                  "TDEE",
                                  _currentKaloriModel != null
                                      ? "${_currentKaloriModel!.tdee?.round() ?? 'N/A'} Kkal" // <<< PERBAIKAN DI SINI
                                      : "N/A",
                                  Icons.directions_run,
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: 20), // Jarak setelah BMR/TDEE

                            // --- BAGIAN BARU: Tingkat Aktivitas ---
                            if (_currentProfileModel?.userDetail?.aktivitas !=
                                null)
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const Icon(Icons.fitness_center_rounded,
                                        color: AppColors.primary, size: 28),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Tingkat Aktivitas",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _formatSnakeCaseToTitleCase(
                                          _currentProfileModel!
                                              .userDetail!.aktivitas
                                              .toDisplayString()),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: AppColors
                                            .primary, // Warna khusus untuk penekanan
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(
                                height: 20), // Jarak setelah aktivitas

                            // --- Garis Pemisah Antara Angka dan Penjelasan ---
                            Divider(
                              color: AppColors.darkGrey.withOpacity(0.2),
                              thickness: 1,
                              height: 0,
                            ),
                            const SizedBox(height: 20), // Jarak setelah divider

                            // Penjelasan rekomendasi
                            if (_currentKaloriModel != null &&
                                _currentKaloriModel!.rekomendasiKaloriHarian !=
                                    null && // Cek apakah nilainya sendiri tidak null
                                _currentProfileModel != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.justify,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            AppColors.darkGrey.withOpacity(0.8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text:
                                                "Target kalori harian Anda adalah "),
                                        TextSpan(
                                          text:
                                              "${_currentKaloriModel!.numericRekomendasiKalori} Kkal",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary),
                                        ),
                                        const TextSpan(text: "."),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 8), // Jarak antar paragraf

                                  RichText(
                                    textAlign: TextAlign.justify,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            AppColors.darkGrey.withOpacity(0.8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text:
                                                "Angka ini dihitung dari Total Pengeluaran Energi Harian (TDEE) Anda sebesar "),
                                        TextSpan(
                                          text:
                                              "${_currentKaloriModel!.tdee?.round() ?? 0} Kkal", // <<< PERBAIKAN DI SINI
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        TextSpan(text: ", yang kemudian "),
                                        TextSpan(
                                          text: _getCalorieAdjustmentText(
                                            _currentKaloriModel!
                                                .numericRekomendasiKalori,
                                            _currentKaloriModel!.tdee ??
                                                0.0, // <<< FIX HERE: Provide a default value (e.g., 0.0) if tdee is null
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const TextSpan(
                                            text:
                                                " untuk mencapai tujuan Anda."),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 8), // Jarak antar paragraf

                                  RichText(
                                    textAlign: TextAlign.justify,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            AppColors.darkGrey.withOpacity(0.8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text: "Tujuan utama Anda adalah "),
                                        TextSpan(
                                          // --- PERBAIKAN DI SINI ---
                                          // Ambil tujuan dari _currentKaloriModel dan gunakan toDisplayString()
                                          text: _currentKaloriModel
                                                  ?.tujuanRekomendasiSistem
                                                  ?.toDisplayString() ??
                                              'mencapai berat ideal', // Fallback jika null
                                          // --- AKHIR PERBAIKAN ---
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const TextSpan(
                                            text:
                                                ", dengan mempertimbangkan berat badan Anda saat ini."),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else // Kondisi jika data kalori atau profil null
                              Text(
                                "Lengkapi data profil Anda untuk mendapatkan perhitungan kalori harian dan rekomendasi yang dipersonalisasi.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkGrey.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.justify,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 33), // Jarak sebelum meal cards

                      // Bagian Makan Pagi, Siang, Malam, Lainnya
                      _buildMealCard("Makan Pagi", Icons.sunny_snowing,
                          Colors.deepOrangeAccent, const MakanPagi()),
                      const SizedBox(height: 16),
                      _buildMealCard("Makan Siang", Icons.wb_sunny_rounded,
                          Colors.orange, const MakanSiang()),
                      const SizedBox(height: 16),
                      _buildMealCard("Makan Malam", Icons.nightlight_round,
                          Colors.blueAccent, const MakanMalam()),
                      const SizedBox(height: 16),
                      _buildMealCard("Lainnya", Icons.fastfood,
                          AppColors.primary, const Lainnya()),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Fungsi pembantu untuk tampilan info BMR/TDEE pada latar belakang terang (AppColors.screen)
  Widget _buildSimplifiedInfoColumnOnWhite(
      String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 30), // Ikon berwarna primary
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.darkGrey, // Teks judul gelap
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            color: AppColors.darkGrey, // Angka gelap
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
