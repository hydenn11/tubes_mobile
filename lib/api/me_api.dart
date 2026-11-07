import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class meAPI {
  final String apiUrl = 'dummy_mode';

  Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'pelamar';
    String? storedName = prefs.getString('user_name');
    String? storedCompany = prefs.getString('user_nama_perusahaan');
    if (storedName == 'PT Sentosa Makmur' || storedCompany == 'PT Sentosa Makmur') {
      storedName = 'PT Astra Otoparts Tbk';
      storedCompany = 'PT Astra Otoparts Tbk';
      await prefs.setString('user_name', storedName);
      await prefs.setString('user_nama_perusahaan', storedCompany);
      await prefs.setString('user_alamat', 'Kawasan Industri GIIC Cikarang, Jawa Barat');
    }

    final email = prefs.getString('user_email') ?? (role == 'perusahaan' ? 'hrd@astra-otoparts.com' : 'rafif@gmail.com');
    final name = storedName ?? (role == 'perusahaan' ? 'PT Astra Otoparts Tbk' : 'Rafif Purnomo');
    final firstName = prefs.getString('user_first_name') ?? name.split(' ').first;
    final lastName = prefs.getString('user_last_name') ?? (name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : 'Purnomo');
    final username = prefs.getString('user_username') ?? firstName.toLowerCase();
    final namaPerusahaan = storedCompany ?? (prefs.getString('user_nama_perusahaan') ?? name);
    final alamat = prefs.getString('user_alamat') ?? 'Kawasan Industri GIIC Cikarang, Jawa Barat';
    final about = prefs.getString('user_about') ?? 'Perusahaan manufaktur terkemuka di Indonesia yang memproduksi berbagai komponen suku cadang otomotif presisi tinggi.';

    final cvPath = prefs.getString('user_curriculum_vitae');
    final cvName = prefs.getString('user_cv') ??
        (cvPath != null
            ? cvPath.split(RegExp(r'[\\/]')).last
            : null);
    final phone = prefs.getString('user_phone');
    final profilePict = prefs.getString('user_profile_pict') ?? 'assets/img/defaultPict.png';

    if (role == 'perusahaan' || role == 'hrd') {
      return {
        'status': true,
        'data': {
          'id': 1,
          'id_perusahaan': 1,
          'role': 'perusahaan',
          'nama': namaPerusahaan,
          'namaPerusahaanAsli': namaPerusahaan,
          'nama_perusahaan': namaPerusahaan,
          'username': username,
          'email': email,
          'alamat': alamat,
          'deskripsi': about,
          'about': about,
          'aboutMe': about,
          'about_me': about,
          'profile_pict': 'assets/img/logoRekanPabrik.png',
          'img': 'assets/img/logoRekanPabrik.png',
        }
      };
    } else {
      return {
        'status': true,
        'data': {
          'id': 1,
          'id_pelamar': 1,
          'role': 'pelamar',
          'nama': name,
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          'alamat': 'Jl. Industri Manufaktur No. 10, Cikarang',
          'phone': phone,
          'aboutMe': 'Operator produksi berpengalaman dengan sertifikasi K3.',
          'about_me': 'Operator produksi berpengalaman dengan sertifikasi K3.',
          'profile_pict': profilePict,
          'img': profilePict,
          'curriculum_vitae': cvPath ?? cvName,
          'cv_path': cvPath ?? cvName,
          'cv': cvName ?? cvPath,
        }
      };
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? 'dummy_token_12345';
  }
}
