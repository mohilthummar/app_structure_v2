import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/mixins/validation_mixin.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/features/auth/presentation/shared/otp_dialog.dart';
import 'package:app_structure/features/auth/presentation/sign_in/sign_in_controller.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:app_structure/shared/widgets/app_app_bar.dart';
import 'package:app_structure/shared/widgets/app_button.dart';
import 'package:app_structure/shared/widgets/app_text_field.dart';
import 'package:app_structure/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignInView extends GetView<SignInController> with ValidationMixin {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(showBack: false),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(defaultPadding).copyWith(top: 0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        clipBehavior: Clip.antiAlias,
        child: Form(
          key: controller.signInFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Screen Header
              const ScreenHeader(
                title: AppStrings.signIn,
                subtitle: AppStrings.pleaseEnterYourCredentialsToProceed,
              ),

              // Phone Text filed view
              AppTextField(
                controller: controller.phoneNumberController,
                label: AppStrings.phoneNumber,
                hintText: AppStrings.enterYourPhoneNumber,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  return phoneValidator(value, 10);
                },
              ),

              36.verticalSpace,

              // Sign in Button view
              Obx(
                () => AppButton(
                  onPressed: () async {
                    final shouldShowOtp = await controller.onSignIn();
                    if (context.mounted && shouldShowOtp) {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => OtpDialog(
                          otpController: controller.otpController,
                          isLoading: controller.isLoading,
                          isResendLoading: controller.isResendLoading,
                          onResend: controller.onResend,
                          onVerify: controller.onVerify,
                        ),
                      );
                    }
                  },
                  label: AppStrings.signIn,
                  isLoading: controller.isLoading.value,
                ),
              ),

              12.verticalSpace,

              // Did not have account view
              const AppText(
                AppStrings.doNotHaveAnAccount,
                textColor: AppColors.darkGreyTextColor,
                textSize: TextSize.small_12,
                textWeight: TextWeight.w600,
              ),

              12.verticalSpace,

              // Sign Up Text Button
              InkWell(
                onTap: () {
                  Get.toNamed(RoutesName.signUpView);
                },
                child: const AppText(
                  AppStrings.signUp,
                  textColor: AppColors.primaryColor,
                  textSize: TextSize.small_12,
                  textWeight: TextWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
