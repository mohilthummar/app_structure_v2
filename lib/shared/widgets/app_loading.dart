import 'package:flutter/material.dart';

import 'package:app_structure/core/constants/app_colors.dart';

/// Centered spinner. Default loading state for `StateSwitch`.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.color, this.size = 24});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color ?? AppColors.primaryColor,
      ),
    ),
  );
}
