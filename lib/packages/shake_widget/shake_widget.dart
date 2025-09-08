import 'package:flutter/material.dart';

class ShakeWidget extends StatelessWidget {
  final Duration duration;
  final double deltaX;
  final Widget child;
  final Curve curve;
  final VoidCallback? onEnd;

  const ShakeWidget({
    super.key,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 20,
    this.curve = Curves.bounceOut,
    required this.child,
    this.onEnd,
  });

  /// convert 0-1 to 0-1-0
  double shake(double animation) => 2 * (0.5 - (0.5 - curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: key,
      onEnd: onEnd,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, animation, child) => Transform.translate(
        offset: Offset(deltaX * shake(animation), 0),
        child: child,
      ),
      child: child,
    );
  }
}
