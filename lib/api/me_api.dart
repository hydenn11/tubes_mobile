import 'package:shared_preferences/shared_preferences.dart';

class meAPI {
  final String apiUrl = 'dummy_mode';

  Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'pelamar';
    final email = prefs.getString('user_email') ?? (role == 'perusahaan' ? 'daffa@gmail.com' : 'rafif@gmail.com');
    final name = prefs.getString('user_name') ?? (role == 'perusahaan' ? 'PT Nusantara Sejahtera' : 'Rafif Purnomo');

    if (role == 'perusahaan' || role == 'hrd') {
      return {
        'status': true,
        'data': {
          'id': 1,
          'id_perusahaan': 1,
          'role': 'perusahaan',
          'nama': name,
          'namaPerusahaanAsli': name,
          'nama_perusahaan': name,
          'email': email,
          'alamat': 'Jl. Merdeka No. 1, Jakarta Pusat',
          'about': 'PT Nusantara Sejahtera adalah perusahaan manufaktur dan distribusi terkemuka di Indonesia.',
          'aboutMe': 'PT Nusantara Sejahtera adalah perusahaan manufaktur dan distribusi terkemuka di Indonesia.',
          'about_me': 'PT Nusantara Sejahtera adalah perusahaan manufaktur dan distribusi terkemuka di Indonesia.',
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
          'first_name': name.split(' ').first,
          'last_name': name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : 'Purnomo',
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
