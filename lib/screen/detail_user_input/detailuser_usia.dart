// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_berat_dan_tinggi.dart';
import 'package:vitacal_app/themes/colors.dart';

class DetailuserUsia extends StatefulWidget {
  final UserDetailFormData formData;

  const DetailuserUsia({super.key, required this.formData});

  @override
  State<DetailuserUsia> createState() => _DetailuserUsiaState();
}

class _DetailuserUsiaState extends State<DetailuserUsia> {
  final double _progressValue = 0.50;

  late int _selectedTanggal;
  late int _selectedBulanIndex;
  late int _selectedTahun;

  late FixedExtentScrollController _tanggalController;
  late FixedExtentScrollController _bulanController;
  late FixedExtentScrollController _tahunController;

  List<int> tanggalList = List.generate(31, (index) => index + 1);
  List<String> bulanList = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  List<int> tahunList =
      List.generate(101, (index) => DateTime.now().year - index);

  String? _usiaErrorMessage;

  @override
  void initState() {
    super.initState();
    DateTime? dob = widget.formData.tanggalLahir;
    if (dob != null) {
      _selectedTanggal = dob.day;
      _selectedBulanIndex = dob.month - 1;
      _selectedTahun = dob.year;
    } else {
      _selectedTanggal = 1;
      _selectedBulanIndex = 0;
      _selectedTahun = 2000;
    }

    _tanggalController = FixedExtentScrollController(
      initialItem: tanggalList.indexOf(_selectedTanggal),
    );
    _bulanController = FixedExtentScrollController(
      initialItem: _selectedBulanIndex,
    );
    _tahunController = FixedExtentScrollController(
      initialItem: tahunList.indexOf(_selectedTahun),
    );
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _bulanController.dispose();
    _tahunController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  void _onNextPressed() {
    setState(() {
      _usiaErrorMessage = null;
    });

    DateTime birthDate;
    try {
      birthDate =
          DateTime(_selectedTahun, _selectedBulanIndex + 1, _selectedTanggal);
      if (birthDate.day != _selectedTanggal ||
          birthDate.month != (_selectedBulanIndex + 1) ||
          birthDate.year != _selectedTahun) {
        throw FormatException();
      }
    } catch (e) {
      setState(() {
        _usiaErrorMessage =
            "Ups, tanggal lahirnya ada yang aneh nih. Cek kembali tanggal, bulan, dan tahun ya!";
      });
      return;
    }

    int umur = _calculateAge(birthDate);

    if (umur < 10 || umur > 100) {
      setState(() {
        _usiaErrorMessage =
            "Umurmu harus antara 10-100 tahun ya! Kami ingin VitaCal pas untukmu.";
      });
      return;
    }

    final updatedFormData = widget.formData.copyWith(
      umur: umur,
      tanggalLahir: birthDate,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailuserBeratDanTinggi(formData: updatedFormData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double itemHeight = screenHeight * 0.07;
    double pickerWidth = screenWidth * 0.28;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.65,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Berapa Usia Anda?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Kami ingin mengenal Anda lebih baik untuk menjadikan aplikasi VitaCal dipersonalisasi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Date Pickers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDatePickerColumn<int>(
                              context: context,
                              label: "Tanggal",
                              list: tanggalList,
                              controller: _tanggalController,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedTanggal = tanggalList[index];
                                  _usiaErrorMessage = null;
                                });
                              },
                              itemHeight: itemHeight,
                              pickerWidth: pickerWidth,
                            ),
                            _buildDatePickerColumn<String>(
                              context: context,
                              label: "Bulan",
                              list: bulanList,
                              controller: _bulanController,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedBulanIndex = index;
                                  _usiaErrorMessage = null;
                                });
                              },
                              itemHeight: itemHeight,
                              pickerWidth: pickerWidth,
                            ),
                            _buildDatePickerColumn<int>(
                              context: context,
                              label: "Tahun",
                              list: tahunList,
                              controller: _tahunController,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedTahun = tahunList[index];
                                  _usiaErrorMessage = null;
                                });
                              },
                              itemHeight: itemHeight,
                              pickerWidth: pickerWidth,
                            ),
                          ],
                        ),

                        if (_usiaErrorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              _usiaErrorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.greenGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Lanjut",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerColumn<T>({
    required BuildContext context,
    required String label,
    required List<T> list,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onSelectedItemChanged,
    required double itemHeight,
    required double pickerWidth,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: pickerWidth,
          height: itemHeight * 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.screen,
            // PERBAIKAN: Menghilangkan border di sini
            // border: Border.all(color: AppColors.mediumGrey.withOpacity(0.5), width: 1),
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: itemHeight,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index >= list.length) {
                  return null;
                }
                final item = list[index];
                final bool isSelected;
                if (T == String) {
                  isSelected = (index == _selectedBulanIndex);
                } else {
                  isSelected =
                      (item == _selectedTanggal || item == _selectedTahun);
                }

                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: isSelected ? pickerWidth * 0.9 : pickerWidth * 0.8,
                    height: isSelected ? itemHeight * 0.9 : itemHeight * 0.8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      style: TextStyle(
                        fontSize: isSelected ? 18 : 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppColors.primary : AppColors.darkGrey,
                      ),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Text(
                        item.toString(),
                      ),
                    ),
                  ),
                );
              },
              childCount: list.length,
            ),
          ),
        ),
      ],
    );
  }
}
