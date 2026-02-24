import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/storage/preferences.dart';
import 'package:app_structure/core/types/result.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// Comprehensive utility class containing all UI-related utility functions.
///
/// This class consolidates device utilities, date utilities, file utilities,
/// and toast utilities into a single, easy-to-use class.
///
/// Usage:
/// ```dart
/// // Device operations
/// UiUtils.darkStatusBar();
/// UiUtils.screenPortrait();
/// final type = UiUtils.getDeviceType();
/// await UiUtils.initPlatformState(fcmToken);
///
/// // Date operations
/// final formatted = UiUtils.changeDateFormat(date: DateTime.now(), outputFormat: 'yyyy-MM-dd');
/// final timeAgo = UiUtils.timeAgoSinceDate('2023-01-01');
///
/// // File operations
/// final file = await UiUtils.pickImage(ImageSource.gallery);
/// final images = await UiUtils.pickMultipleImage();
/// final result = await UiUtils.pickFile();
///
/// // Toast operations
/// UiUtils.showToast(message: 'Hello World!');
/// ```
class UiUtils {
  // ============================================================================
  // DEVICE UTILITIES
  // ============================================================================

  /// Sets the status bar to dark theme
  static void darkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Sets the status bar to light theme
  static void lightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.white,
      ),
    );
  }

  /// Locks the screen orientation to portrait mode
  static void screenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Gets the current device type (Android or iOS)
  static String getDeviceType() {
    return Platform.isAndroid ? 'Android' : 'iOS';
  }

  /// Hides the keyboard
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Initializes platform state and returns device information
  static Future<Map<String, String>> initPlatformState(String fcmToken) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final RxString deviceId = ''.obs;
    final RxString deviceName = ''.obs;
    final RxString deviceType = ''.obs;
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidDeviceInfo = (await deviceInfoPlugin.androidInfo);
        deviceId.value = androidDeviceInfo.id;
        deviceName.value = androidDeviceInfo.brand;
        deviceType.value = 'Android';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosDeviceInfo = (await deviceInfoPlugin.iosInfo);
        deviceId.value = iosDeviceInfo.identifierForVendor ?? '';
        deviceName.value = iosDeviceInfo.modelName;
        deviceType.value = iosDeviceInfo.systemName;
      }

      Preferences.deviceId = deviceId.value;
      Preferences.deviceName = deviceName.value;
      Preferences.deviceToken = fcmToken;

      debugPrint('device_name: ${deviceName.value}');
      debugPrint('device_type: ${deviceType.value}');
      debugPrint('device_id: ${deviceId.value}');
      debugPrint('device_token: $fcmToken');
    } catch (e) {
      debugPrint(e.toString());
    }

    return {
      'device_id': deviceId.value,
      'device_token': deviceId.value,
      'device_name': deviceType.value,
      'device_type': deviceType.value,
    };
  }

  // ============================================================================
  // DATE UTILITIES
  // ============================================================================

  /// Converts duration string to minutes format
  static String convertDurationToMinutes(String text) {
    const String data = '00:00:30';
    final List<String> splitData = data.toString().split(':');
    final int result = (int.parse(splitData[0].toString()) * 60) + int.parse(splitData[1].toString());
    int duration = result;
    if (splitData[2].toString() != '0') {
      duration = result + 1;
    }
    return '$duration Min';
  }

  /// Changes date format to specified output format
  static String changeDateFormat({DateTime? date, String? outputFormat}) {
    if (date != null && outputFormat != null) {
      final DateFormat formatter = DateFormat(outputFormat);
      final String formatted = formatter.format(date);
      return formatted;
    }
    return 'N/A';
  }

  /// Converts UTC datetime string to local datetime string
  static String utcToLocal(String utcDateTime) {
    final DateTime dateTime = DateTime.parse(utcDateTime).toLocal();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  /// Returns time ago string from a date string
  static String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    final DateTime dateUtc = DateTime.parse(dateString);
    final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateUtc.toString(), true);
    final DateTime date = dateTime.toLocal();
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return (numericDates) ? '${(difference.inDays / 365).floor()} Y' : '${(difference.inDays / 365).floor()} Years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 Y' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} M';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 M' : 'Last Month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return (numericDates) ? '${(difference.inDays / 7).floor()} w' : '${(difference.inDays / 7).floor()} Weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 w' : 'Last week';
    } else if (difference.inDays >= 2) {
      return (numericDates) ? '${difference.inDays} d' : '${difference.inDays} Days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} min';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} sec';
    } else {
      return 'now';
    }
  }

  // ============================================================================
  // FILE UTILITIES
  // ============================================================================

  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified source (gallery or camera)
  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(source: source, requestFullMetadata: false);
      if (xFile != null) {
        return xFile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Picks multiple images and returns them as base64 strings
  static Future<List<String>> pickMultipleImage() async {
    try {
      final List<XFile> xFile = await _picker.pickMultiImage();
      if (xFile.isNotEmpty) {
        final List<String> images = xFile.map((e) {
          final String base64String = base64Encode(File(e.path).readAsBytesSync());
          return 'data:image/png;base64,$base64String';
        }).toList();
        return images;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Picks a file (currently supports PDF files)
  static Future<Result<PlatformFile, String>> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: false);
      if (result != null) {
        return Success(result.files.first);
      }
      return Failure('Please select a file');
    } catch (e) {
      return Failure('Please select a file');
    }
  }

  /// Gets the download folder path for the current platform
  static Future<String> getDownloadFolderPath() async {
    Directory? downloadDir;
    if (Platform.isAndroid) {
      downloadDir = await getDownloadsDirectory();
    } else if (Platform.isIOS) {
      downloadDir = await getApplicationDocumentsDirectory();
    }
    if (downloadDir == null) {
      throw Exception('Failed to get download folder path.');
    }
    return downloadDir.path;
  }

  /// Converts a ui.Image to base64 string
  static Future<String?> imageToBase64(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final String base64Image = base64Encode(pngBytes);
    return base64Image;
  }

  // ============================================================================
  // TOAST UTILITIES
  // ============================================================================

  /// Shows a toast message at the bottom of the screen
  static void showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.white,
      backgroundColor: AppColors.primaryColor,
    );
  }
}
