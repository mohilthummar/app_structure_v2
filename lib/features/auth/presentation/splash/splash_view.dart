import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/constants/app_assets.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
            const AppText(
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
