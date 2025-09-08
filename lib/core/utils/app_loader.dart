import 'dart:ui';

import 'package:app_structure/data/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_style.dart';
import '../themes/app_text.dart';

/// A customizable loader overlay with blur and label.
///
/// Usage:
/// ```dart
/// // Show a loading dialog
/// showDialog(
///   context: context,
///   builder: (_) => const AppLoader(label: 'Loading...'),
/// );
///
/// // Use as a widget
/// AppLoader(label: 'Processing...', loaderColor: Colors.blue)
/// ```
class AppLoader extends StatelessWidget {
  final String label;
  final Color? loaderColor;
  final Color? backgroundColor;
  final double blurSigma;
  final double? width;
  final double? height;

  /// Main constructor for AppLoader.
  const AppLoader({super.key, this.label = 'Loading...', this.loaderColor, this.backgroundColor, this.blurSigma = 4.0, this.width, this.height});

  /// Named constructor for download loader.
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

/// A circular progress indicator with customizable color and size.
///
/// Usage:
/// ```dart
/// CircularLoader(color: Colors.red, loaderSize: 32)
/// ```
class CircularLoader extends StatelessWidget {
  final Color? color;
  final double? loaderSize;

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
