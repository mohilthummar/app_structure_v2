import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/storage/local_storage.dart';

/// Owns the app's `ThemeMode` (light / dark / system). Reads the saved
/// choice from `LocalStorageService` on init; defaults to
/// `ThemeMode.system` so first-launch matches the device.
///
/// Registered as a permanent service in `InitialBinding`. Calls
/// `Get.changeThemeMode` so every `GetMaterialApp`-managed widget reacts
/// without needing an explicit `Obx` at the top of the tree.
class ThemeController extends GetxController {
  ThemeController(this._storage);

  final LocalStorageService _storage;

  static const _light = 'light';
  static const _dark = 'dark';
  static const _system = 'system';

  /// Current ThemeMode. UI may `Obx` this for a theme picker — most
  /// callers don't need to since `Get.changeThemeMode` propagates.
  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    mode.value = _decodeStored(_storage.savedThemeMode);
  }

  /// Switch theme mode. Persists the choice + tells `Get` to update
  /// `GetMaterialApp.themeMode`.
  Future<void> setMode(ThemeMode next) async {
    if (mode.value == next) return;
    mode.value = next;
    await _storage.saveThemeMode(_encode(next));
    Get.changeThemeMode(next);
  }

  /// Convenience for a tri-state picker (settings tile).
  Future<void> useLight() => setMode(ThemeMode.light);
  Future<void> useDark() => setMode(ThemeMode.dark);
  Future<void> useSystem() => setMode(ThemeMode.system);

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => _light,
    ThemeMode.dark => _dark,
    ThemeMode.system => _system,
  };

  static ThemeMode _decodeStored(String? raw) => switch (raw) {
    _light => ThemeMode.light,
    _dark => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
