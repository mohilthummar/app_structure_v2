import 'package:app_structure/core/themes/app_style.dart';
import 'package:flutter/material.dart';

class BottomBorderContainer extends StatelessWidget {
  final bool isSelected;
  final Widget child;
  final Color color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AlignmentGeometry? alignment;

  const BottomBorderContainer({
    super.key,
    required this.isSelected,
    required this.child,
    required this.color,
    this.padding,
    this.margin,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(defaultRadius),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                  spreadRadius: 0,
                  color: color,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}
