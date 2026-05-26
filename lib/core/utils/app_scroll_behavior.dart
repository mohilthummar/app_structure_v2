import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// App-wide scroll behavior — iOS bounce on iOS, stretching overscroll
/// on Android / web / desktop.
///
/// Wire once at the `GetMaterialApp.scrollBehavior` slot. Individual
/// scroll views inherit it; there's no need to set physics per
/// `ListView` / `SingleChildScrollView`.
///
/// Usage:
/// ```dart
/// GetMaterialApp(
///   scrollBehavior: AppScrollBehavior(),
///   home: ...,
/// );
/// ```
class AppScrollBehavior extends CupertinoScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return const BouncingScrollPhysics();
    }
    return const _BounceOnFlingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}

/// Clamping physics that *only* bounces during a fling — keeps Material's
/// edge behaviour intact while still giving the eye a soft endpoint.
class _BounceOnFlingScrollPhysics extends ClampingScrollPhysics {
  const _BounceOnFlingScrollPhysics({super.parent});

  @override
  _BounceOnFlingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _BounceOnFlingScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
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
