import 'package:app_structure/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key/value storage for sensitive material (auth, refresh, CSRF
/// tokens). Uses `EncryptedSharedPreferences` on Android, Keychain on iOS.
///
/// Registered as a permanent service in `InitialBinding`.
class SecureStorageService {
  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  final FlutterSecureStorage _storage;

  // ── Auth token ─────────────────────────────────────────────────────────
  Future<void> saveToken(String token) => _storage.write(key: AppConstants.tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: AppConstants.tokenKey);

  // ── Refresh token ──────────────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) => _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.refreshTokenKey);

  // ── CSRF token ─────────────────────────────────────────────────────────
  Future<void> saveCsrfToken(String token) => _storage.write(key: AppConstants.csrfTokenKey, value: token);

  Future<String?> getCsrfToken() => _storage.read(key: AppConstants.csrfTokenKey);

  // ── Helpers ────────────────────────────────────────────────────────────
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
