import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rekanpabrik/utils/api_url.dart';

class meAPI {
  final String apiUrl = getApiUrl();

  Future<Map<String, dynamic>> getUserProfile() async {
    final url = Uri.parse('$apiUrl/auth/me');
    final token = await getToken();
    if (token == null) {
      return {
        'status': false,
        'message': 'Token not found. Please log in again.',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return {
          'status': true,
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'status': false,
          'message': 'Failed to fetch user profile',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
