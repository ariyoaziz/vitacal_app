// lib/services/profile_service.dart

import 'package:vitacal_app/models/profile_model.dart';
import 'package:vitacal_app/services/userdetail_service.dart';
import 'package:vitacal_app/exceptions/auth_exception.dart';
import 'package:vitacal_app/models/enums.dart';

class ProfileService {
  final UserDetailService _userDetailService;

  ProfileService({UserDetailService? userDetailService})
      : _userDetailService = userDetailService ?? UserDetailService();

  Future<ProfileModel> getProfileData() async {
    try {
      final Map<String, dynamic> rawResponse =
          await _userDetailService.getProfileDataRaw();

      print(
          'DEBUG PROFILE_SERVICE: Raw response from getProfileDataRaw: $rawResponse');

      if (rawResponse.containsKey('user') && rawResponse['user'] != null) {
        return ProfileModel.fromJson(rawResponse);
      } else {
        throw AuthException('Struktur data profil tidak valid dari server.');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      print('ERROR di ProfileService.getProfileData: ${e.toString()}');
      throw AuthException(
          "Terjadi kesalahan tidak terduga saat mengambil data profil: ${e.toString()}");
    }
  }

  Future<void> updateBeratBadan(double beratBadan) async {
    try {
      await _userDetailService.updateUserDetail({'berat_badan': beratBadan});
      print(
          'DEBUG PROFILE_SERVICE: Berat badan berhasil diperbarui ke $beratBadan');
    } on AuthException {
      rethrow;
    } catch (e) {
      print('ERROR di ProfileService.updateBeratBadan: ${e.toString()}');
      throw AuthException('Gagal memperbarui berat badan: ${e.toString()}');
    }
  }

  Future<void> updateTinggiBadan(double tinggiBadan) async {
    try {
      await _userDetailService.updateUserDetail({'tinggi_badan': tinggiBadan});
      print(
          'DEBUG PROFILE_SERVICE: Tinggi badan berhasil diperbarui ke $tinggiBadan');
    } on AuthException {
      rethrow;
    } catch (e) {
      print('ERROR di ProfileService.updateTinggiBadan: ${e.toString()}');
      throw AuthException('Gagal memperbarui tinggi badan: ${e.toString()}');
    }
  }

  Future<void> updateJenisKelamin(JenisKelamin jenisKelamin) async {
    try {
      await _userDetailService
          .updateUserDetail({'jenis_kelamin': jenisKelamin.toApiString()});
      print(
          'DEBUG PROFILE_SERVICE: Jenis kelamin berhasil diperbarui ke ${jenisKelamin.toApiString()}');
    } on AuthException {
      rethrow;
    } catch (e) {
      print('ERROR di ProfileService.updateJenisKelamin: ${e.toString()}');
      throw AuthException('Gagal memperbarui jenis kelamin: ${e.toString()}');
    }
  }

  Future<void> updateAktivitas(Aktivitas aktivitas) async {
    try {
      await _userDetailService
          .updateUserDetail({'aktivitas': aktivitas.toApiString()});
      print(
          'DEBUG PROFILE_SERVICE: Aktivitas berhasil diperbarui ke ${aktivitas.toApiString()}');
    } on AuthException {
      rethrow;
    } catch (e) {
      print('ERROR di ProfileService.updateAktivitas: ${e.toString()}');
      throw AuthException('Gagal memperbarui aktivitas: ${e.toString()}');
    }
  }

  Future<void> updateTujuan(Tujuan tujuan) async {
    try {
      await _userDetailService
          .updateUserDetail({'tujuan': tujuan.toApiString()});
      print(
          'DEBUG PROFILE_SERVICE: Tujuan berhasil diperbarui ke ${tujuan.toApiString()}');
    } on AuthException {
      rethrow;
    } catch (e) {
      print('ERROR di ProfileService.updateTujuan: ${e.toString()}');
      throw AuthException('Gagal memperbarui tujuan: ${e.toString()}');
    }
  }

  Future<void> deleteProfile() async {
    try {
      await _userDetailService
          .deleteUserDetail(); // Panggil metode delete di UserDetailService
      print('DEBUG PROFILE_SERVICE: Akun berhasil dihapus.');
    } on AuthException {
      rethrow; // Teruskan AuthException
    } catch (e) {
      print('ERROR di ProfileService.deleteProfile: ${e.toString()}');
      throw AuthException('Gagal menghapus akun: ${e.toString()}');
    }
  }
}
