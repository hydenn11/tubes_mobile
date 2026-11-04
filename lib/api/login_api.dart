import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekanpabrik/dummy/dummy_account.dart';

class LoginAPI {
  final String apiUrl = 'dummy_mode';

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulasi delay

    final cleanInput = email.trim().toLowerCase();
    
    // Cari di data dummy_account berdasarkan email atau username DAN kecocokan password
    final match = dummyAccounts.firstWhere(
      (acc) =>
          ((acc['email']?.toString().toLowerCase() == cleanInput) ||
           (acc['username']?.toString().toLowerCase() == cleanInput)) &&
          acc['password'] == password,
      orElse: () => {},
    );

    if (match.isEmpty) {
      return {
        'status': false,
        'message': 'Email/Username atau kata sandi tidak sesuai',
      };
    }

    String role = match['role']?.toString().toLowerCase() == 'hrd' ? 'perusahaan' : 'pelamar';
    String finalEmail = match['email'] ?? (email.contains('@') ? email : '$cleanInput@gmail.com');
    String fullName = (match['nama_perusahaan'] ?? match['name'] ?? "${match['first_name'] ?? ''} ${match['last_name'] ?? ''}").toString().trim();
    String firstName = match['first_name'] ?? fullName.split(' ').first;
    String lastName = match['last_name'] ?? (fullName.split(' ').length > 1 ? fullName.split(' ').sublist(1).join(' ') : '');
    String username = match['username'] ?? cleanInput;
    String? namaPerusahaan = match['nama_perusahaan'] ?? (role == 'perusahaan' ? fullName : null);
    String? alamat = match['alamat'];
    String? about = match['about'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'dummy_token_12345');
    await prefs.setString('user_role', role);
    await prefs.setString('user_email', finalEmail);
    await prefs.setString('user_name', fullName);
    await prefs.setString('user_first_name', firstName);
    await prefs.setString('user_last_name', lastName);
    await prefs.setString('user_username', username);
    if (namaPerusahaan != null) {
      await prefs.setString('user_nama_perusahaan', namaPerusahaan);
    }
    if (alamat != null) {
      await prefs.setString('user_alamat', alamat);
    }
    if (about != null) {
      await prefs.setString('user_about', about);
    }

    return {
      'status': true,
      'token': 'dummy_token_12345',
      'message': 'Login berhasil (Mode Frontend)',
    };
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? 'dummy_token_12345';
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_first_name');
    await prefs.remove('user_last_name');
    await prefs.remove('user_username');
    await prefs.remove('user_nama_perusahaan');
    await prefs.remove('user_alamat');
    await prefs.remove('user_about');
    return true;
  }
}
