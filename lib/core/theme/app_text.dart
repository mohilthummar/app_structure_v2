import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_colors.dart';

/// Enum defining different text sizes available in the app
/// Each size corresponds to a specific font size in logical pixels
enum TextSize {
  extraSmall_10, // 10sp - for very small text like captions
  small_12, // 12sp - for small text like body text
  medium_14, // 14sp - for medium text like descriptions
  large_16, // 16sp - for large text like subheadings
  title_18, // 18sp - for titles
  largeTitle_20, // 20sp - for large titles
  headline_24, // 24sp - for headlines
}

/// Enum defining different font weights available in the app
enum TextWeight {
  w400, // Normal weight
  w500, // Medium weight
  w600, // Semi-bold weight
}

/// A customizable text widget that provides consistent typography across the app
///
/// This widget wraps Flutter's Text widget with predefined styles and sizes
/// to maintain consistency throughout the application. It supports various
/// text sizes, weights, colors, and alignment options.
///
/// Example usage:
/// ```dart
/// AppText(
///   'Hello World',
///   textSize: TextSize.large_16,
///   textWeight: TextWeight.w500,
///   textColor: Colors.blue,
/// )
/// ```
class AppText extends StatelessWidget {
  /// The text content to display
  final String text;

  /// The size of the text (defaults to small_12)
  final TextSize? textSize;

  /// The weight of the text (defaults to w400)
  final TextWeight? textWeight;

  /// The color of the text (defaults to AppColors.primaryTextColor)
  final Color? textColor;

  /// Whether the text should support multiple lines (defaults to false)
  final bool? multiLine;

  /// The alignment of the text (defaults to TextAlign.left)
  final TextAlign? textAlign;

  /// Text decoration like underline, strikethrough, etc.
  final TextDecoration? textDecoration;

  /// Maximum number of lines for the text (null for unlimited)
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow? overflow;

  /// Constructor for single-line text
  const AppText(
    this.text, {
    super.key,
    this.textSize = TextSize.small_12,
    this.textWeight = TextWeight.w400,
    this.textColor = AppColors.primaryTextColor,
    this.multiLine = false,
    this.textAlign = TextAlign.left,
    this.textDecoration,
    this.maxLines,
    this.overflow, //
  });

  /// Constructor for multi-line text
  const AppText.multiLine(
    this.text, {
    super.key,
    this.textSize = TextSize.small_12,
    this.textWeight = TextWeight.w400,
    this.textColor = AppColors.primaryTextColor,
    this.textAlign = TextAlign.left,
    this.textDecoration,
    this.maxLines,
    this.overflow, //
  }) : multiLine = true;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines ?? (multiLine! ? null : 1),
      textAlign: textAlign,
      overflow: overflow ?? (multiLine! ? TextOverflow.visible : TextOverflow.ellipsis),
      style: textStyle!.copyWith(color: textColor, fontWeight: fontWeight, decoration: textDecoration ?? TextDecoration.none),
    );
  }

  /// Returns the appropriate FontWeight based on the textWeight enum
  FontWeight? get fontWeight {
    switch (textWeight) {
      case TextWeight.w400:
        return FontWeight.w400;
      case TextWeight.w500:
        return FontWeight.w500;
      case TextWeight.w600:
        return FontWeight.w600;
      default:
        return FontWeight.w400;
    }
  }

  /// Returns the appropriate TextStyle based on the textSize enum
  /// Uses Flutter's built-in text theme as a base and applies custom font sizes
  TextStyle? get textStyle {
    switch (textSize) {
      case TextSize.extraSmall_10:
        return Theme.of(Get.context!).textTheme.bodySmall!.copyWith(fontSize: 10.sp);
      case TextSize.small_12:
        return Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(fontSize: 12.sp);
      case TextSize.medium_14:
        return Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(fontSize: 14.sp);
      case TextSize.large_16:
        return Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(fontSize: 16.sp);
      case TextSize.title_18:
        return Theme.of(Get.context!).textTheme.titleMedium!.copyWith(fontSize: 18.sp);
      case TextSize.largeTitle_20:
        return Theme.of(Get.context!).textTheme.titleLarge!.copyWith(fontSize: 20.sp);
      case TextSize.headline_24:
        return Theme.of(Get.context!).textTheme.headlineSmall!.copyWith(fontSize: 24.sp);
      default:
        return Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(fontSize: 12.sp);
    }
  }
}
