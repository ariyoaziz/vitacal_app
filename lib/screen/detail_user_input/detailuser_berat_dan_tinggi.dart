import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/detail_user_input/detailuser_aktivitas.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/models/user_detail_form_data.dart';

class DetailuserBeratDanTinggi extends StatefulWidget {
  final UserDetailFormData formData;

  const DetailuserBeratDanTinggi({super.key, required this.formData});

  @override
  State<DetailuserBeratDanTinggi> createState() =>
      _DetailuserBeratDanTinggiState();
}

class _DetailuserBeratDanTinggiState extends State<DetailuserBeratDanTinggi> {
  final double _progressValue = 0.67;

  late double _beratBadan;
  late double _tinggiBadan;

  late FixedExtentScrollController _beratBadanController;
  late FixedExtentScrollController _tinggiBadanController;

  List<int> beratBadanList =
      List.generate(141, (index) => 10 + index); // 10 kg - 150 kg
  List<int> tinggiBadanList =
      List.generate(201, (index) => 50 + index); // 50 cm - 250 cm

  @override
  void initState() {
    super.initState();
    _beratBadan = widget.formData.beratBadan ?? 60.0;
    _tinggiBadan = widget.formData.tinggiBadan ?? 160.0;

    int initialBeratIndex = beratBadanList.indexOf(_beratBadan.toInt());
    int initialTinggiIndex = tinggiBadanList.indexOf(_tinggiBadan.toInt());

    _beratBadanController = FixedExtentScrollController(
      initialItem: initialBeratIndex != -1 ? initialBeratIndex : (60 - 10),
    );
    _tinggiBadanController = FixedExtentScrollController(
      initialItem: initialTinggiIndex != -1 ? initialTinggiIndex : (160 - 50),
    );
  }

  @override
  void dispose() {
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    final updatedFormData = widget.formData.copyWith(
      beratBadan: _beratBadan,
      tinggiBadan: _tinggiBadan,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailuserAktivitas(formData: updatedFormData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double itemHeight = screenHeight * 0.08;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Ink(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.73,
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
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
                          "Berapa Berat dan Tinggi Badanmu?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 11),
                        const Text(
                          "Kami ingin mengenal Anda lebih baik untuk menjadikan aplikasi VitaCal dipersonalisasi.",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 33),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildWeightHeightPicker(
                              context: context,
                              label: "Berat Badan",
                              unit: "kg",
                              value: _beratBadan,
                              list: beratBadanList,
                              controller: _beratBadanController,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _beratBadan =
                                      beratBadanList[index].toDouble();
                                });
                              },
                              itemHeight: itemHeight,
                              itemWidth: screenWidth * 0.35,
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            _buildWeightHeightPicker(
                              context: context,
                              label: "Tinggi Badan",
                              unit: "cm",
                              value: _tinggiBadan,
                              list: tinggiBadanList,
                              controller: _tinggiBadanController,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _tinggiBadan =
                                      tinggiBadanList[index].toDouble();
                                });
                              },
                              itemHeight: itemHeight,
                              itemWidth: screenWidth * 0.35,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: screenWidth * 0.85,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.greenGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Lanjut",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  // Helper untuk membangun ListWheelScrollView (Picker)
  Widget _buildWeightHeightPicker({
    required BuildContext context,
    required String label,
    required String unit,
    required double value,
    required List<int> list,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onSelectedItemChanged,
    required double itemHeight,
    required double itemWidth,
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
        const SizedBox(height: 21),
        Container(
          width: itemWidth,
          height: itemHeight * 3, // Tinggi yang menampilkan 3 item
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21), // Sudut membulat

            color: AppColors.screen, // Latar belakang picker yang bersih
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
                // Item yang dipilih adalah item yang sama dengan nilai state
                final bool isSelected = item == value.toInt();

                return Center(
                  child: AnimatedContainer(
                    // Menggunakan AnimatedContainer untuk transisi background
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: isSelected ? itemWidth * 0.8 : itemWidth * 0.7,
                    height: isSelected ? itemHeight * 0.8 : itemHeight * 0.7,
                    decoration: BoxDecoration(
                      color: isSelected
                          // ignore: deprecated_member_use
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent, // Highlight background samar
                      borderRadius: BorderRadius.circular(
                          10), // Sudut bulat untuk highlight
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null, // Border saat dipilih
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      // Untuk animasi perubahan teks
                      style: TextStyle(
                        fontSize: isSelected ? 21 : 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppColors.primary : AppColors.darkGrey,
                      ),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Text(
                        '$item $unit', // Tampilkan nilai dan unit (misal "60 kg")
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
