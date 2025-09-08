import 'package:app_structure/data/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/themes/app_text.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? showBack;
  final List<Widget>? actions;

  const AppAppBar({super.key, this.title, this.actions, this.showBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      centerTitle: false,
      automaticallyImplyLeading: showBack ?? true,
      titleSpacing: 6.w,
      title: AppText(title ?? "", textSize: TextSize.title_18, textWeight: TextWeight.w600),
      actions: actions ?? [],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
