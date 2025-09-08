import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Utility class for handling local storage operations with type safety and less boilerplate.
///
/// Usage:
/// ```dart
/// // Store a string
/// Preferences.set<String>('key', 'value');
/// final value = Preferences.get<String>('key');
///
/// // Store a bool
/// Preferences.set<bool>('isLoggedIn', true);
///
/// // Store a model
/// Preferences.setModel<User>('user', user, (u) => u.toJson());
/// final user = Preferences.getModel<User>('user', User.fromJson);
/// ```
class Preferences {
  static final GetStorage _storage = GetStorage();

  // Keys
  static const String _user = "user";
  static const String _deviceId = "deviceId";
  static const String _deviceToken = "deviceToken";
  static const String _deviceName = "deviceName";
  static const String _isLogged = 'isLogged';
  static const String _token = 'token';

  /// Generic setter for primitives
  static void set<T>(String key, T? value) {
    _storage.write(key, value);
  }

  /// Generic getter for primitives
  static T? get<T>(String key) {
    final value = _storage.read(key);
    if (value is T) return value;
    return null;
  }

  /// Store a model as JSON
  static void setModel<T>(String key, T model, Map<String, dynamic> Function(T) toJson) {
    _storage.write(key, jsonEncode(toJson(model)));
  }

  /// Get a model from JSON
  static T? getModel<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final raw = _storage.read(key);
      if (raw == null) return null;
      final map = jsonDecode(raw);
      return fromJson(map);
    } catch (e) {
      return null;
    }
  }

  // Example for bool
  static set isLogged(bool value) => set<bool>(_isLogged, value);
  static bool get isLogged => get<bool>(_isLogged) ?? false;

  // Example for other fields (add as needed)
  static set token(String? value) => set<String>(_token, value);
  static String? get token => get<String>(_token);

  static set deviceId(String? value) => set<String>(_deviceId, value);
  static String? get deviceId => get<String>(_deviceId);

  static set deviceName(String? value) => set<String>(_deviceName, value);
  static String? get deviceName => get<String>(_deviceName);

  static set deviceToken(String? value) => set<String>(_deviceToken, value);
  static String? get deviceToken => get<String>(_deviceToken);

  /// Remove all user data and token
  static void logout() {
    _storage.write(_isLogged, false);
    _storage.write(_token, null);
    _storage.write(_user, null);
  }
}
