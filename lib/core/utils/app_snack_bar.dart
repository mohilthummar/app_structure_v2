import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_assets.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';

/// Snackbar types supported by [AppSnackBar].
enum SnackBarType { success, info, warning, error }

/// A utility for showing consistent, themed snackbars throughout the app.
///
/// All colors come from `AppColors`, all sizing from `AppDimensions`,
/// typography from `AppText`. Never inline `Color(0xFF…)` or raw numbers.
///
/// Usage:
/// ```dart
/// AppSnackBar.success(message: 'Operation successful!');
/// AppSnackBar.error(message: 'Something went wrong.');
/// AppSnackBar.info(message: 'This is an info message.');
/// AppSnackBar.warning(message: 'This is a warning.');
/// ```
class AppSnackBar {
  AppSnackBar._();

  static final RxBool isSnackBarOpen = false.obs;

  /// Closes any open snackbar.
  static void closeSnackbar() {
    if (isSnackBarOpen.value) {
      Get.closeAllSnackbars();
    }
  }

  /// Shows a themed snackbar of the given [type].
  static void show({
    required String message,
    SnackBarType type = SnackBarType.info,
    void Function()? onPress,
    String? buttonText,
    bool bottomPadding = true,
  }) {
    closeSnackbar();

    final Color borderColor;
    final Color backgroundColor;
    final Widget icon;
    final String title;

    switch (type) {
      case SnackBarType.success:
        borderColor = AppColors.toastSuccess;
        backgroundColor = AppColors.successBg;
        icon = const Icon(CupertinoIcons.check_mark_circled, color: AppColors.black);
        title = 'Success';
        break;
      case SnackBarType.info:
        borderColor = AppColors.toastInfo;
        backgroundColor = AppColors.infoBg;
        icon = const Icon(CupertinoIcons.info, color: AppColors.black);
        title = 'Info';
        break;
      case SnackBarType.warning:
        borderColor = AppColors.toastWarning;
        backgroundColor = AppColors.warningBg;
        icon = SvgPicture.asset(AppAssets.icWarning, height: 18.h);
        title = 'Warning';
        break;
      case SnackBarType.error:
        borderColor = AppColors.toastError;
        backgroundColor = AppColors.errorBg;
        icon = const Icon(CupertinoIcons.clear_circled, color: AppColors.black);
        title = 'Error';
        break;
    }

    Get.snackbar(
      title,
      message,
      messageText: AppText.multiLine(
        message,
        textWeight: TextWeight.w500,
        textColor: AppColors.black,
      ),
      borderRadius: AppDimensions.radius10,
      borderWidth: 1.4,
      shouldIconPulse: false,
      colorText: AppColors.black,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.BOTTOM,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      icon: icon,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ).copyWith(top: AppDimensions.spacing6),
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing32).copyWith(bottom: bottomPadding ? AppDimensions.spacing72 : 0),
      mainButton: onPress == null
          ? null
          : TextButton(
              onPressed: onPress,
              child: AppText(buttonText ?? 'Open', textWeight: TextWeight.w600),
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

  static void success({required String message, bool bottomPadding = true}) => show(
    message: message,
    type: SnackBarType.success,
    bottomPadding: bottomPadding,
  );

  static void info({
    required String message,
    void Function()? onPress,
    String? buttonText,
    bool bottomPadding = true,
  }) => show(
    message: message,
    type: SnackBarType.info,
    onPress: onPress,
    buttonText: buttonText,
    bottomPadding: bottomPadding,
  );

  static void warning({
    required String message,
    void Function()? onPress,
    String? buttonText,
    bool bottomPadding = true,
  }) => show(
    message: message,
    type: SnackBarType.warning,
    onPress: onPress,
    buttonText: buttonText,
    bottomPadding: bottomPadding,
  );

  static void error({
    required String message,
    void Function()? onPress,
    String? buttonText,
    bool bottomPadding = true,
  }) => show(
    message: message,
    type: SnackBarType.error,
    onPress: onPress,
    buttonText: buttonText,
    bottomPadding: bottomPadding,
  );
}
