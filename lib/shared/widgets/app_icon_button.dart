import 'package:app_structure/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final dynamic icon;
  final double? iconSize;
  final Color? iconColor;

  final Color? borderColor;

  final ButtonStyle? decoration;

  const AppIconButton({super.key, required this.onTap, required this.icon, this.iconSize, this.iconColor, this.decoration, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: iconSize == null ? 38.h : iconSize! + 16.h,
      width: iconSize == null ? 38.h : iconSize! + 16.h,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        style: decoration,
        icon: icon is IconData
            ? Icon(icon, size: iconSize ?? 22.h)
            : SvgPicture.asset(
                icon,
                height: iconSize ?? 22.h,
                width: iconSize ?? 22.h,
                colorFilter: ColorFilter.mode(iconColor ?? AppColors.primaryColor, BlendMode.srcIn),
              ),
      ),
    );
  }
}

/// Extension on [AppIconButton] to facilitate inclusion of all types of border style etc
extension IconButtonStyle on AppIconButton {
  static ButtonStyle get outlineBorder => IconButton.styleFrom(
    alignment: Alignment.center,
    side: const BorderSide(color: AppColors.white, width: 1.4),
  );

  static ButtonStyle get fillPrimary => IconButton.styleFrom(alignment: Alignment.center, backgroundColor: AppColors.primaryColor);

  static ButtonStyle get fillContainerColor => IconButton.styleFrom(alignment: Alignment.center, backgroundColor: AppColors.containerFillColor);
}
