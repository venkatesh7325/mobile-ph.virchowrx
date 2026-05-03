import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  /// Same pharmacy API root as the React portal ([Pharmacy]/src/utils/axios.ts).
  static String get baseUrl {
    final fromEnv = dotenv.env['APP_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return 'https://vbpl-dev-backend-a3drbdd0fbh2cjbn.centralindia-01.azurewebsites.net/api/pharmacy';
  }
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static int get timeout => int.tryParse(dotenv.env['APP_TIMEOUT'] ?? '30000') ?? 30000;

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}
