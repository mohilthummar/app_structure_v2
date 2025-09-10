import 'package:app_structure/core/themes/app_text.dart';
import 'package:app_structure/data/constants/app_assets.dart';
import 'package:app_structure/data/constants/app_colors.dart';
import 'package:app_structure/data/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.splashIcon,
              width: Get.width * 0.6,
              height: Get.width * 0.6,
            ),
            SizedBox(height: 40.h),
            AppText(
             AppStrings.appName,
              textSize: TextSize.headline_24,
              textWeight: TextWeight.w600,
              textColor: AppColors.primaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
