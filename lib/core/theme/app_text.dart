import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/theme/app_typography.dart';

/// Text size buckets used by [AppText]. Each maps to an [AppTypography]
/// size token; `.sp` scaling is applied at render time.
enum TextSize {
  extraSmall_10,
  small_12,
  medium_14,
  large_16,
  title_18,
  largeTitle_20,
  headline_24,
}

/// Text weight buckets used by [AppText].
enum TextWeight { w400, w500, w600 }

/// App-wide text widget. Wraps Flutter's `Text` with [TextSize] +
/// [TextWeight] tokens so every label, body, and title in the app uses
/// the same scale.
///
/// Reach for the multi-line constructor only when you need wrapping —
/// the default constructor truncates with ellipsis at 1 line.
///
/// Usage:
/// ```dart
/// AppText('Continue', textSize: TextSize.medium_14, textWeight: TextWeight.w500);
/// AppText.multiLine(longBody, textSize: TextSize.medium_14, maxLines: 3);
/// ```
class AppText extends StatelessWidget {
  final String text;
  final TextSize? textSize;
  final TextWeight? textWeight;
  final Color? textColor;
  final bool? multiLine;
  final TextAlign? textAlign;
  final TextDecoration? textDecoration;
  final int? maxLines;
  final TextOverflow? overflow;

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
    this.overflow,
  });

  const AppText.multiLine(
    this.text, {
    super.key,
    this.textSize = TextSize.small_12,
    this.textWeight = TextWeight.w400,
    this.textColor = AppColors.primaryTextColor,
    this.textAlign = TextAlign.left,
    this.textDecoration,
    this.maxLines,
    this.overflow,
  }) : multiLine = true;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines ?? (multiLine! ? null : 1),
      textAlign: textAlign,
      overflow: overflow ?? (multiLine! ? TextOverflow.visible : TextOverflow.ellipsis),
      style: textStyle!.copyWith(
        color: textColor,
        fontWeight: fontWeight,
        decoration: textDecoration ?? TextDecoration.none,
      ),
    );
  }

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
