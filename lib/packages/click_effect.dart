import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClickEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ClickEffect({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<ClickEffect> createState() => _ClickEffectState();
}

class _ClickEffectState extends State<ClickEffect> {
  RxBool buttonPress = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.elasticOut,
        tween: buttonPress.isTrue ? Tween(begin: 0.9, end: 0.97) : Tween(begin: 1.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: InkWell(
              onHighlightChanged: (click) {
                buttonPress.value = click;
              },
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              onTap: widget.onTap,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
