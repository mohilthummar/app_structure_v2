import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'package:app_structure/core/config/app_environment.dart';
import 'package:app_structure/core/utils/app_logger.dart';

/// Thin wrapper around Firebase Analytics. Same safety model as
/// `CrashlyticsService`: every method is a no-op when Firebase init
/// failed OR `enableAnalytics` is `false` in `.env`. Safe to call from
/// anywhere without null checks.
///
/// Registered as a permanent service in `InitialBinding`. Bootstrap
/// calls `init()` once after the DI graph is up. Wire `observer` into
/// `GetMaterialApp.navigatorObservers` to auto-log screen views.
class AnalyticsService {
  AnalyticsService();

  FirebaseAnalyticsObserver? _observer;

  bool _ready = false;

  /// True when analytics is wired AND enabled.
  bool get isActive => _ready;

  /// Pass this to `GetMaterialApp.navigatorObservers` only when [isActive].
  /// Never touches [FirebaseAnalytics] when Firebase init failed.
  NavigatorObserver get observer {
    if (!_isAvailable) return _NoopNavigatorObserver();
    return _observer ??= FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
      routeFilter: (route) => route?.settings.name?.isNotEmpty == true,
      nameExtractor: (settings) => settings.name,
    );
  }

  Future<void> init() async {
    if (!_isAvailable) {
      AppLogger.info(
        'Analytics disabled (Firebase init failed or ENABLE_ANALYTICS=false)',
        tag: 'AnalyticsService',
      );
      return;
    }
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    _ready = true;
  }

  /// Log a custom event. Names should be snake_case and < 40 chars.
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }

  /// Attach the current user id. Pass `null` on logout.
  Future<void> setUserId(String? userId) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.setUserId(id: userId);
  }

  /// Set a user property (e.g. role, locale, plan). Keep names stable —
  /// Analytics treats each unique name as its own dimension.
  Future<void> setUserProperty(String name, String? value) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
  }

  bool get _isAvailable => Firebase.apps.isNotEmpty && AppEnvironment.enableAnalytics;
}

/// Used when Firebase is unavailable so [GetMaterialApp] can keep a stable
/// observer list without calling [FirebaseAnalytics.instance].
class _NoopNavigatorObserver extends NavigatorObserver {}
