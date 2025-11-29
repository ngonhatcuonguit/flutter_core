import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvManager {
  static final _instance = EnvManager._();

  factory EnvManager() => _instance;

  EnvManager._();

  static EnvManager get shared => _instance;

  // API Configuration
  String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://newsapi.org/v2';
  String get apiKey => dotenv.env['API_KEY'] ?? '';
  String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  // Check if running in production
  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
}
