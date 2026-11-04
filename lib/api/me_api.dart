import 'package:shared_preferences/shared_preferences.dart';

class meAPI {
  final String apiUrl = 'dummy_mode';

  Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'pelamar';
    final email = prefs.getString('user_email') ?? (role == 'perusahaan' ? 'daffa@gmail.com' : 'rafif@gmail.com');
    final name = prefs.getString('user_name') ?? (role == 'perusahaan' ? 'PT Sentosa Makmur' : 'Rafif Purnomo');
    final firstName = prefs.getString('user_first_name') ?? name.split(' ').first;
    final lastName = prefs.getString('user_last_name') ?? (name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : 'Purnomo');
    final username = prefs.getString('user_username') ?? firstName.toLowerCase();
    final namaPerusahaan = prefs.getString('user_nama_perusahaan') ?? name;
    final alamat = prefs.getString('user_alamat') ?? 'Kawasan Industri MM2100 Blok C-4, Cikarang Barat';
    final about = prefs.getString('user_about') ?? '$namaPerusahaan adalah perusahaan manufaktur komponen presisi dan perakitan mekanikal terkemuka di Indonesia.';

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
          'phone': '081234567890',
          'aboutMe': 'Operator produksi berpengalaman dengan sertifikasi K3.',
          'about_me': 'Operator produksi berpengalaman dengan sertifikasi K3.',
          'profile_pict': 'assets/img/defaultPict.png',
          'img': 'assets/img/defaultPict.png',
          'cv': 'CV_Rafif_Purnomo.pdf',
        }
      };
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? 'dummy_token_12345';
  }
}
