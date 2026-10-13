import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class Pelamarapi {
  final String apiUrl = getApiUrl();

  Future<bool> updateDataPelamar({
    required int idpelamar,
    required String firstname,
    required String lastname,
    required String email,
    required String aboutme,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("TOKEN NULL");
      return false;
    }

    final url = Uri.parse(
      '$apiUrl/pelamar/$idpelamar',
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstname,
        'last_name': lastname,
        'email': email,
        'aboutMe': aboutme,
      }),
    );

    print("===== UPDATE DATA PELAMAR =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("===============================");

    return response.statusCode == 200;
  }

  Future<bool> updateProfilePicture({
    required int idpelamar,
    required File imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("TOKEN NULL");
      return false;
    }

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse(
        '$apiUrl/pelamar/$idpelamar/profile-picture',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    if (await imagePath.exists()) {
      final mimeType = lookupMimeType(imagePath.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_pict',
          imagePath.path,
          contentType: MediaType.parse(
            mimeType ?? 'image/jpeg',
          ),
        ),
      );
    } else {
      print("FILE TIDAK ADA");
      return false;
    }

    final response = await request.send();

    final body = await response.stream.bytesToString();

    print("===== UPDATE FOTO =====");
    print("URL : ${request.url}");
    print("STATUS : ${response.statusCode}");
    print("BODY : $body");
    print("=======================");

    return response.statusCode == 200;
  }

  Future<bool> updateCV({
    required int idpelamar,
    required File imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("TOKEN NULL");
      return false;
    }

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse(
        '$apiUrl/pelamar/$idpelamar/cv',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    if (await imagePath.exists()) {
      final mimeType = lookupMimeType(imagePath.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'CV',
          imagePath.path,
          contentType: MediaType.parse(
            mimeType ?? 'application/pdf',
          ),
        ),
      );
    } else {
      print("FILE CV TIDAK ADA");
      return false;
    }

    final response = await request.send();

    final body = await response.stream.bytesToString();

    print("===== UPDATE CV =====");
    print("URL : ${request.url}");
    print("STATUS : ${response.statusCode}");
    print("BODY : $body");
    print("=====================");

    return response.statusCode == 200;
  }

  Future<bool> changePassword({
    required int idpelamar,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null) {
      print("TOKEN NULL");
      return false;
    }

    final url = Uri.parse(
      '$apiUrl/pelamar/$idpelamar/password',
    );

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'newPass': newPassword,
      }),
    );

    print("===== CHANGE PASSWORD =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("===========================");

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> createAccount(
      String Fname, String Lname, String email, String password, {String? username}) async {
    var url = Uri.parse('$apiUrl/auth/register/pelamar');
    print("REGISTER URL : $url");
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'username': username,
            'password': password,
            'first_name': Fname,
            'last_name': Lname
          }));

      print("REGISTER STATUS : ${response.statusCode}");
      print("REGISTER BODY : ${response.body}");

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      return {
        'status': response.statusCode >= 200 && response.statusCode < 300,
        'message': data['message'] ?? 'Gagal membuat akun',
      };
    } catch (e) {
      print("REGISTER ERROR : $e");
      String message = e.toString();
      if (message.contains('XMLHttpRequest') ||
          message.contains('SocketException') ||
          message.contains('Connection refused') ||
          message.contains('Failed host lookup')) {
        message = 'Tidak dapat terhubung ke server backend. Pastikan server backend sedang berjalan.';
      }
      return {
        'status': false,
        'message': message,
      };
    }
  }

}
