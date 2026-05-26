/// Identifiers and config constants that don't belong in storage, theme,
/// or i18n.
///
/// Lives here because:
///
/// * Storage **keys** (token, refresh, csrf) belong with the constants
///   that reference them — not with the storage *values* (which live in
///   `SecureStorageService` / `LocalStorageService`).
/// * Network timeouts + the CSRF header name are shared between
///   [`ApiClient`] and [`TokenRefreshInterceptor`]; defining them once
///   here keeps both in sync.
/// * UX timings (animations, debounces, toast lifetimes) are shared
///   across many widgets — pinning them here keeps motion consistent.
///
/// Don't put colors, asset paths, or visible copy here — those live in
/// `app_colors.dart`, `app_assets.dart`, and `core/i18n/i18n_keys.dart`.
abstract class AppConstants {
  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'app_structure';

  // ── Secure storage keys ──────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String csrfTokenKey = 'csrf_token';

  // ── Network ──────────────────────────────────────────────────────────────
  static const String csrfHeaderName = 'x-csrf-token';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageLimit = 10;

  // ── UX timings ───────────────────────────────────────────────────────────
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration toastDuration = Duration(seconds: 5);
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
