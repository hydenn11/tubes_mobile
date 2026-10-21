import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekanpabrik/dummy/dummy_account.dart';

class LoginAPI {
  final String apiUrl = 'dummy_mode';

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulasi delay

    final cleanEmail = email.trim().toLowerCase();
    
    // Cari di data dummy_account
    final match = dummyAccounts.firstWhere(
      (acc) =>
          acc['email']?.toString().toLowerCase() == cleanEmail &&
          acc['password'] == password,
      orElse: () => {},
    );

    String role = 'pelamar';
    String finalEmail = email;
    String name = 'Rafif Purnomo';

    if (match.isNotEmpty) {
      role = match['role']?.toString().toLowerCase() == 'hrd' ? 'perusahaan' : 'pelamar';
      finalEmail = match['email'] ?? email;
      name = "${match['firstName'] ?? ''} ${match['lastName'] ?? ''}".trim();
    } else {
      // Fallback ramah pengguna: jika input mengandung kata 'hrd' -> perusahaan, selain itu pelamar
      if (cleanEmail.contains('hrd') || cleanEmail.contains('company') || cleanEmail.contains('daffa')) {
        role = 'perusahaan';
        name = 'PT Nusantara Sejahtera';
      } else {
        role = 'pelamar';
        name = email.split('@').first;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'dummy_token_12345');
    await prefs.setString('user_role', role);
    await prefs.setString('user_email', finalEmail);
    await prefs.setString('user_name', name);

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
    return true;
  }
}