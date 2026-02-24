import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/mixins/validation_mixin.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/features/auth/presentation/shared/otp_dialog.dart';
import 'package:app_structure/features/auth/presentation/sign_up/sign_up_controller.dart';
import 'package:app_structure/shared/widgets/app_app_bar.dart';
import 'package:app_structure/shared/widgets/app_button.dart';
import 'package:app_structure/shared/widgets/app_text_field.dart';
import 'package:app_structure/shared/widgets/screen_header.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpView extends GetView<SignUpController> with ValidationMixin {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding).copyWith(top: 0),
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        clipBehavior: Clip.antiAlias,
        child: Form(
          key: controller.singUpFormKey,
          child: Column(
            children: [
              const ScreenHeader(
                title: AppStrings.signUp,
                subtitle: AppStrings.createYourAccountToGetStarted,
              ),

              // Name text field view
              AppTextField(
                label: AppStrings.fullName,
                hintText: AppStrings.enterYourFullName,
                keyboardType: TextInputType.name,
                controller: controller.yourNameController,
                validator: nameValidator,
              ),

              14.verticalSpace,

              // Phone Number Text Filed view
              AppTextField(
                label: AppStrings.phoneNumber,
                hintText: AppStrings.enterYourPhoneNumber,
                keyboardType: TextInputType.phone,
                controller: controller.phoneNumberController,
                validator: (value) {
                  return phoneValidator(value, 10);
                },
              ),

              14.verticalSpace,

              // Address Text Filed view
              AppTextField(
                label: AppStrings.password,
                hintText: AppStrings.enterYourPassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                obscureText: true,
                controller: controller.addressController,
                validator: passwordValidator,
              ),

              36.verticalSpace,

              // Sign Up Button view
              Obx(
                () => AppButton(
                  onPressed: () async {
                    final shouldShowOtp = await controller.onSignUp();
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
                  label: AppStrings.signUp,
                  isLoading: controller.isLoading.value,
                ),
              ),

              28.verticalSpace,

              // Already Have An Account view
              RichText(
                text: TextSpan(
                  text: AppStrings.doNotHaveAnAccount,
                  style: TextStyle(
                    color: AppColors.darkGreyTextColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: ' ${AppStrings.signIn}',
                      recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
