import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'color_print.dart';
import 'preferences.dart';

/// Utility class for device and platform operations.
///
/// Usage:
/// ```dart
/// DeviceUtils.darkStatusBar();
/// DeviceUtils.screenPortrait();
/// final type = DeviceUtils.getDeviceType();
/// await DeviceUtils.initPlatformState(fcmToken);
/// ```
class DeviceUtils {
  static void darkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light, //
      ),
    );
  }

  static void lightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.white, //
      ),
    );
  }

  static void screenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown, //
    ]);
  }

  static String getDeviceType() {
    return Platform.isAndroid ? 'Android' : 'iOS';
  }

  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static Future<Map<String, String>> initPlatformState(String fcmToken) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    RxString deviceId = "".obs;
    RxString deviceName = "".obs;
    RxString deviceType = "".obs;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = (await deviceInfoPlugin.androidInfo);
        deviceId.value = androidDeviceInfo.id;
        deviceName.value = androidDeviceInfo.brand;
        deviceType.value = "Android";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = (await deviceInfoPlugin.iosInfo);
        deviceId.value = iosDeviceInfo.identifierForVendor ?? "";
        deviceName.value = iosDeviceInfo.modelName;
        deviceType.value = iosDeviceInfo.systemName;
      }
      Preferences.deviceId = deviceId.value;
      Preferences.deviceName = deviceName.value;
      Preferences.deviceToken = fcmToken;
      printBlue("device_name:  [36m${deviceName.value}");
      printBlue("device_type:  [36m${deviceType.value}");
      printBlue("device_id:  [36m${deviceId.value}");
      printBlue("device_token:  [36m$fcmToken");
    } catch (e) {
      debugPrint(e.toString());
    }
    return {"device_id": deviceId.value, "device_token": deviceId.value, "device_name": deviceType.value, "device_type": deviceType.value};
  }
}
