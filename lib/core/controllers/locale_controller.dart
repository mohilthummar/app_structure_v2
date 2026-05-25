import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/i18n/app_translations.dart';
import 'package:app_structure/core/storage/local_storage.dart';

/// Owns the app's active locale. Reads the saved choice from
/// `LocalStorageService` on init; falls back to the system locale when
/// supported, otherwise to `AppTranslations.fallbackLocale`.
///
/// Registered as a permanent service in `InitialBinding`. Views read
/// `currentLocale.value` reactively for things like a language picker;
/// most callers just use `I18n.x.tr` and never touch this class.
///
/// Switching is a single call: `Get.find<LocaleController>().setLocale(...)`.
/// `Get.updateLocale` is invoked internally so every `.tr` consumer
/// rebuilds.
class LocaleController extends GetxController {
  LocaleController(this._storage);

  final LocalStorageService _storage;

  /// Currently active locale. Reactive — UI can `Obx` on it to update
  /// language-picker selections etc.
  final Rx<Locale> currentLocale = AppTranslations.fallbackLocale.obs;

  @override
  void onInit() {
    super.onInit();
    currentLocale.value = _resolveInitialLocale();
  }

  /// Switch language. Persists the choice and triggers a rebuild for
  /// every `.tr` consumer.
  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) return;
    currentLocale.value = locale;
    await _storage.saveLocale(
      languageCode: locale.languageCode,
      countryCode: locale.countryCode,
    );
    await Get.updateLocale(locale);
  }

  /// Clear the saved choice — next boot will use the system locale (or
  /// fallback). Use for a "Reset to device language" button.
  Future<void> clearSavedLocale() async {
    await _storage.clearLocale();
    final next = _systemLocaleIfSupported() ?? AppTranslations.fallbackLocale;
    currentLocale.value = next;
    await Get.updateLocale(next);
  }

  Locale _resolveInitialLocale() {
    final lang = _storage.savedLanguageCode;
    if (lang != null && lang.isNotEmpty) {
      final saved = Locale(lang, _storage.savedCountryCode);
      if (_isSupported(saved)) return saved;
    }
    return _systemLocaleIfSupported() ?? AppTranslations.fallbackLocale;
  }

  Locale? _systemLocaleIfSupported() {
    final system = PlatformDispatcher.instance.locale;
    return _isSupported(system) ? system : null;
  }

  bool _isSupported(Locale locale) {
    return AppTranslations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }
}
