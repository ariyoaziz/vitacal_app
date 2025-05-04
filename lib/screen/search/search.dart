import 'package:flutter/material.dart';
import 'package:vitacal_app/themes/colors.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String selectedCategory = 'Makan Pagi';
  String searchQuery = '';

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
  ];

  final Map<String, List<String>> selectedItemsByCategory = {};

  List<String> getFilteredItems() {
    if (searchQuery.isEmpty) return [];

    List<String> selectedItems =
        selectedItemsByCategory[selectedCategory] ?? [];

    return allItems
        .where((item) =>
            item.toLowerCase().contains(searchQuery.toLowerCase()) &&
            !selectedItems.contains(item))
        .toList();
  }

  List<String> getSelectedItemsForCategory() {
    return selectedItemsByCategory[selectedCategory] ?? [];
  }

  void saveSelectedItem(String item) {
    setState(() {
      selectedItemsByCategory.putIfAbsent(selectedCategory, () => []);
      selectedItemsByCategory[selectedCategory]!.add(item);
      searchQuery = ''; // Reset search query after item is added
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
                const Center(
                  child: Text(
                    'Cari',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 11),

            // Kategori scroll horizontal
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: categories.map((category) {
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              isSelected ? AppColors.primary : Colors.grey[200],
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 11),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                alignment:
                    Alignment.center, // pastikan isi berada di tengah container
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: const TextStyle(fontSize: 16),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    isCollapsed:
                        true, // kunci: supaya padding tidak terlalu tinggi
                    hintText: 'Cari makanan...',
                    prefixIcon: Icon(Icons.search, size: 21),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),

            // Hasil pencarian
            if (getFilteredItems().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Hasil Pencarian",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ...getFilteredItems().map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: AppColors.screen,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood),
                      title: Text(item),
                      subtitle: Text("Kategori: $selectedCategory"),
                      trailing: const Icon(Icons.add),
                      onTap: () {
                        saveSelectedItem(item); // Simpan item yang dipilih
                      },
                    ),
                  ),
                );
                // ignore: unnecessary_to_list_in_spreads
              }).toList(),
            ],

            // Item yang sudah ditambahkan dalam kategori ini
            if (getSelectedItemsForCategory().isNotEmpty) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  "Item dalam $selectedCategory",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...getSelectedItemsForCategory().map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: AppColors.screen,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(item),
                      subtitle: Text("Kategori: $selectedCategory"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removeSelectedItem(item); // Hapus item yang dipilih
                        },
                      ),
                    ),
                  ),
                );
                // ignore: unnecessary_to_list_in_spreads
              }).toList(),
            ],
            SizedBox(height: 50),

            // Tombol simpan muncul jika ada item yang dipilih
            if (hasItemsToSave) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient, // Menambahkan gradient
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Aksi simpan yang mungkin diperlukan
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.screen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Makanan Disimpan!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 11),
                                    const Text(
                                      'Makanan berhasil disimpan ke dalam daftar.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.darkGrey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),

                                    // Tombol OK dengan background gradient
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ).copyWith(
                                          // Menambahkan background gradient ke dalam Ink
                                          // ignore: deprecated_member_use
                                          backgroundColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            // ignore: deprecated_member_use
                                            (Set<MaterialState> states) => null,
                                          ),
                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: AppColors.greenGradient,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: const Text(
                                              "OK",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // Agar background transparan
                        shadowColor: Colors.transparent, // Menghilangkan shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Padding vertikal
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          color: Colors
                              .white, // Warna teks agar tetap terlihat jelas
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
