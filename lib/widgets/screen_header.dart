import 'package:app_structure/core/themes/app_style.dart';
import 'package:app_structure/core/themes/app_text.dart';
import 'package:app_structure/data/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  title,
                  textSize: TextSize.largeTitle_20,
                  textWeight: TextWeight.w600,
                  textColor: AppColors.primaryTextColor,
                ),
              ),
              if (action != null) action!,
            ],
          ),
          if (subtitle != null) ...[
            8.verticalSpace,
            AppText(
              subtitle!,
              textSize: TextSize.medium_14,
              textWeight: TextWeight.w400,
              textColor: AppColors.darkGreyTextColor,
            ),
          ],
        ],
      ),
    );
  }
}
