import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_typography.dart';

/// Centered empty / error placeholder. Default empty state for `StateSwitch`.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(AppDimensions.spacing24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: AppDimensions.spacing48.w,
            color: iconColor ?? AppColors.emptyStateIcon,
          ),
          SizedBox(height: AppDimensions.spacing12.h),
          Text(
            title,
            style: AppTypography.mdSemibold.copyWith(fontSize: AppTypography.mdSemibold.fontSize!.sp),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppDimensions.spacing4.h),
            Text(
              subtitle!,
              style: AppTypography.sm.copyWith(
                fontSize: AppTypography.sm.fontSize!.sp,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}
