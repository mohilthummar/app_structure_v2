import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer utilities for loading placeholders.
///
/// Usage:
/// ```dart
/// // Wrap any widget with shimmer effect
/// shimmerWrapper(child: MyWidget(), showShimmer: isLoading);
///
/// // Use a shimmer container as a placeholder
/// shimmerContainer(height: 20, width: 100);
/// ```
///
/// Use shimmerWrapper for custom widgets, shimmerContainer for simple rectangles.
Widget shimmerWrapper({
  required Widget child,
  Color? baseColor,
  Color? highlightColor,
  bool showShimmer = true,
}) {
  if (showShimmer) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.withAlpha((255.0 * .2).round()),
      child: child,
    );
  } else {
    return child;
  }
}

Widget shimmerContainer({
  double? height,
  double? width,
  BorderRadiusGeometry? borderRadius,
  Widget? child,
  Decoration? decoration,
}) {
  return Container(
    height: height,
    width: width,
    decoration: decoration ??
        BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8.0),
          color: Colors.grey,
        ),
    child: child,
  );
}

// Deprecated: Use shimmer_utils.dart instead of simmer_utils.dart
