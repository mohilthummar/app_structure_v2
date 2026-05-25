import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Non-secure key/value store. Use `SecureStorageService` for tokens.
///
/// GetStorage-backed — sync reads after `init()`, async writes.
/// Registered as a permanent service in `InitialBinding`; `main.dart` calls
/// `init()` once before `runApp`.
class LocalStorageService {
  LocalStorageService();

  final GetStorage _storage = GetStorage();

  /// Initialise GetStorage. Idempotent — safe to call repeatedly.
  Future<void> init() async {
    await GetStorage.init();
  }

  // ── Generic accessors ──────────────────────────────────────────────────

  Future<bool> setString(String key, String value) async {
    await _storage.write(key, value);
    return true;
  }

  String? getString(String key) => _storage.read<String>(key);

  Future<bool> setBool(String key, bool value) async {
    await _storage.write(key, value);
    return true;
  }

  bool? getBool(String key) => _storage.read<bool>(key);

  Future<bool> setInt(String key, int value) async {
    await _storage.write(key, value);
    return true;
  }

  int? getInt(String key) => _storage.read<int>(key);

  Future<bool> remove(String key) async {
    await _storage.remove(key);
    return true;
  }

  Future<bool> clear() async {
    await _storage.erase();
    return true;
  }

  // ── Cached user (persisted JSON string survives restarts) ──────────────

  static const String _userDataKey = 'user_data';

  String? get userDataJson => getString(_userDataKey);
  Future<bool> saveUserData(String json) => setString(_userDataKey, json);
  Future<bool> clearUserData() => remove(_userDataKey);

  // ── Device info (for login device_info payload + FCM) ──────────────────

  static const String _deviceIdKey = 'device_id';
  static const String _deviceTypeKey = 'device_type';
  static const String _deviceTokenKey = 'device_token';
  static const String _deviceNameKey = 'device_name';

  String get deviceId => getString(_deviceIdKey) ?? '';
  String get deviceType => getString(_deviceTypeKey) ?? '';
  String get deviceToken => getString(_deviceTokenKey) ?? '';
  String get deviceName => getString(_deviceNameKey) ?? '';

  Future<void> saveDeviceInfo({
    required String deviceId,
    required String deviceType,
    required String deviceToken,
    required String deviceName,
  }) async {
    await setString(_deviceIdKey, deviceId);
    await setString(_deviceTypeKey, deviceType);
    await setString(_deviceTokenKey, deviceToken);
    await setString(_deviceNameKey, deviceName);
  }

  // ── Locale (selected via LocaleController) ─────────────────────────────

  static const String _languageCodeKey = 'locale_language_code';
  static const String _countryCodeKey = 'locale_country_code';

  String? get savedLanguageCode => getString(_languageCodeKey);
  String? get savedCountryCode => getString(_countryCodeKey);

  Future<void> saveLocale({required String languageCode, String? countryCode}) async {
    await setString(_languageCodeKey, languageCode);
    if (countryCode != null) {
      await setString(_countryCodeKey, countryCode);
    } else {
      await remove(_countryCodeKey);
    }
  }

  Future<void> clearLocale() async {
    await remove(_languageCodeKey);
    await remove(_countryCodeKey);
  }

  // ── Theme (selected via ThemeController; values: 'light' | 'dark' | 'system') ──

  static const String _themeModeKey = 'theme_mode';

  String? get savedThemeMode => getString(_themeModeKey);

  Future<bool> saveThemeMode(String mode) => setString(_themeModeKey, mode);

  Future<bool> clearThemeMode() => remove(_themeModeKey);

  // ── Typed model helpers (toJson / fromJson round-trip) ─────────────────

  /// Persist a model as JSON. Use for typed objects that ship `toJson()`.
  Future<bool> saveModel<T>(
    String key,
    T model,
    Map<String, dynamic> Function(T) toJson,
  ) => setString(key, jsonEncode(toJson(model)));

  /// Read a previously-persisted model. Returns null on missing key or
  /// parse failure (e.g. schema change).
  T? getModel<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
