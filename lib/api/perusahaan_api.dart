import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class PerusahaanAPI {
  final String apiUrl = getApiUrl();

  Future<bool> updateProfilePicture({
    required int idperusahaan,
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
        '$apiUrl/perusahaan/$idperusahaan/profile-picture',
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

    print("========== UPLOAD PROFILE ==========");
    print("URL : ${request.url}");
    print("STATUS : ${response.statusCode}");
    print("BODY : $body");
    print("====================================");

    return response.statusCode == 200;
  }

  Future<bool> updateProfileData({
    required int idperusahaan,
    required String email,
    required String namaPerusahaan,
    required String tentangPerusahaan,
    required String alamatPerusahaan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return false;
    }

    var url = Uri.parse('$apiUrl/perusahaan/updateDataPerusahaan');

    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idPerusahaan': idperusahaan,
          'email': email,
          'nama_perusahaan': namaPerusahaan,
          'aboutMe': tentangPerusahaan,
          'alamat': alamatPerusahaan,
        }));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> changePassword({
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null) {
      print("TOKEN NULL");
      return false;
    }

    final url = Uri.parse(
      '$apiUrl/auth/password/reset',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'newPassword': newPassword,
      }),
    );

    print("========== RESET PASSWORD ==========");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("====================================");

    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getAllPerusahaan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("Terjadi kesalahan:");
    }

    final url = Uri.parse('$apiUrl/perusahaan/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("=== GET ALL PERUSAHAAN ===");
      print("URL : $url");
      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.body}");
      print("==========================");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['data'] != null) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception("Tidak ada data Perusahaan.");
        }
      } else {
        throw Exception(
            "Gagal mengambil data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getPerusahaanByIDPerusahaan(
      int idperusahaan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = Uri.parse('$apiUrl/perusahaan/$idperusahaan');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("===== DETAIL PERUSAHAAN =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("=============================");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<dynamic> perusahaan = data['data'];

      return perusahaan.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception(
        'Gagal mengambil data postingan pekerjaan (${response.statusCode})',
      );
    }
  }

  Future<bool> createAccount(
      String email, String password, String namaPerusahaan) async {
    var url = Uri.parse('$apiUrl/auth/register/perusahaan');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'namaPerusahaan': namaPerusahaan,
      }),
    );

    print("===== REGISTER PERUSAHAAN =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("===============================");

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
