import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholders for loading states.
///
/// Two helpers — pick whichever fits the call site:
///
/// * [AppShimmers.wrap] — wrap any widget so it pulses while
///   `showShimmer` is `true`; render normally once it flips to `false`.
/// * [AppShimmers.box] — a plain shimmer rectangle, useful as a stand-in
///   for content that hasn't loaded yet (avatars, lines of text, cards).
///
/// Usage:
/// ```dart
/// AppShimmers.wrap(
///   showShimmer: controller.state.value.isLoading,
///   child: const ProductCard(),
/// );
///
/// AppShimmers.box(height: 16, width: 120);
/// ```
abstract class AppShimmers {
  /// Wraps [child] with a [Shimmer] effect while [showShimmer] is `true`.
  /// Returns the bare [child] otherwise so the same tree can flip between
  /// loading and loaded states without rebuilding.
  static Widget wrap({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    bool showShimmer = true,
  }) {
    if (!showShimmer) return child;
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.withAlpha((255.0 * .2).round()),
      child: child,
    );
  }

  /// A shimmer-friendly rectangle used as a placeholder block. Wrap it
  /// with [wrap] (or build a parent shimmer) to make it pulse.
  static Widget box({
    double? height,
    double? width,
    BorderRadiusGeometry? borderRadius,
    Widget? child,
    Decoration? decoration,
  }) {
    return Container(
      height: height,
      width: width,
      decoration:
          decoration ??
          BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            color: Colors.grey,
          ),
      child: child,
    );
  }
}
