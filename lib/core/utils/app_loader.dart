import 'dart:ui';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';

/// Full-screen blurred overlay with a centred spinner + label.
///
/// Use as a route-blocking modal while a long-running action runs. Wrap
/// in a `WillPopScope` (or open with `barrierDismissible: false`) when
/// you don't want the user dismissing it accidentally.
///
/// Usage:
/// ```dart
/// // Block the screen while uploading.
/// showDialog<void>(
///   context: context,
///   barrierDismissible: false,
///   builder: (_) => const AppLoader(label: 'Uploading...'),
/// );
///
/// // Inline / hero overlay.
/// const AppLoader(label: 'Processing...', loaderColor: Colors.blue);
/// ```
class AppLoader extends StatelessWidget {
  /// Caption shown next to the spinner.
  final String label;

  /// Spinner colour. Falls back to `Theme.of(context).primaryColor`.
  final Color? loaderColor;

  /// Card background. Falls back to `AppColors.containerFillColor`.
  final Color? backgroundColor;

  /// Backdrop blur sigma. Higher → more blur. Default `4.0`.
  final double blurSigma;

  /// Override width. Defaults to the parent's full width.
  final double? width;

  /// Override height. Defaults to the parent's full height.
  final double? height;

  /// Generic loader.
  const AppLoader({
    super.key,
    this.label = 'Loading...',
    this.loaderColor,
    this.backgroundColor,
    this.blurSigma = 4.0,
    this.width,
    this.height,
  });

  /// Preset for file-download flows.
  const AppLoader.download({super.key}) : label = 'Downloading...', loaderColor = null, backgroundColor = null, blurSigma = 4.0, width = null, height = null;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: height ?? size.height,
      width: width ?? size.width,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(color: backgroundColor ?? AppColors.containerFillColor, borderRadius: BorderRadius.circular(defaultPadding)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularLoader(color: loaderColor ?? Theme.of(context).primaryColor),
                const SizedBox(width: 14),
                AppText(label, textSize: TextSize.medium_14, textColor: AppColors.primaryTextColor, textWeight: TextWeight.w500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Plain circular progress indicator with stroke + colour overrides.
///
/// Reach for this when you need a spinner inside a button or row — for
/// a full-screen overlay use [AppLoader].
///
/// Usage:
/// ```dart
/// const CircularLoader(loaderSize: 18);
/// ```
class CircularLoader extends StatelessWidget {
  /// Stroke colour. Falls back to `AppColors.white`.
  final Color? color;

  /// Square spinner size in logical px. Default `20.h`.
  final double? loaderSize;

  /// Creates a [CircularLoader].
  const CircularLoader({super.key, this.color, this.loaderSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (loaderSize ?? 20.h),
      height: (loaderSize ?? 20.h),
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.white), strokeCap: StrokeCap.round, strokeWidth: 2),
    );
  }
}
