import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import 'package:app_structure/core/utils/app_logger.dart';

/// GetX translations source. Reads dictionaries from `assets/i18n/<lang>.json`
/// at boot — call [load] from `bootstrap.dart` before constructing the
/// instance you hand to `GetMaterialApp.translations`.
///
/// Why JSON files (not inline maps): translators / non-Dart contributors
/// can edit them, AI assistants can diff them, and adding a new language
/// is "drop a file in `assets/i18n/`" rather than a Dart edit + recompile.
///
/// The class itself is immutable after construction. To add a language,
/// register its locale in [supportedLocales] below and ship its JSON file.
class AppTranslations extends Translations {
  AppTranslations(this._keys);

  final Map<String, Map<String, String>> _keys;

  @override
  Map<String, Map<String, String>> get keys => _keys;

  /// Locales the app ships with. Used by `GetMaterialApp.supportedLocales`
  /// AND by [load] to know which JSON files to read.
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
  ];

  static const Locale fallbackLocale = Locale('en', 'US');

  /// Loads every supported-locale JSON file and returns an `AppTranslations`
  /// instance. Locale codes are stored as `<lang>_<country>` so they match
  /// what GetX expects when looking up via `.tr`.
  ///
  /// Missing files don't crash — the locale simply has no entries, which
  /// falls back to [fallbackLocale]. That keeps the skeleton bootable
  /// while a translation file is being drafted.
  static Future<AppTranslations> load() async {
    final result = <String, Map<String, String>>{};
    for (final locale in supportedLocales) {
      final code = '${locale.languageCode}_${locale.countryCode ?? ''}';
      try {
        final path = 'assets/i18n/${locale.languageCode}.json';
        final raw = await rootBundle.loadString(path);
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        result[code] = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (e) {
        AppLogger.warning(
          'Could not load translations for $code: $e',
          tag: 'AppTranslations',
        );
        result[code] = const {};
      }
    }
    return AppTranslations(result);
  }
}
