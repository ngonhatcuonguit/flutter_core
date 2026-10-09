import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized app configuration.
/// Values are read from the loaded .env file (either .env.dev or .env.prod),
/// which is determined by the entrypoint (main_dev.dart / main_prod.dart).
class AppConfig {
  AppConfig._();

  static String? _readEnv(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  /// The environment name: "development" or "production"
  static String get environment => _readEnv('ENVIRONMENT') ?? 'development';

  /// Base URL for the THP API (e.g. https://mobile-app.thp.com.vn)
  static String get baseUrl =>
      _readEnv('API_BASE_URL') ?? 'https://mobile-app.thp.com.vn';

  /// Dedicated base URL for THP Festival. This client never shares the main
  /// app's login session or bearer token.
  static String get festivalBaseUrl =>
      _readEnv('FESTIVAL_API_BASE_URL') ?? 'https://mobile-test.thp.com.vn';

  /// Dedicated host documented for live Hotline zone/table lookups. This is
  /// intentionally separate so check-in and authentication keep their current
  /// Festival API host.
  static String get festivalSeatingBaseUrl =>
      _readEnv('FESTIVAL_SEATING_API_BASE_URL') ??
      'https://event_checkin.thp.com.vn';

  /// Current event used for Festival seating and guest color lookups.
  static int get festivalEventId {
    final value = int.tryParse(_readEnv('FESTIVAL_EVENT_ID') ?? '');
    return value != null && value > 0 ? value : 2;
  }

  /// Display name shown in app title / debug banner
  static String get appTitle => _readEnv('APP_TITLE') ?? 'My THP';

  /// Whether this is a development build
  static bool get isDev => environment == 'development';

  /// Whether this is a production build
  static bool get isProd => environment == 'production';

  /// Connect / receive / send timeout in milliseconds
  static int get timeoutMs =>
      int.tryParse(_readEnv('API_TIMEOUT_MS') ?? '30000') ?? 30000;

  @override
  String toString() => 'AppConfig(env=$environment, baseUrl=$baseUrl)';
}
