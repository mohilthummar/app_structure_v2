import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:app_structure/core/utils/app_logger.dart';

/// Shared FCM token fetch used by [DeviceInfoService] and
/// [NotificationService]. Handles iOS APNS timing and simulator fallback.
///
/// Stateless static helper — not a GetX-injected service, so it's never
/// registered in `InitialBinding`. It lives under `services/` because it
/// wraps a platform capability (Firebase Messaging), not because it holds
/// session state.
abstract final class FcmTokenService {
  /// Returns an FCM registration token, or `null` when Firebase is off or
  /// the token cannot be obtained (permissions denied, APNS missing, etc.).
  static Future<String?> fetchToken() async {
    if (Firebase.apps.isEmpty) return null;

    if (Platform.isIOS) {
      final placeholder = await _iosSimulatorPlaceholderToken();
      if (placeholder != null) return placeholder;
      await _waitForApnsToken();
    }

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      AppLogger.error(
        'FCM getToken failed: $e',
        tag: 'FcmTokenService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// iOS must register for remote notifications before [getToken] succeeds.
  static Future<void> _waitForApnsToken() async {
    const attempts = 12;
    const delay = Duration(milliseconds: 250);

    for (var i = 0; i < attempts; i++) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null && apns.isNotEmpty) return;
      await Future.delayed(delay);
    }

    AppLogger.warning(
      'APNS token not available after ${attempts * delay.inMilliseconds}ms — '
      'FCM getToken may fail until the user grants notification permission.',
      tag: 'FcmTokenService',
    );
  }

  static Future<String?> _iosSimulatorPlaceholderToken() async {
    if (!kDebugMode || !Platform.isIOS) return null;
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    if (!iosInfo.isPhysicalDevice) return 'debug-token';
    return null;
  }
}
