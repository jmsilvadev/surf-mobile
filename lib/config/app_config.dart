import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration loaded from environment variables.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8081';

  // Timeout durations.
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // OAuth client id for server-side verification (web client id)
  static String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
}
