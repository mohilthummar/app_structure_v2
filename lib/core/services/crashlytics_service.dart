import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:app_structure/core/config/app_environment.dart';
import 'package:app_structure/core/utils/app_logger.dart';

/// Forwards uncaught errors to Firebase Crashlytics.
///
/// **Safe to use without Firebase configured.** Every call first checks
/// `Firebase.apps.isNotEmpty` — if init failed (missing
/// `google-services.json` / `GoogleService-Info.plist`), all methods are
/// no-ops. Same when `enableCrashlytics` is `false` in `.env`.
///
/// Wired into the global error sink during `init()` by setting
/// `AppLogger.errorReportHook`, so every `AppLogger.error(...)` call
/// automatically reaches Crashlytics — controllers/services don't need
/// to know Crashlytics exists.
///
/// Registered as a permanent service in `InitialBinding`. `init()` is
/// called once from `bootstrap.dart` after DI graph is up.
class CrashlyticsService {
  CrashlyticsService();

  bool _ready = false;

  /// True when Crashlytics is wired AND enabled. Use in tests or callers
  /// that want to skip extra work when reporting is off.
  bool get isActive => _ready;

  Future<void> init() async {
    if (!_isAvailable) {
      AppLogger.info(
        'Crashlytics disabled (Firebase init failed or ENABLE_CRASHLYTICS=false)',
        tag: 'CrashlyticsService',
      );
      return;
    }

    final crashlytics = FirebaseCrashlytics.instance;

    // Off in debug — devs shouldn't poison the prod dashboard with stack
    // traces from hot reload. Use `enableCrashlytics` in .env to override.
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Forward every AppLogger.error call to Crashlytics.
    AppLogger.errorReportHook = (Object error, StackTrace? stack, {String? tag}) {
      crashlytics.recordError(
        error,
        stack,
        reason: tag,
        fatal: false,
      );
    };

    _ready = true;
  }

  /// Manually record a non-fatal error. Most code should just call
  /// `AppLogger.error(...)` — this is exposed for cases where you want to
  /// record without logging to the console.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_ready) return;
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Attach the current authenticated user id so crashes can be grouped.
  /// Call from `AuthController.applyLoginResponse` (or wherever the user
  /// id first becomes known) and pass `null` on logout.
  Future<void> setUserId(String? userId) async {
    if (!_ready) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }

  /// Add a key/value pair to every crash report (e.g. feature flag values,
  /// last route). Keep keys short and stable — Crashlytics caps the count.
  Future<void> setCustomKey(String key, Object value) async {
    if (!_ready) return;
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  bool get _isAvailable => Firebase.apps.isNotEmpty && AppEnvironment.enableCrashlytics;
}
