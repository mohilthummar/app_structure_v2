import 'package:flutter/material.dart';

class BouncingEffect extends StatefulWidget {
  final Widget child;
  const BouncingEffect({super.key, required this.child});

  @override
  State<BouncingEffect> createState() => _BouncingEffectState();
}

class _BouncingEffectState extends State<BouncingEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);

    _controller.forward().whenComplete(() {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
