import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/constants/app_assets.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            // AppAssets.splashIcon is an SVG — must use SvgPicture, not
            // Image.asset (the raster decoder throws "Invalid image data"
            // on SVG bytes). For new screens prefer `AppImageView`, which
            // auto-detects asset type by extension.
            SvgPicture.asset(
              AppAssets.splashIcon,
              width: Get.width * 0.6,
              height: Get.width * 0.6,
            ),
            SizedBox(height: 40.h),
            AppText(
              I18n.appName.tr,
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
