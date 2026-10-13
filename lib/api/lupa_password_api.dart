import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class LupaPasswordapi {
  final String apiUrl = getApiUrl();

  Future<bool> requestResetPassword(String email) async {
    var url = Uri.parse('$apiUrl/auth/password/forgot');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
