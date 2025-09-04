// lib/screen/home/home.dart
// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/models/enums.dart';

import 'package:vitacal_app/screen/home/kalender.dart';
import 'package:vitacal_app/screen/home/lainnya.dart';
import 'package:vitacal_app/screen/home/makan_malam.dart';
import 'package:vitacal_app/screen/home/makan_pagi.dart';
import 'package:vitacal_app/screen/home/makan_siang.dart';
import 'package:vitacal_app/screen/home/notifikasi.dart';

import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/kalori_model.dart';
import 'package:vitacal_app/models/profile_model.dart';

// Blocs
import 'package:vitacal_app/blocs/kalori/kalori_bloc.dart';
import 'package:vitacal_app/blocs/kalori/kalori_event.dart';
import 'package:vitacal_app/blocs/kalori/kalori_state.dart';
import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_state.dart';

import 'dart:math' as math;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int selectedIndex = -1;
  int proteinHariIni = 0;
  int karboHariIni = 0;
  int lemakHariIni = 0;

  late List<DateTime> weekDates;
  late DateTime _selectedDate;

  KaloriModel? _currentKaloriModel; // cache Kalori
  ProfileModel? _currentProfileModel; // cache Profil (untuk aktivitas)

  // NOTE: Hapus _hydratedFromProfile — bikin data tidak pernah update lagi
  // bool _hydratedFromProfile = false;

  int kaloriSudahDikonsumsiHariIni = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      initializeDateFormatting('id_ID', null);
    } catch (_) {}

    _selectedDate = DateTime.now();
    _generateWeekDates(_selectedDate);
    selectedIndex = weekDates.indexWhere((d) =>
        DateFormat('yyyy-MM-dd').format(d) ==
        DateFormat('yyyy-MM-dd').format(_selectedDate));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _softFetch(); // biarkan cache tampil, fetch jalan di belakang
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Auto-refresh saat balik dari background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _softFetch();
    }
  }

  void _softFetch() {
    if (!mounted) return;
    context.read<KaloriBloc>().add(const FetchKaloriData());
    // Tidak fetch Profile di sini — kita hanya LISTEN ProfileLoaded dari tempat lain
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      _selectedDate = DateTime.now();
      _generateWeekDates(_selectedDate);
      selectedIndex = weekDates.indexWhere((d) =>
          DateFormat('yyyy-MM-dd').format(d) ==
          DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
    // Biar makin “segar”, boleh sekalian tarik Profile saat pull-to-refresh:
    // context.read<ProfileBloc>().add(const LoadProfileData());
    _softFetch();
  }

  void _generateWeekDates(DateTime d) {
    final w = d.weekday;
    final start = w == DateTime.sunday
        ? d.subtract(const Duration(days: 6))
        : d.subtract(Duration(days: w - 1));
    weekDates = List.generate(7, (i) => start.add(Duration(days: i)));
  }

  void _onDateSelected(DateTime newDate, int index) {
    if (!mounted) return;
    setState(() {
      _selectedDate = newDate;
      selectedIndex = index;
    });
  }

  String _formatSnakeCaseToTitleCase(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  double _clamp01(double v) => v.isNaN ? 0 : v.clamp(0.0, 1.0);

  String _getCalorieAdjustmentText(int recommendedCalories, double tdee) {
    final adj = (recommendedCalories - tdee).round();
    if (adj > 0) return "ditambah ${adj.abs()} Kkal";
    if (adj < 0) return "dikurangi ${adj.abs()} Kkal";
    return "tanpa penyesuaian";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double iconSize = 24.0;

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
              // === KALORI LISTENER ===
              BlocListener<KaloriBloc, KaloriState>(
                listenWhen: (prev, curr) =>
                    curr is KaloriLoaded, // diam saat Loading/Error
                listener: (context, state) {
                  if (!mounted) return;
                  final loaded = state as KaloriLoaded;
                  // Update cache UI
                  setState(() => _currentKaloriModel = loaded.kaloriModel);
                },
              ),
              // === PROFILE LISTENER ===
              BlocListener<ProfileBloc, ProfileState>(
                listenWhen: (prev, curr) => curr is ProfileLoaded,
                listener: (context, state) {
                  if (!mounted) return;
                  final loaded = state as ProfileLoaded;

                  // simpan profil (buat tampil tingkat aktivitas, dsb)
                  setState(() => _currentProfileModel = loaded.profileData);

                  // PENTING: sinkronkan kalori SETIAP ada ProfileLoaded
                  final KaloriModel? kFromProfile = loaded.profileData
                      .rekomendasiKaloriData; // pastikan field benar
                  if (kFromProfile != null) {
                    // update UI cache
                    setState(() => _currentKaloriModel = kFromProfile);
                    // dan hydrate ke KaloriBloc biar state global konsisten
                    context
                        .read<KaloriBloc>()
                        .add(HydrateKaloriFromProfile(kFromProfile));
                  }
                },
              ),
            ],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ======= HEADER =======
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: SvgPicture.asset("assets/icons/logo.svg",
                            height: 35),
                        onPressed: () {},
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: SvgPicture.asset("assets/icons/calender.svg",
                                height: iconSize),
                            onPressed: () => showKalenderDialog(context),
                          ),
                          const SizedBox(width: 11),
                          IconButton(
                            icon: SvgPicture.asset("assets/icons/notif.svg",
                                height: iconSize),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Notifikasi()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 33),

                  // ======= TANGGAL =======
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat("EEEE, d MMMM yyyy", 'id_ID')
                          .format(_selectedDate),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 33),

                  // ======= SELECTOR MINGGU =======
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekDates.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;

                        final isSelected = DateFormat('yyyy-MM-dd').format(d) ==
                            DateFormat('yyyy-MM-dd').format(_selectedDate);
                        final isToday = DateFormat('yyyy-MM-dd').format(d) ==
                            DateFormat('yyyy-MM-dd').format(DateTime.now());

                        final labelHariPendek =
                            DateFormat('E', 'id_ID').format(d); // Sen, Sel, ...

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onDateSelected(d, i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
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
                                    labelHariPendek,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.85)
                                          : AppColors.darkGrey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat("d").format(d),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkGrey,
                                      fontSize: 16,
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

                  // ======= HEADLINE =======
                  SizedBox(
                    width: screenWidth * 0.75,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        children: _buildHeadlineMessageSpans(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 33),

                  // ======= PROGRESS KALORI =======
                  _buildProgressCard(),
                  const SizedBox(height: 33),

                  // ======= ANALISIS =======
                  _buildAnalysisCard(),
                  const SizedBox(height: 33),

                  // ======= MEAL CARDS =======
                  _buildMealCard("Makan Pagi", Icons.sunny_snowing,
                      Colors.deepOrangeAccent, const MakanPagi()),
                  const SizedBox(height: 11),
                  _buildMealCard("Makan Siang", Icons.wb_sunny_rounded,
                      Colors.orange, const MakanSiang()),
                  const SizedBox(height: 11),
                  _buildMealCard("Makan Malam", Icons.nightlight_round,
                      Colors.blueAccent, const MakanMalam()),
                  const SizedBox(height: 11),
                  _buildMealCard("Lainnya", Icons.fastfood, AppColors.primary,
                      const Lainnya()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helpers UI =====

  List<TextSpan> _buildHeadlineMessageSpans() {
    final target = _currentKaloriModel?.numericRekomendasiKalori ?? 0;
    final tujuanText =
        _currentKaloriModel?.tujuanRekomendasiSistem?.toDisplayString() ?? '';

    if (target > 0) {
      return [
        const TextSpan(text: "Target kalori harian Anda adalah "),
        TextSpan(
          text: "$target Kkal",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (tujuanText.isNotEmpty) ...[
          const TextSpan(text: " untuk "),
          TextSpan(
            text: _formatSnakeCaseToTitleCase(tujuanText),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
              text: " Anda! Mari konsisten capai pola makan yang sehat."),
        ] else
          const TextSpan(text: ". Mari konsisten capai pola makan yang sehat!"),
      ];
    }

    return const [
      TextSpan(
        text: "Yuk, siap jaga pola makan sehatmu!",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "\nLengkapi data agar dapat rekomendasi kalori harian.",
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
      ),
    ];
  }

  Widget _buildProgressCard() {
    final target = _currentKaloriModel?.numericRekomendasiKalori ?? 0;
    final consumed = kaloriSudahDikonsumsiHariIni;
    final progress = target > 0 ? _clamp01(consumed / target) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ukuran lingkaran adaptif, anti overflow di layar kecil
          final double circleSize =
              (constraints.maxWidth * 0.55).clamp(140.0, 220.0);
          final double strokeWidth =
              (circleSize / 12).clamp(10.0, 16.0); // proporsional

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header sederhana (tanpa shader)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Progres Kalori",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white.withOpacity(0.22), height: 1),
              const SizedBox(height: 20),

              // Progress lingkaran + target
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress lingkaran + target (versi estetik)
                    Center(
                      child: _ProgressDial(
                        progress: progress, // 0..1
                        size: circleSize, // dari LayoutBuilder kamu
                        stroke: strokeWidth, // dari LayoutBuilder kamu
                        targetText: '$target', // teks di tengah
                        subtitle: 'Target harian (Kkal)',
                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            '$target',
                            key: ValueKey(target),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Target harian (Kkal)",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.22), height: 1),
              const SizedBox(height: 16),

              // Konsumsi hari ini (full width)
              _miniStat(
                "Kalori sudah dikonsumsi",
                "$consumed Kkal",
                Icons.restaurant,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),

              const SizedBox(height: 14),

              // 2x2: Kalori / Protein / Karbo / Lemak
              Wrap(
                spacing: 12, // jarak antar kolom
                runSpacing: 12, // jarak antar baris
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _miniStat(
                      "Kalori",
                      "$consumed Kkal",
                      Icons.local_fire_department,
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _miniStat(
                      "Protein",
                      "0 g",
                      Icons.fitness_center,
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _miniStat(
                      "Karbo",
                      "0 g",
                      Icons.rice_bowl,
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _miniStat(
                      "Lemak",
                      "0 g",
                      Icons.opacity,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 4), // safety kecil supaya tidak mepet bawah
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalysisCard() {
    final int? bmr = _currentKaloriModel?.bmr?.round();
    final int? tdee = _currentKaloriModel?.tdee?.round();
    final int rekom = _currentKaloriModel?.numericRekomendasiKalori ?? 0;

    final String? aktivitasLabel =
        _currentProfileModel?.userDetail?.aktivitas.toDisplayString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.screen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.assessment_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                "Analisis Kalori Harian",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _thinDivider(),

          const SizedBox(height: 12),

          // BMR & TDEE (2 kolom simetris)
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  title: "BMR",
                  value: bmr != null ? "$bmr Kkal" : "—",
                  icon: Icons.calculate_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  title: "TDEE",
                  value: tdee != null ? "$tdee Kkal" : "—",
                  icon: Icons.directions_run,
                ),
              ),
            ],
          ),

          // Tingkat Aktivitas (opsional)
          if (aktivitasLabel != null && aktivitasLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            _thinDivider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.fitness_center_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  "Tingkat Aktivitas",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _formatSnakeCaseToTitleCase(aktivitasLabel),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],

          const SizedBox(height: 12),
          _thinDivider(),
          const SizedBox(height: 12),

          // Penjelasan rekomendasi
          if (rekom > 0) ...[
            // Baris 1
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.darkGrey.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: "Target kalori harian Anda adalah "),
                  TextSpan(
                    text: "$rekom Kkal",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Baris 2
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.darkGrey.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(
                      text:
                          "Angka ini dihitung dari TDEE (Total Pengeluaran Energi Harian) sebesar "),
                  TextSpan(
                    text: "${(tdee ?? 0)} Kkal",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: ", lalu "),
                  TextSpan(
                    text: _getCalorieAdjustmentText(
                      rekom,
                      (_currentKaloriModel?.tdee ?? 0.0),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: " untuk menyesuaikan tujuan Anda."),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Baris 3
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.darkGrey.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: "Tujuan utama Anda adalah "),
                  TextSpan(
                    text: _currentKaloriModel?.tujuanRekomendasiSistem
                            ?.toDisplayString() ??
                        'mencapai berat ideal',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(
                      text: ", dengan mempertimbangkan kondisi saat ini."),
                ],
              ),
            ),
          ] else
            Text(
              "Lengkapi data profil untuk mendapatkan perhitungan kalori harian dan rekomendasi yang dipersonalisasi.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.darkGrey.withOpacity(0.75),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumGrey,
                    )),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thinDivider() => Divider(
        color: AppColors.darkGrey.withOpacity(0.12),
        height: 1,
        thickness: 1,
      );

  Widget _buildMealCard(
    String title,
    IconData icon,
    Color iconColor,
    Widget destinationPage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.screen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            ).then((_) {
              _softFetch(); // revalidate setelah balik
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                // leading icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),

                // title + sub
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // NOTE: nanti ganti "0" dengan total dinamis per-meal
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          "Total: 0 Kkal",
                          key: ValueKey("$title-0"),
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.mediumGrey.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // trailing chevron
                const Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AppColors.mediumGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(
    String label,
    String value,
    IconData icon, {
    Color? accent, // warna aksen ikon/glow
    EdgeInsetsGeometry? padding, // padding custom kalau butuh
  }) {
    (accent ?? Colors.white).withOpacity(0.85);

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12), // glassy di atas card primary
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          // Ikon dengan glow halus
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
            ),
            child: Icon(icon, size: 18, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Text(
                    value,
                    key: ValueKey('$label-$value'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDial extends StatelessWidget {
  final double progress; // 0..1
  final double size; // diameter
  final double stroke; // ketebalan ring
  final String targetText; // teks besar di tengah
  final String subtitle; // teks kecil di bawahnya

  const _ProgressDial({
    required this.progress,
    required this.size,
    required this.stroke,
    required this.targetText,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: clamped),
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Lukisan ring progres
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                value: value,
                stroke: stroke,
              ),
            ),
            // Konten tengah (target & subtitle)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  targetText,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value; // 0..1
  final double stroke;

  _RingPainter({required this.value, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    // Rect lingkaran untuk arc
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Start di atas (−90°)
    const startAngle = -math.pi / 2;
    final sweep = (2 * math.pi) * value;

    // 1) Inner glow tipis (isi)
    final innerFill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.04);
    canvas.drawCircle(center, radius - stroke * 0.6, innerFill);

    // 2) Ring background
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);

    // 3) Ring progres (gradient + rounded cap)
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi,
        colors: const [
          Colors.white,
          Color(0xFFFFF2CC), // mirip AppColors.cream
          Colors.white,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    if (value > 0) {
      canvas.drawArc(rect, startAngle, sweep, false, progressPaint);
    }

    // 4) Knob/ujung arc (lingkaran kecil) — tampil kalau progress > 0
    if (value > 0) {
      final endAngle = startAngle + sweep;
      final knobR = radius;
      final knobX = center.dx + knobR * math.cos(endAngle);
      final knobY = center.dy + knobR * math.sin(endAngle);

      // Shadow halus di belakang knob
      final knobShadow = Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(knobX, knobY), stroke * 0.55, knobShadow);

      // Bulatan knob
      final knob = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(knobX, knobY), stroke * 0.45, knob);

      // Titik kecil di tengah knob (aksen)
      final knobDot = Paint()..color = const Color(0xFFFFE7A4);
      canvas.drawCircle(Offset(knobX, knobY), stroke * 0.20, knobDot);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.stroke != stroke;
  }
}
