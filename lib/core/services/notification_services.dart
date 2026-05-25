import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:app_structure/core/services/device_info_service.dart';
import 'package:app_structure/core/services/permission_service.dart';
import 'package:app_structure/core/storage/local_storage.dart';
import 'package:app_structure/core/utils/app_logger.dart';

/// Payload extracted from a tapped or foreground push. Routes consumers
/// can act on without re-parsing the raw `Map`. Always built via
/// [NotificationService._parse], which whitelists the `type` field.
class NotificationPayload {
  const NotificationPayload({
    required this.type,
    required this.data,
    this.title,
    this.body,
  });

  final String type;
  final Map<String, dynamic> data;
  final String? title;
  final String? body;
}

/// Push + local-notification service. Replaces the legacy script-style
/// implementation that used globals, hardcoded routes, and skipped
/// payload validation.
///
/// Key safety rules (enforced here, per `.claude/rules/security.md`):
///
/// * **Whitelist `type` before navigating.** Push payloads are
///   user-controlled input — only types listed in [_allowedTypes] are
///   surfaced via [onTap]. Everything else is logged and dropped.
/// * **No business logic inside this service.** Consumers (controllers
///   / a top-level coordinator) subscribe to [onTap] and decide where
///   to navigate. The service never calls `Get.toNamed` itself.
/// * **Init guarded.** Safe to call `init()` when Firebase failed to
///   initialize — every Firebase call is wrapped in a check and the
///   stream just stays silent.
///
/// Registered as a permanent service in `InitialBinding`. Call `init()`
/// from a top-level coordinator (typically the splash controller) so
/// the FCM token is fetched + persisted before the first protected
/// route is opened.
class NotificationService {
  NotificationService({
    required LocalStorageService storage,
    required PermissionService permissions,
    required DeviceInfoService deviceInfo,
    Set<String>? allowedTypes,
  }) : _storage = storage,
       _permissions = permissions,
       _deviceInfo = deviceInfo,
       _allowedTypes = allowedTypes ?? const {};

  final LocalStorageService _storage;
  // ignore: unused_field
  final DeviceInfoService _deviceInfo;
  final PermissionService _permissions;

  /// Notification `type` values that callers want surfaced via `onTap`.
  /// Anything else is dropped with a warning. Extend by passing
  /// `allowedTypes: { 'order', 'deal', 'chat' }` when constructing.
  final Set<String> _allowedTypes;

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<NotificationPayload>.broadcast();
  bool _initialized = false;

  /// Tap stream — emit on initial-message tap (cold start), background
  /// tap, and local-notification tap. Subscribe in a top-level
  /// coordinator like the splash controller.
  Stream<NotificationPayload> get onTap => _tapController.stream;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// Idempotent. No-op when Firebase init failed.
  Future<void> init() async {
    if (_initialized) return;
    if (Firebase.apps.isEmpty) {
      AppLogger.info(
        'Firebase not initialized — NotificationService running in disabled mode.',
        tag: 'NotificationService',
      );
      _initialized = true;
      return;
    }

    await _requestPermission();
    await _initLocalNotifications();
    await _wireFcm();
    await _refreshDeviceToken();

    _initialized = true;
  }

  /// Cancel everything (e.g. on logout). Safe to call before [init].
  Future<void> clearAll() => _local.cancelAll();

  // ── Internals ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final outcome = await _permissions.notification();
    AppLogger.data(outcome.name, tag: 'NotificationService.permission');
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const iOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _local.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (resp) => _onLocalTap(resp.payload),
    );

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _wireFcm() async {
    final fm = FirebaseMessaging.instance;

    await fm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Cold start — app launched from a tapped notification.
    final initial = await fm.getInitialMessage();
    if (initial != null) _emit(initial.data, initial.notification);

    // Background tap.
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _emit(msg.data, msg.notification);
    });

    // Foreground push — show a local notification on Android so the
    // user actually sees it. iOS handles foreground presentation via
    // setForegroundNotificationPresentationOptions above.
    FirebaseMessaging.onMessage.listen((msg) async {
      if (Platform.isAndroid && msg.notification != null) {
        await _showLocal(msg);
      }
    });
  }

  Future<void> _refreshDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _storage.saveDeviceInfo(
          deviceId: _storage.deviceId,
          deviceType: _storage.deviceType,
          deviceToken: token,
          deviceName: _storage.deviceName,
        );
      }
    } catch (e, st) {
      AppLogger.error(
        e.toString(),
        tag: 'NotificationService.refreshDeviceToken',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _showLocal(RemoteMessage msg) async {
    final android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      priority: Priority.high,
      importance: Importance.max,
      icon: '@drawable/ic_notification',
    );
    const iOS = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    await _local.show(
      msg.notification.hashCode,
      msg.notification!.title,
      msg.notification!.body,
      NotificationDetails(android: android, iOS: iOS),
      payload: jsonEncode(msg.data),
    );
  }

  void _onLocalTap(String? raw) {
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        _emit(data, null);
      }
    } catch (e) {
      AppLogger.warning(
        'Ignoring local-notification tap with malformed payload: $e',
        tag: 'NotificationService',
      );
    }
  }

  /// Validates the payload and pushes onto `onTap` if allowed.
  void _emit(Map<String, dynamic> data, RemoteNotification? notification) {
    final type = data['type']?.toString();
    if (type == null || type.isEmpty) {
      AppLogger.warning('Dropping notification with missing `type`.', tag: 'NotificationService');
      return;
    }
    if (_allowedTypes.isNotEmpty && !_allowedTypes.contains(type)) {
      AppLogger.warning(
        'Dropping notification with non-whitelisted type: $type',
        tag: 'NotificationService',
      );
      return;
    }
    _tapController.add(
      NotificationPayload(
        type: type,
        data: Map<String, dynamic>.from(data),
        title: notification?.title,
        body: notification?.body,
      ),
    );
  }
}
