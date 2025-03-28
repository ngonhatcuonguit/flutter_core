
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvManager {
  static final _instance = EnvManager._();

  factory EnvManager() => _instance;

  EnvManager._();
  static EnvManager get shared => _instance;

  String get apiBaseUrlMyTHP => dotenv.env['base_url_driver']!;
  // String get apiNodeUrl => dotenv.env['api_node_url']!;
  // String get apiSocketApi => dotenv.env['api_socket_api']!;
  // String get apiKey => dotenv.env['API_KEY']!;
  // String get environmentName => dotenv.env['environment_name']!;
  // String get socketChat => dotenv.env['socket_chat']!;
}