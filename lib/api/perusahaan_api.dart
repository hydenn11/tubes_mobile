import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekanpabrik/dummy/dummy_perusahaan.dart';

class PerusahaanAPI {
  final String apiUrl = 'dummy_mode';

  List<Map<String, dynamic>> _formatPerusahaanList() {
    return dummyPerusahaan.map((item) {
      final id = item['id'] ?? 1;
      final nama = item['namaPerusahaanAsli'] ?? item['nama'] ?? 'Perusahaan';
      final emailName = (item['nama'] ?? 'perusahaan')
          .toString()
          .toLowerCase()
          .replaceAll(' ', '');
      return {
        'id_perusahaan': id,
        'id': id,
        'nama_perusahaan': nama,
        'nama': item['nama'] ?? nama,
        'namaPerusahaanAsli': nama,
        'email': '$emailName@rekanpabrik.com',
        'about_me': item['about'] ?? 'Perusahaan terkemuka di Indonesia.',
        'about': item['about'] ?? 'Perusahaan terkemuka di Indonesia.',
        'profile_pict': item['img'] ?? 'assets/img/logoRekanPabrik.png',
        'img': item['img'] ?? 'assets/img/logoRekanPabrik.png',
        'alamat': item['alamat'] ?? 'Indonesia',
        'jumlah_posting': item['jumlahLowongan'] ?? 5,
        'jumlahLowongan': item['jumlahLowongan'] ?? 5,
      };
    }).toList();
  }

  Future<bool> updateProfilePicture({
    required int idperusahaan,
    required File imagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Future<bool> updateProfileData({
    required int idperusahaan,
    required String email,
    required String namaPerusahaan,
    required String tentangPerusahaan,
    required String alamatPerusahaan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', namaPerusahaan);
    await prefs.setString('user_email', email);
    return true;
  }

  Future<bool> changePassword({
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Future<List<Map<String, dynamic>>> getAllPerusahaan() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _formatPerusahaanList();
  }

  Future<List<Map<String, dynamic>>> getPerusahaanByIDPerusahaan(
      int idperusahaan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _formatPerusahaanList();
    final filtered = list.where((p) => p['id_perusahaan'] == idperusahaan).toList();
    if (filtered.isNotEmpty) {
      return filtered;
    }
    return list.take(1).toList();
  }

  Future<bool> createAccount(
      String email, String password, String namaPerusahaan) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', 'perusahaan');
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', namaPerusahaan);
    return true;
  }
}
