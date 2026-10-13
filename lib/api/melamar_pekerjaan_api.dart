import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class MelamarPekerjaanapi {
  final String apiUrl = getApiUrl();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Map<String, dynamic>>> gethistoryLamaran(
      int idPelamar) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final url =
    Uri.parse('$apiUrl/applications/pelamar/$idPelamar');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("===== HISTORY LAMARAN =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("===========================");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(
        jsonResponse['data'] ?? [],
      );
    }

    throw Exception(
      'Gagal mengambil data history lamaran',
    );
  }

  Future<Map<String, dynamic>> lamarPekerjaan(
      int idPostPekerjaan, int idPelamar) async {
    final token = await _getToken();

    if (token == null) {
      return {
        "success": false,
        "message": "Token tidak ditemukan"
      };
    }

    final url = Uri.parse('$apiUrl/applications');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "idPostPekerjaan": idPostPekerjaan,
        "idPelamar": idPelamar,
      }),
    );

    print("===== MELAMAR =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("===================");

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        "success": true,
        "message": data["message"],
      };
    }

    return {
      "success": false,
      "message": data["message"] ??
          "Gagal mengirim lamaran",
    };
  }

  Future<Map<String, dynamic>> getDetailPostinganByIdPostingan(
      int idPostingan) async {
    final token = await _getToken();

    final url =
    Uri.parse('$apiUrl/applications/post/$idPostingan');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("===== DETAIL LAMARAN =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("==========================");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Map<String, dynamic>.from(
        data['data'],
      );
    }

    throw Exception(
      'Gagal mengambil detail lamaran',
    );
  }

  Future<bool> ubahStatusPelamar(
      String status,
      int idLamaranPekerjaan,
      ) async {
    final token = await _getToken();

    print("STATUS YANG DIKIRIM:");
    print(status);

    print("ID LAMARAN:");
    print(idLamaranPekerjaan);

    final url =
    Uri.parse('$apiUrl/applications/$idLamaranPekerjaan');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "status": status,
      }),
    );

    print("===== UPDATE STATUS =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("=========================");

    return response.statusCode == 200;
  }
}