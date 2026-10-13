import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class Pengaduanapi {
  final String apiUrl = getApiUrl();

  Future<bool> kirimPengaduan(
      String firstName,
      String lastName,
      String email,
      String phone,
      String message,
      ) async {
    final url = Uri.parse('$apiUrl/pengaduan');

    print("========== KIRIM PENGADUAN ==========");
    print("URL : $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "nomor_telpon": phone,
        "pesan": message,
      }),
    );

    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }
}