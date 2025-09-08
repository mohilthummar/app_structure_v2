import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A scroll behavior that provides iOS-style bouncing on iOS and stretching overscroll on other platforms.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   scrollBehavior: ScrollBehaviorModified(),
///   // ...
/// )
/// ```
class ScrollBehaviorModified extends CupertinoScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return const BouncingScrollPhysics();
    } else {
      return CustomScrollPhysics();
    }
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}

/// Custom scroll physics for non-iOS platforms, providing a bounce effect.
class CustomScrollPhysics extends ClampingScrollPhysics {
  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }
}
