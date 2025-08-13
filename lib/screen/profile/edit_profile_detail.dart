// lib/screen/profile/edit_profile_detail.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitacal_app/themes/colors.dart';

// Blocs & events
import 'package:vitacal_app/blocs/user_detail/userdetail_bloc.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_event.dart';
import 'package:vitacal_app/blocs/user_detail/userdetail_state.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_bloc.dart';
import 'package:vitacal_app/blocs/riwayat_user/riwayat_user_event.dart';
import 'package:vitacal_app/blocs/profile/profile_bloc.dart';
import 'package:vitacal_app/blocs/profile/profile_event.dart';

class EditProfileDetailPage extends StatefulWidget {
  final String initialNama;
  final int initialUmur;

  const EditProfileDetailPage({
    super.key,
    required this.initialNama,
    required this.initialUmur,
  });

  @override
  State<EditProfileDetailPage> createState() => _EditProfileDetailPageState();
}

class _EditProfileDetailPageState extends State<EditProfileDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaC;
  late final TextEditingController _umurC;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.initialNama);
    _umurC = TextEditingController(text: widget.initialUmur.toString());
  }

  @override
  void dispose() {
    _namaC.dispose();
    _umurC.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final nama = _namaC.text.trim();
    final umur = int.tryParse(_umurC.text.trim()) ?? 0;

    setState(() => _saving = true);

    // Kirim ke UserDetailBloc
    context.read<UserDetailBloc>().add(UpdateUserDetail(
          updates: {
            'nama': nama,
            'umur': umur,
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserDetailBloc, UserDetailState>(
      listener: (context, state) {
        if (state is UserDetailUpdateSuccess) {
          // Segarkan halaman lain biar langsung konsisten
          context.read<ProfileBloc>().add(const LoadProfileData());
          context.read<RiwayatUserBloc>().add(const LoadRiwayat(days: 7));

          if (mounted) {
            setState(() => _saving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Detail akun berhasil diperbarui')),
            );
            Navigator.pop(context); // kembali ke Profile
          }
        } else if (state is UserDetailError) {
          if (mounted) {
            setState(() => _saving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memperbarui: ${state.message}')),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ubah Detail Akun'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                color: AppColors.screen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _namaC,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            if (v.trim().length < 2) {
                              return 'Nama terlalu pendek';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _umurC,
                          decoration: const InputDecoration(
                            labelText: 'Umur',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null) return 'Umur harus angka';
                            if (n < 10 || n > 100) {
                              return 'Umur harus 10–100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _submit,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_saving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.08),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
