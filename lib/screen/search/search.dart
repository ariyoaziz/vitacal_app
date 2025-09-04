// lib/screen/search/search.dart
// ignore_for_file: unused_element, deprecated_member_use, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vitacal_app/themes/colors.dart';
import 'package:vitacal_app/screen/widgets/dialog.dart';

// BLoC & model makanan
import 'package:vitacal_app/blocs/makanan/makanan_bloc.dart';
import 'package:vitacal_app/blocs/makanan/makanan_event.dart';
import 'package:vitacal_app/blocs/makanan/makanan_state.dart';
import 'package:vitacal_app/models/makanan_item.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String selectedCategory = 'Makan Pagi';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // controller untuk semua ListView (biar load-more bisa jalan konsisten)
  final ScrollController _listCtrl = ScrollController();
  bool _isPaging = false; // cegah trigger load-more ganda

  final List<String> categories = const [
    'Makan Pagi',
    'Makan Siang',
    'Makan Malam',
    'Cemilan',
  ];

  // Simpan pilihan per kategori (pakai model dari backend)
  final Map<String, List<MakananItem>> selectedItemsByCategory = {
    'Makan Pagi': [],
    'Makan Siang': [],
    'Makan Malam': [],
    'Cemilan': [],
  };

  @override
  void initState() {
    super.initState();

    // load rekomendasi/initial list dari backend
    context.read<MakananBloc>().add(const MakananFetchAll(limit: 50, page: 1));

    // listener untuk auto load-more saat mendekati bottom (hanya non-search & saat BELUM ada item dipilih)
    _listCtrl.addListener(() {
      final bloc = context.read<MakananBloc>();
      if (bloc.isSearching) return; // jangan load-more saat search
      // jika sudah ada item dipilih → jangan load-more (rekomendasi disembunyikan)
      if ((selectedItemsByCategory[selectedCategory] ?? []).isNotEmpty) return;

      if (_listCtrl.position.pixels >=
              _listCtrl.position.maxScrollExtent - 200 &&
          !_isPaging) {
        final st = bloc.state;
        if (st is MakananListLoaded && st.hasMore) {
          _isPaging = true;
          bloc.add(const MakananLoadMore());
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  List<MakananItem> _selectedItems() =>
      selectedItemsByCategory[selectedCategory] ?? [];

  void _addItem(MakananItem item) {
    final list =
        selectedItemsByCategory.putIfAbsent(selectedCategory, () => []);
    if (!list.any((x) => x.id == item.id)) {
      setState(() => list.add(item));
    }
    // Setelah pilih makanan -> sembunyikan hasil pencarian
    _searchController.clear();
    searchQuery = '';
    context.read<MakananBloc>().add(const MakananClearSearch());
    FocusScope.of(context).unfocus();
  }

  void _removeItem(MakananItem item) {
    setState(() {
      selectedItemsByCategory[selectedCategory]
          ?.removeWhere((x) => x.id == item.id);
    });
  }

  bool get _hasItemsToSave => _selectedItems().isNotEmpty;

  Future<void> _refreshList() async {
    // Bersihkan search & reload rekomendasi
    _searchController.clear();
    searchQuery = '';
    context.read<MakananBloc>().add(const MakananClearSearch());
    context
        .read<MakananBloc>()
        .add(const MakananFetchAll(limit: 50, page: 1, refresh: true));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: Column(
        children: [
          // ================= HEADER (tetap, tidak ikut scroll)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: paddingTop) +
                const EdgeInsets.fromLTRB(20, 12, 20, 14),
            decoration: const BoxDecoration(gradient: AppColors.greenGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Cari Makanan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.screen,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                      context
                          .read<MakananBloc>()
                          .add(MakananSearchQueryChanged(value));
                    },
                    style: const TextStyle(
                        fontSize: 16, color: AppColors.darkGrey),
                    decoration: InputDecoration(
                      hintText: 'Cari makanan...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search,
                          size: 24, color: AppColors.darkGrey.withOpacity(0.7)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      isDense: true,
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.mediumGrey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  searchQuery = '';
                                });
                                context
                                    .read<MakananBloc>()
                                    .add(const MakananClearSearch());
                              },
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.search,
                  ),
                ),

                const SizedBox(height: 14),

                // Chips kategori
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedCategory = category;
                              _searchController.clear();
                              searchQuery = '';
                            });
                            context
                                .read<MakananBloc>()
                                .add(const MakananClearSearch());
                            // scroll ke atas biar UX enak
                            _listCtrl.animateTo(0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut);
                          }
                        },
                        selectedColor: AppColors.lightPrimary,
                        backgroundColor: AppColors.screen,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkGrey,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ================= LIST AREA (scrollable)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              color: AppColors.primary,
              backgroundColor: AppColors.screen,
              strokeWidth: 3,
              displacement: 60,
              child: BlocListener<MakananBloc, MakananState>(
                listener: (context, state) {
                  // reset flag paging ketika sudah dapat state baru
                  if (state is MakananListLoaded ||
                      state is MakananError ||
                      state is MakananEmpty) {
                    _isPaging = false;
                  }
                },
                child: BlocBuilder<MakananBloc, MakananState>(
                  builder: (context, state) {
                    final bloc = context.read<MakananBloc>();
                    final isSearching = bloc.isSearching;
                    final List<MakananItem> selected = _selectedItems();

                    // utility: filter rekomendasi agar tidak duplikat dengan yang dipilih
                    List<MakananItem> _excludeSelected(List<MakananItem> src) {
                      final pickedIds = selected.map((e) => e.id).toSet();
                      return src
                          .where((e) => !pickedIds.contains(e.id))
                          .toList();
                    }

                    if (isSearching) {
                      // === MODE PENCARIAN ===
                      if (state is MakananSearchLoading) {
                        return ListView(
                          controller: _listCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                          children: const [
                            _SectionTitle('Hasil Pencarian'),
                            SizedBox(height: 16),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      if (state is MakananSearchLoaded) {
                        final results = _excludeSelected(state.items);
                        if (results.isEmpty) {
                          return ListView(
                            controller: _listCtrl,
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                            children: [
                              const _SectionTitle('Hasil Pencarian'),
                              const SizedBox(height: 12),
                              _emptyState(
                                icon: Icons.search_off_rounded,
                                title: 'Tidak ada hasil',
                                subtitle:
                                    'Coba kata kunci lain atau periksa ejaannya.',
                              ),
                            ],
                          );
                        }
                        return ListView.builder(
                          controller: _listCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                          itemCount: results.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: _SectionTitle('Hasil Pencarian'),
                              );
                            }
                            final item = results[index - 1];
                            return _resultItem(item,
                                onTap: () => _addItem(item));
                          },
                        );
                      }
                      if (state is MakananError) {
                        return ListView(
                          controller: _listCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                          children: [
                            const _SectionTitle('Hasil Pencarian'),
                            const SizedBox(height: 12),
                            _emptyState(
                              icon: Icons.error_outline_rounded,
                              title: 'Gagal memuat',
                              subtitle: state.message,
                            ),
                          ],
                        );
                      }
                      // fallback saat searching tetapi belum ada state -> loader ringan
                      return ListView(
                        controller: _listCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        children: const [
                          _SectionTitle('Hasil Pencarian'),
                          SizedBox(height: 16),
                          Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }

                    // === MODE REKOMENDASI / LIST AWAL ===
                    if (state is MakananLoading || state is MakananInitial) {
                      // belum ada pilihan -> tampilkan startCard + loader
                      if (selected.isEmpty) {
                        return ListView(
                          controller: _listCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                          children: [
                            _startCard(),
                            const SizedBox(height: 20),
                            const _SectionTitle('Rekomendasi'),
                            const SizedBox(height: 16),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      // sudah ada pilihan -> tampilkan HANYA pilihan (rekomendasi disembunyikan)
                      return ListView(
                        controller: _listCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                        children: [
                          _SectionTitle('Item $selectedCategory Kamu'),
                          const SizedBox(height: 12),
                          ...selected.map(
                            (e) =>
                                _selectedItem(e, onTap: () => _removeItem(e)),
                          ),
                        ],
                      );
                    }

                    if (state is MakananListLoaded) {
                      // jika BELUM ada item dipilih → tampilkan rekomendasi
                      if (selected.isEmpty) {
                        final recommended =
                            _excludeSelected(state.items).take(8).toList();
                        return ListView(
                          controller: _listCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                          children: [
                            _startCard(),
                            const SizedBox(height: 20),
                            const _SectionTitle('Rekomendasi'),
                            const SizedBox(height: 12),
                            ...recommended.map(
                              (e) => _resultItem(e, onTap: () => _addItem(e)),
                            ),
                          ],
                        );
                      }

                      // SUDAH ada item dipilih → HANYA tampilkan daftar pilihan (tanpa rekomendasi)
                      return ListView(
                        controller: _listCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                        children: [
                          _SectionTitle('Item $selectedCategory Kamu'),
                          const SizedBox(height: 12),
                          ...selected.map(
                            (e) =>
                                _selectedItem(e, onTap: () => _removeItem(e)),
                          ),
                        ],
                      );
                    }

                    if (state is MakananEmpty) {
                      // tidak ada data awal dari backend
                      if (selected.isNotEmpty) {
                        // sudah ada pilihan → tampilkan HANYA pilihan
                        return ListView(
                          controller: _listCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                          children: [
                            _SectionTitle('Item $selectedCategory Kamu'),
                            const SizedBox(height: 12),
                            ...selected.map(
                              (e) =>
                                  _selectedItem(e, onTap: () => _removeItem(e)),
                            ),
                          ],
                        );
                      }
                      // belum ada pilihan → tampilkan kosong + info
                      return ListView(
                        controller: _listCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                        children: const [
                          _SectionTitle('Rekomendasi'),
                          SizedBox(height: 12),
                          _EmptyBox(),
                        ],
                      );
                    }

                    if (state is MakananError) {
                      if (selected.isNotEmpty) {
                        // sudah ada pilihan → tetap hanya tampilkan pilihan
                        return ListView(
                          controller: _listCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                          children: [
                            _SectionTitle('Item $selectedCategory Kamu'),
                            const SizedBox(height: 12),
                            ...selected.map(
                              (e) =>
                                  _selectedItem(e, onTap: () => _removeItem(e)),
                            ),
                          ],
                        );
                      }
                      // belum ada pilihan → tampilkan error di area rekomendasi
                      return ListView(
                        controller: _listCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                        children: [
                          const _SectionTitle('Rekomendasi'),
                          const SizedBox(height: 12),
                          _emptyState(
                            icon: Icons.error_outline_rounded,
                            title: 'Gagal memuat',
                            subtitle: state.message,
                          ),
                        ],
                      );
                    }

                    // fallback
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

          // ================= BOTTOM ACTIONS (Simpan & Edit)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: _hasItemsToSave ? 76 : 0,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            color: AppColors.screen,
            child: _hasItemsToSave
                ? Row(
                    children: [
                      Expanded(
                        child: _outlinedButton(
                          label: 'Edit',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditNutritionPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _saveButton(
                          onPressed: () {
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
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  static Widget _startCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.screen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mulai cari makanan untuk ditambahkan ke daftar kamu.',
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedButton(
      {required String label, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withOpacity(.6), width: 1.2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _saveButton({required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          "Simpan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  static Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 46, color: AppColors.darkGrey.withOpacity(.35)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey.withOpacity(.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _kcalPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }

  // Kartu hasil pencarian / rekomendasi (tap di mana saja = tambah)
  Widget _resultItem(MakananItem item, {required VoidCallback onTap}) {
    return Card(
      color: AppColors.screen,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // icon kiri
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fastfood,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),

              // judul + chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // judul + kcal
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGrey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _kcalPill('${item.energiKal.toStringAsFixed(0)} Kkal'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _categoryChip(selectedCategory),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // tombol add (opsional)
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary, size: 28),
                splashRadius: 22,
                tooltip: 'Tambah',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kartu item terpilih (tap di mana saja = hapus)
  Widget _selectedItem(MakananItem item, {required VoidCallback onTap}) {
    return Card(
      color: AppColors.screen,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // icon kiri
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle_outline,
                    color: Colors.green[700], size: 22),
              ),
              const SizedBox(width: 12),

              // judul + chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // judul + kcal
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGrey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _kcalPill('${item.energiKal.toStringAsFixed(0)} Kkal'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _categoryChip(selectedCategory),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // tombol remove (opsional)
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red, size: 28),
                splashRadius: 22,
                tooltip: 'Hapus dari daftar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Title section kecil (biar rapi & konsisten)
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.darkGrey,
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    return _SearchState._emptyState(
      icon: Icons.inbox_outlined,
      title: 'Belum ada data',
      subtitle: 'Coba tarik untuk memuat ulang.',
    );
  }
}

// ============== Halaman Edit Nutrisi (kosong dulu) ==============
class EditNutritionPage extends StatelessWidget {
  const EditNutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      appBar: AppBar(
        title: const Text('Edit Nutrisi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Halaman Edit Nutrisi (coming soon)',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
