// lib/screen/search/search.dart

// ignore_for_file: unused_element, deprecated_member_use, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/screen/widgets/dialog.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String selectedCategory = 'Makan Pagi';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'Makan Pagi',
    'Makan Siang',
    'Makan Malam',
    'Cemilan',
  ];

  final List<String> allItems = [
    'Nasi Goreng',
    'Roti Bakar',
    'Sereal',
    'Ayam Bakar',
    'Salad',
    'Kentang Goreng',
    'Sate Ayam',
    'Bakso',
    'Mie Ayam',
    'Bubur Ayam',
    'Telur Dadar',
    'Sup Ayam',
    'Gado-gado',
    'Nasi Uduk',
    'Pecel Lele',
    'Martabak',
    'Pisang Goreng',
    'Kerupuk',
    'Tempe Mendoan',
    'Es Krim',
    'Cokelat',
    'Kue',
    'Buah-buahan',
    'Yogurt',
    'Susu',
    'Kopi',
    'Teh',
    'Air Putih',
  ];

  final Map<String, List<String>> selectedItemsByCategory = {
    'Makan Pagi': [],
    'Makan Siang': [],
    'Makan Malam': [],
    'Cemilan': [],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> getFilteredItems() {
    if (searchQuery.isEmpty) return [];

    List<String> currentSelectedItems =
        selectedItemsByCategory[selectedCategory] ?? [];

    return allItems
        .where((item) =>
            item.toLowerCase().contains(searchQuery.toLowerCase()) &&
            !currentSelectedItems.contains(item))
        .toList();
  }

  List<String> getSelectedItemsForCategory() {
    return selectedItemsByCategory[selectedCategory] ?? [];
  }

  void saveSelectedItem(String item) {
    setState(() {
      selectedItemsByCategory.putIfAbsent(selectedCategory, () => []);
      selectedItemsByCategory[selectedCategory]!.add(item);
      _searchController.clear();
      searchQuery = '';
    });
  }

  void removeSelectedItem(String item) {
    setState(() {
      selectedItemsByCategory[selectedCategory]?.remove(item);
    });
  }

  bool get hasItemsToSave {
    return getSelectedItemsForCategory().isNotEmpty;
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi refresh
    setState(() {
      // Logic for data refresh if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      // Menggunakan Stack untuk membuat background hijau lebih panjang
      body: Stack(
        children: [
          // Background hijau yang lebih panjang
          Container(
            height: 220, // Ketinggian background hijau (bisa disesuaikan)
            decoration: const BoxDecoration(
              gradient: AppColors.greenGradient,
            ),
          ),
          RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primary,
            backgroundColor: AppColors.screen,
            strokeWidth: 3,
            displacement: 60,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar atau Header di dalam SingleChildScrollView agar bisa scroll bersama
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text(
                      'Cari Makanan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  const SizedBox(height: 30), // Spasi setelah header

                  // Search bar - shadow dikurangi
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.screen,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05), // Shadow lebih tipis
                          blurRadius: 5, // Blur lebih sedikit
                          offset: const Offset(0, 2), // Offset lebih kecil
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.darkGrey),
                      decoration: InputDecoration(
                        hintText: 'Cari makanan...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search,
                            size: 24,
                            color: AppColors.darkGrey.withOpacity(0.7)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),

                  const SizedBox(height: 33), // Spasi setelah search bar

                  // Kategori scroll horizontal
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: EdgeInsets.only(
                                right: index == categories.length - 1 ? 0 : 10),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCategory = category;
                                    _searchController.clear();
                                    searchQuery = '';
                                  });
                                }
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.screen,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.darkGrey,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.darkGrey.withOpacity(0.4),
                                  width: 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Hasil pencarian
                  if (getFilteredItems().isNotEmpty) ...[
                    const Text(
                      "Hasil Pencarian",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: getFilteredItems().length,
                      itemBuilder: (context, index) {
                        final item = getFilteredItems()[index];
                        return Card(
                          color: AppColors.screen,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.fastfood,
                                  color: AppColors.primary, size: 24),
                            ),
                            title: Text(item,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGrey,
                                    fontSize: 16)),
                            subtitle: Text("Kategori: $selectedCategory",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13)),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.primary, size: 30),
                              onPressed: () {
                                saveSelectedItem(item);
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Item yang sudah ditambahkan dalam kategori ini
                  if (getSelectedItemsForCategory().isNotEmpty) ...[
                    Text(
                      "Item ${selectedCategory} Anda",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: getSelectedItemsForCategory().length,
                      itemBuilder: (context, index) {
                        final item = getSelectedItemsForCategory()[index];
                        return Card(
                          color: AppColors.screen,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.check_circle_outline,
                                  color: Colors.green[700], size: 24),
                            ),
                            title: Text(item,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGrey,
                                    fontSize: 16)),
                            subtitle: Text("Kategori: $selectedCategory",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red, size: 30),
                              onPressed: () {
                                removeSelectedItem(item);
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Tombol simpan muncul jika ada item yang dipilih
                  if (hasItemsToSave)
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.greenGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print("Items saved: $selectedItemsByCategory");
                            CustomDialog.show(
                              context,
                              title: 'Makanan Disimpan!',
                              message:
                                  'Makanan berhasil disimpan ke dalam daftar.',
                              type: DialogType.success,
                              autoDismiss: true,
                              dismissDuration: const Duration(seconds: 2),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text(
                            "Simpan Makanan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
