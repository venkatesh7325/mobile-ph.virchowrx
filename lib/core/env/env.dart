import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get baseUrl => dotenv.env['APP_BASE_URL'] ?? 'https://api.yourapp.com';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static int get timeout => int.tryParse(dotenv.env['APP_TIMEOUT'] ?? '30000') ?? 30000;

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}
