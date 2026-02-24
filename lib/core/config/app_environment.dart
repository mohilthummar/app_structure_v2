import 'package:app_structure/core/enums/common_enums.dart';
import 'package:app_structure/core/utils/color_print.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Manages the application's environment configuration.
///
/// All values are read from a single `.env` file.
/// Environment is selected in `main.dart` via [setEnvironment].
/// The selected environment determines which URL/key/flag set is used.
///
/// Usage:
///   AppEnvironment.setEnvironment(EnvironmentType.development);
///   AppEnvironment.baseUrl       → reads BASE_URL_DEV from .env
///   AppEnvironment.apiTimeout    → reads API_TIMEOUT_DEV from .env
///   AppEnvironment.endpoint.signIn → reads EP_SIGN_IN from .env
class AppEnvironment {
  AppEnvironment._();

  factory AppEnvironment() => _instance;

  static AppEnvironment get instance => _instance;

  static final AppEnvironment _instance = AppEnvironment._();

  // ── Environment State ──

  static late EnvironmentType envType;

  /// Set environment. Call in main.dart before bootstrap.
  static void setEnvironment(EnvironmentType env) {
    envType = env;
    AppPrint.data(type: 'APP Environment', text: '${env.label} (${env.slug})');
    AppPrint.data(type: 'API Base URL', text: baseUrl);
  }

  // ── Env Value Reader ──

  /// Read a value from .env with optional fallback.
  /// Returns empty string if key is missing and no fallback provided.
  String getEnvValue(String key, {String? fallback}) {
    final String? value = dotenv.maybeGet(key);
    if (value == null || value.trim().isEmpty) return fallback ?? '';
    return value.trim();
  }

  // ── Base URL ──

  /// Base URL for the current environment (e.g. "https://api-dev.example.com")
  static String get baseUrl => _instance._getBaseUrl();

  String _getBaseUrl() {
    switch (envType) {
      case EnvironmentType.local:
        return getEnvValue('BASE_URL_LOCAL');
      case EnvironmentType.development:
        return getEnvValue('BASE_URL_DEV');
      case EnvironmentType.staging:
        return getEnvValue('BASE_URL_STAGING');
      case EnvironmentType.production:
        return getEnvValue('BASE_URL_PROD');
    }
  }

  // ── Feature Flags ──

  /// Whether app is in debug mode (true for local/dev/staging, false for production)
  static bool get isDebug => envType != EnvironmentType.production;

  /// Whether logging is enabled for the current environment
  static bool get enableLogging => _instance.getEnvValue('ENABLE_LOGGING', fallback: 'false') == 'true';

  /// Whether Crashlytics is enabled for the current environment
  static bool get enableCrashlytics => _instance.getEnvValue('ENABLE_CRASHLYTICS', fallback: 'false') == 'true';
}
