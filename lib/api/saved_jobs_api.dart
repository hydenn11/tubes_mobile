import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class SavedJobsApi {
  final String apiUrl = getApiUrl();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Map<String, dynamic>>> getSavedJobsByIDPelamar(
      int idPelamar) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final url = Uri.parse('$apiUrl/saved-jobs/pelamar/$idPelamar');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("===== SAVED JOBS =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("======================");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(
        data['data'] ?? [],
      );
    }

    throw Exception(
      'Gagal mengambil data saved jobs',
    );
  }

  Future<Map<String, dynamic>> savedJobs(
    int idPostPekerjaan,
    int idPelamar,
  ) async {
    final token = await _getToken();

    if (token == null) {
      return {
        "success": false,
        "message": "Token tidak ditemukan",
      };
    }

    final url = Uri.parse('$apiUrl/saved-jobs');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "idPelamar": idPelamar,
        "idPostPekerjaan": idPostPekerjaan,
      }),
    );

    print("===== SAVE JOB =====");
    print("URL : $url");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("====================");

    print("===== SAVED JOBS =====");
    print(response.body);
    print("=====================");

    final data = jsonDecode(response.body);

    return {
      "success": data["success"] ?? false,
      "saved": data["saved"] ?? false,
      "message": data["message"] ?? "",
    };
  }

  Future<bool> toggleSavedJobs(
      int idPelamar,
      int idPostPekerjaan,
      ) async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();

    String? token =
    prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$apiUrl/saved-jobs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "idPelamar": idPelamar,
        "idPostPekerjaan": idPostPekerjaan,
      }),
    );

    return response.statusCode == 200;
  }
}
