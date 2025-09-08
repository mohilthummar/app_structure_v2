import 'package:app_structure/data/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../data/constants/app_colors.dart';
import '../themes/app_text.dart';

/// Types of snackbars supported by [AppSnackBar].
enum SnackBarType { success, info, warning, error }

/// A utility for showing consistent, themed snackbars throughout the app.
///
/// Usage:
/// ```dart
/// AppSnackBar.success(message: 'Operation successful!');
/// AppSnackBar.error(message: 'Something went wrong.');
/// AppSnackBar.info(message: 'This is an info message.');
/// AppSnackBar.warning(message: 'This is a warning.');
///
/// // Custom usage:
/// AppSnackBar.show(
///   message: 'Custom message',
///   type: SnackBarType.success,
///   onPress: () { /* ... */ },
///   buttonText: 'Undo',
///   bottomPadding: false,
/// );
/// ```
class AppSnackBar {
  static RxBool isSnackBarOpen = false.obs;

  /// Closes any open snackbar.
  static void closeSnackbar() {
    if (isSnackBarOpen.value) {
      Get.closeAllSnackbars();
    }
  }

  /// Shows a themed snackbar of the given [type].
  /// See [SnackBarType] for available types.
  static void show({required String message, SnackBarType type = SnackBarType.info, void Function()? onPress, String? buttonText, bool bottomPadding = true}) {
    closeSnackbar();

    // Defaults
    Color borderColor = Colors.grey;
    Color backgroundColor = Colors.white;
    Widget? icon;
    String title = '';

    switch (type) {
      case SnackBarType.success:
        borderColor = const Color(0xFF32BC32);
        backgroundColor = const Color(0xFFEAF8EA);
        icon = const Icon(CupertinoIcons.check_mark_circled, color: AppColors.black);
        title = 'Success';
        break;
      case SnackBarType.info:
        borderColor = const Color(0xFF47AFFF);
        backgroundColor = const Color(0xFFEDF7FF);
        icon = const Icon(CupertinoIcons.info, color: AppColors.black);
        title = 'Info';
        break;
      case SnackBarType.warning:
        borderColor = const Color(0xFFFFB600);
        backgroundColor = const Color(0xFFFFF8E5);
        icon = SvgPicture.asset(AppAssets.icWarning, height: 18.h);
        title = 'Warning';
        break;
      case SnackBarType.error:
        borderColor = const Color(0xFFFF3A30);
        backgroundColor = const Color(0xFFFFEBEA);
        icon = const Icon(CupertinoIcons.clear_circled, color: AppColors.black);
        title = 'Error';
        break;
    }

    Get.snackbar(
      title,
      message,
      messageText: AppText.multiLine(message, textWeight: TextWeight.w500, textColor: AppColors.black),
      borderRadius: 10,
      borderWidth: 1.4,
      shouldIconPulse: false,
      colorText: AppColors.black,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.BOTTOM,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      icon: icon,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(top: 6),
      margin: const EdgeInsets.symmetric(horizontal: 32).copyWith(bottom: bottomPadding ? 70 : 0),
      mainButton: onPress == null
          ? null
          : TextButton(
              onPressed: onPress,
              child: AppText(buttonText ?? "Open", textWeight: TextWeight.w600),
            ),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.OPEN || status == SnackbarStatus.OPENING) {
          isSnackBarOpen(true);
        } else if (status == SnackbarStatus.CLOSED) {
          isSnackBarOpen(false);
        }
      },
    );
  }

  /// Shows a success snackbar.
  static void success({required String message, bool bottomPadding = true}) => show(
    message: message,
    type: SnackBarType.success,
    bottomPadding: bottomPadding, //
  );

  /// Shows an info snackbar.
  static void info({required String message, void Function()? onPress, String? buttonText, bool bottomPadding = true}) => show(
    message: message,
    type: SnackBarType.info,
    onPress: onPress,
    buttonText: buttonText,
    bottomPadding: bottomPadding, //
  );

  /// Shows a warning snackbar.
  static void warning({required String message, void Function()? onPress, String? buttonText, bool bottomPadding = true}) => show(
    message: message,
    type: SnackBarType.warning,
    onPress: onPress,
    buttonText: buttonText,
    bottomPadding: bottomPadding, //
  );

  /// Shows an error snackbar.
  static void error({required String message, void Function()? onPress, String? buttonText, bool bottomPadding = true}) => show(
    message: message,
    type: SnackBarType.error,
    onPress: onPress,
    buttonText: buttonText,
    bottomPadding: bottomPadding, //
  );
}
