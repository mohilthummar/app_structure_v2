import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/theme/app_typography.dart';

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

  /// Returns the appropriate TextStyle based on the textSize enum.
  /// Maps each `TextSize` value to an `AppTypography` token and applies
  /// `.sp` scaling from `flutter_screenutil` at the call site.
  TextStyle? get textStyle {
    final base = switch (textSize) {
      TextSize.extraSmall_10 => AppTypography.xxs,
      TextSize.small_12 => AppTypography.xs,
      TextSize.medium_14 => AppTypography.sm,
      TextSize.large_16 => AppTypography.md,
      TextSize.title_18 => AppTypography.base,
      TextSize.largeTitle_20 => AppTypography.lg,
      TextSize.headline_24 => AppTypography.xl,
      _ => AppTypography.xs,
    };
    return base.copyWith(fontSize: base.fontSize!.sp);
  }
}
