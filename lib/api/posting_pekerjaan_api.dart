import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class Postingpekerjaanapi {
  final String apiUrl = getApiUrl();

  Future<List<Map<String, dynamic>>> getPostPekerjaan(int idPerusahaan) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    final url = '$apiUrl/jobs/company/$idPerusahaan';

    print("GET JOBS URL : $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return List<Map<String, dynamic>>.from(
        data['data'],
      );
    }

    throw Exception('Gagal mengambil data postingan pekerjaan');
  }

  Future<List<Map<String, dynamic>>> detailsJob(int idPostingan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$apiUrl/jobs/$idPostingan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<dynamic> jobs = data['data'];

      return jobs.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    throw Exception('Gagal mengambil detail pekerjaan');
  }

  Future<bool> postingPekerjaann(
    int idPerusahaan,
    String posisi,
    String lokasi,
    String jobDetails,
    String requirements,
  ) async {
    print("API URL : $apiUrl/jobs");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$apiUrl/jobs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'idPerusahaan': idPerusahaan,
        'posisi': posisi,
        'lokasi': lokasi,
        'jobDetails': jobDetails,
        'requirements': requirements,
      }),
    );

    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

    return response.statusCode == 201;
  }

  Future<bool> ubahStatusPekerjaann(int idPostPekerjaan, String status) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null) {
      return false;
    }

    final response = await http.patch(
      Uri.parse('$apiUrl/jobs/$idPostPekerjaan/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getPelamarByCompanyId(
      int idPerusahaan) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = '$apiUrl/perusahaan/$idPerusahaan/applications';

    print("GET PELAMAR URL : $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(
        jsonResponse['data'],
      );
    }

    throw Exception('Gagal mengambil data pelamar');
  }

  Future<Map<String, dynamic>> getDetailPelamar(int idLamaranPekerjaan) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$apiUrl/jobs/applications/$idLamaranPekerjaan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Map<String, dynamic>.from(data['data'][0]);
    }

    throw Exception('Gagal mengambil detail pelamar');
  }

  Future<List<Map<String, dynamic>>> getAllPostPekerjaan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$apiUrl/jobs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<dynamic> postings = data['data'];

      return postings.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    throw Exception('Gagal mengambil seluruh postingan');
  }
}
