import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/utils/app_loader.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/shared/widgets/app_button.dart';
import 'package:app_structure/shared/widgets/app_pin_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OtpDialog extends StatelessWidget {
  const OtpDialog({
    super.key,
    required this.otpController,
    required this.isLoading,
    required this.isResendLoading,
    required this.onResend,
    required this.onVerify,
  });

  final TextEditingController otpController;
  final RxBool isLoading;
  final RxBool isResendLoading;
  final Function() onResend;
  final void Function() onVerify;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(defaultPadding),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius * 4)),

      // Dialog View
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding * 1.5),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title View
            const AppText(
              AppStrings.enterOtp,
              textSize: TextSize.large_16,
              textWeight: TextWeight.w600,
              textColor: AppColors.whiteTextColor,
            ),
            8.verticalSpace,

            // Sub title view
            const AppText.multiLine(
              AppStrings.pleaseEnterTheOtpSentToYourEmail,
              textSize: TextSize.small_12,
              textColor: AppColors.whiteTextColor,
              textAlign: TextAlign.center,
            ),
            12.verticalSpace,

            // Pin code field view
            AppPinCodeField(controller: otpController, onCompleted: (text) => onVerify()),
            16.verticalSpace,

            // Did not receive code view
            const AppText(
              AppStrings.didNotReceiveTheCode,
              textSize: TextSize.extraSmall_10,
              textColor: AppColors.whiteTextColor,
              textAlign: TextAlign.center,
            ),
            2.verticalSpace,

            // Re send button view
            Obx(() {
              if (isResendLoading.value) {
                return const CircularLoader(color: AppColors.whiteTextColor);
              }

              return GestureDetector(
                onTap: onResend,
                child: const AppText(
                  AppStrings.resendCode,
                  textSize: TextSize.extraSmall_10,
                  textColor: AppColors.whiteTextColor,
                  textDecoration: TextDecoration.underline,
                ),
              );
            }),
            10.verticalSpace,

            // Verify button view
            Obx(
              () => AppButton(
                minimumSize: Size(220.w, 42.h),
                onPressed: onVerify,
                label: AppStrings.verify,
                isLoading: isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
