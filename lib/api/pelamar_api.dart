import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Pelamarapi {
  final String apiUrl = 'dummy_mode';

  Future<bool> updateDataPelamar({
    required int idpelamar,
    required String firstname,
    required String lastname,
    required String email,
    required String aboutme,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', '$firstname $lastname');
    await prefs.setString('user_email', email);
    return true;
  }

  Future<bool> updateProfilePicture({
    required int idpelamar,
    required File imagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Future<bool> updateCV({
    required int idpelamar,
    required File imagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Future<bool> changePassword({
    required int idpelamar,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return true;
  }

  Future<Map<String, dynamic>> createAccount(
      String Fname, String Lname, String email, String password, {String? username}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', 'pelamar');
    final combinedName = Lname.isNotEmpty ? '$Fname $Lname' : Fname;
    await prefs.setString('user_name', combinedName);
    await prefs.setString('user_email', email);
    await prefs.setString('auth_token', 'dummy_token_12345');

    return {
      'status': true,
      'message': 'Akun pelamar berhasil dibuat (Mode Frontend)',
    };
  }
}
