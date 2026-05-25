import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/controllers/locale_controller.dart';
import 'package:app_structure/core/controllers/theme_controller.dart';
import 'package:app_structure/core/i18n/app_translations.dart';
import 'package:app_structure/core/services/app_info_service.dart';

/// Thin orchestration controller — no repo, no network. Profile is a
/// composition of state already owned by global controllers:
///
/// * `AuthController` — user identity + logout action.
/// * `ThemeController` — light/dark/system.
/// * `LocaleController` — current language + setLocale.
/// * `AppInfoService`  — version / build for the "About" tile.
///
/// Kept as a `GetxController` (not `BaseController`) because no async
/// state machine is needed; everything reactive lives on the upstream
/// controllers.
class ProfileController extends GetxController {
  final AuthController auth = Get.find<AuthController>();
  final ThemeController theme = Get.find<ThemeController>();
  final LocaleController locale = Get.find<LocaleController>();
  final AppInfoService appInfo = Get.find<AppInfoService>();

  @override
  void onReady() {
    super.onReady();
    appInfo.load();
  }

  List<Locale> get supportedLocales => AppTranslations.supportedLocales;

  Future<void> onChangeTheme(ThemeMode mode) => theme.setMode(mode);

  Future<void> onChangeLocale(Locale next) => locale.setLocale(next);

  Future<void> onLogout() => auth.logout();
}
