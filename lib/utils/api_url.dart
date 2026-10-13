import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

String getApiUrl() {
  final envUrl = dotenv.env['API_URL']?.trim() ?? '';

  if (kIsWeb) {
    // Pada Browser (Chrome/Edge), 10.0.2.2 tidak dikenal, harus pakai localhost
    if (envUrl.contains('10.0.2.2')) {
      return envUrl.replaceAll('10.0.2.2', 'localhost');
    }
    return envUrl.isNotEmpty ? envUrl : 'http://localhost:8000';
  }

  // Pada Mobile Android
  if (Platform.isAndroid) {
    if (envUrl.contains('localhost')) {
      return envUrl.replaceAll('localhost', '10.0.2.2');
    }
    return envUrl.isNotEmpty ? envUrl : 'http://10.0.2.2:8000';
  }

  // Windows Desktop / Lainnya
  if (envUrl.contains('10.0.2.2')) {
    return envUrl.replaceAll('10.0.2.2', 'localhost');
  }
  return envUrl.isNotEmpty ? envUrl : 'http://localhost:8000';
}
