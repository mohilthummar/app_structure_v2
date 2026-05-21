/// Application-wide constants: keys for storage, header names, timeouts,
/// debounce intervals, default page sizes.
///
/// Don't put colors, asset paths, or copy here — those live in `app_colors`,
/// `app_assets`, `app_strings`.
abstract class AppConstants {
  static const String appName = 'app_structure';

  // Storage keys (used by SecureStorageService)
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String csrfTokenKey = 'csrf_token';

  // Header names
  static const String csrfHeaderName = 'x-csrf-token';

  // Networking
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // UX
  static const int defaultPageLimit = 10;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration toastDuration = Duration(seconds: 5);
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
