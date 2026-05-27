import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:app_structure/core/storage/local_storage.dart';
import 'package:app_structure/core/utils/fcm_messaging_helper.dart';

/// Collects device identity + FCM token and persists it for later lookups.
///
/// Backend expects device_info on login in this shape:
/// ```
/// { "device_id": "...", "device_type": "Android"|"iOS", "device_token": "<FCM>" }
/// ```
class DeviceInfoService {
  DeviceInfoService(this._localStorage);

  final LocalStorageService _localStorage;

  static const String _androidType = 'Android';
  static const String _iosType = 'iOS';

  /// Builds the `device_info` payload for the login API.
  /// First call (or when cached info missing): requests notification
  /// permission, fetches FCM token, persists id/type/token/name.
  /// Subsequent calls: returns cached values without re-fetching.
  Future<Map<String, dynamic>> getDeviceInfo({bool refresh = false}) async {
    if (refresh || _localStorage.deviceId.isEmpty || _localStorage.deviceType.isEmpty || _localStorage.deviceToken.isEmpty) {
      await _refreshDeviceInfo();
    }

    return {
      'device_id': _localStorage.deviceId,
      'device_type': _localStorage.deviceType,
      'device_token': _localStorage.deviceToken,
    };
  }

  Future<void> _refreshDeviceInfo() async {
    final fcmToken = Firebase.apps.isNotEmpty ? await _fetchFcmToken() : null;
    await _persistDeviceDetails(fcmToken: fcmToken ?? '');
  }

  Future<String?> _fetchFcmToken() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return FcmMessagingHelper.fetchToken();
  }

  Future<void> _persistDeviceDetails({required String fcmToken}) async {
    final plugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      final id = info.isPhysicalDevice ? info.id : _randomId();
      await _localStorage.saveDeviceInfo(
        deviceId: id,
        deviceType: _androidType,
        deviceToken: fcmToken,
        deviceName: info.model,
      );
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      final id = info.isPhysicalDevice ? (info.identifierForVendor ?? _randomId()) : _randomId();
      await _localStorage.saveDeviceInfo(
        deviceId: id,
        deviceType: _iosType,
        deviceToken: fcmToken,
        deviceName: info.utsname.machine,
      );
    }
  }

  static String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return List.generate(20, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}
