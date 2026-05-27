import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/config/app_environment.dart';
import 'package:app_structure/firebase_options.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/controllers/locale_controller.dart';
import 'package:app_structure/core/controllers/theme_controller.dart';
import 'package:app_structure/core/di/initial_binding.dart';
import 'package:app_structure/core/enums/environment_enums.dart';
import 'package:app_structure/core/error/app_error_handler.dart';
import 'package:app_structure/core/i18n/app_translations.dart';
import 'package:app_structure/core/services/analytics_service.dart';
import 'package:app_structure/core/services/crashlytics_service.dart';
import 'package:app_structure/core/storage/local_storage.dart';
import 'package:app_structure/core/utils/app_logger.dart';

/// Single boot seam. Owns the exact order of every step that must complete
/// before `runApp` is called. Call from `main.dart` like this:
///
/// ```dart
/// void main() {
///   runZonedGuarded(() async {
///     await bootstrap(environment: EnvironmentType.development);
///     runApp(const MyApp());
///   }, AppErrorHandler.onZoneError);
/// }
/// ```
///
/// Order (don't reorder — each step depends on the one above):
///
/// 1. `WidgetsFlutterBinding.ensureInitialized()` — must be first; platform
///    channels aren't usable before this.
/// 2. `AppErrorHandler.init()` — install FlutterError + PlatformDispatcher
///    hooks early so any error during the rest of boot is captured.
/// 3. `dotenv.load()` — `.env` MUST be loaded before any code reads
///    `AppEnvironment` / `ApiUrls`, which `InitialBinding` does.
/// 4. `AppEnvironment.setEnvironment()` — selects which BASE_URL_* /
///    EP_* keys are returned.
/// 5. Firebase init (guarded) — if `google-services.json` /
///    `GoogleService-Info.plist` is missing, the failure is logged and we
///    keep going. Crashlytics + Analytics services will detect this and
///    no-op until config is added.
/// 6. System chrome + portrait lock.
/// 7. `InitialBinding().dependencies()` — registers SecureStorage,
///    LocalStorage, ApiClient, AuthController, etc. ApiClient reads
///    `AppEnvironment.baseUrl` at this point.
/// 8. `LocalStorageService.init()` — GetStorage async warmup so all
///    subsequent reads are synchronous.
Future<void> bootstrap({required EnvironmentType environment}) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppErrorHandler.init();

  await dotenv.load(fileName: '.env');

  AppEnvironment.setEnvironment(environment);

  await _initFirebaseSafe();

  await _applySystemChrome();

  InitialBinding().dependencies();

  await Get.find<LocalStorageService>().init();

  // Telemetry init AFTER DI is up — these set their internal `_ready`
  // flag, install the AppLogger hook, and start auto-collecting. Both
  // no-op safely if Firebase init failed or the corresponding `.env`
  // flag is off, so the app boots either way.
  await Get.find<CrashlyticsService>().init();
  await Get.find<AnalyticsService>().init();

  // i18n — load JSON dictionaries off-disk once, then register the
  // translations + locale controller. LocaleController.onInit reads the
  // saved locale from LocalStorage (initialised above) and falls back
  // to system locale → AppTranslations.fallbackLocale.
  final translations = await AppTranslations.load();
  Get.put<AppTranslations>(translations, permanent: true);
  Get.put<LocaleController>(
    LocaleController(Get.find<LocalStorageService>()),
    permanent: true,
  );

  // Theme — reads saved mode from LocalStorage in onInit, defaults to
  // ThemeMode.system. GetMaterialApp uses Get.changeThemeMode under the
  // hood so views never need an explicit Obx for theme.
  Get.put<ThemeController>(
    ThemeController(Get.find<LocalStorageService>()),
    permanent: true,
  );
}

/// Firebase init with fallback. Missing config files are a normal state
/// for a fresh skeleton — log and continue rather than crash boot.
Future<void> _initFirebaseSafe() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    if (kDebugMode) {
      AppLogger.success('Firebase initialised');
    }
  } catch (e) {
    AppLogger.warning(
      'Firebase init skipped (likely missing google-services.json / '
      'GoogleService-Info.plist): $e',
    );
    // Intentional: Crashlytics + Analytics services check Firebase.apps
    // before any call, so they no-op cleanly when init fails.
  }
}

Future<void> _applySystemChrome() async {
  // Boot-time defaults — the AppBar / Scaffold's
  // `appBarTheme.systemOverlayStyle` (built into `AppTheme`) takes over once
  // a screen with an AppBar mounts. Keep the icon brightness consistent with
  // the background color (dark icons on white surfaces) or they become
  // invisible until the theme overlay applies.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
