import 'package:app_structure/core/themes/app_style.dart';
import 'package:app_structure/core/utils/validation_mixin.dart';
import 'package:app_structure/data/constants/app_colors.dart';
import 'package:app_structure/data/constants/app_strings.dart';
import 'package:app_structure/widgets/app_app_bar.dart';
import 'package:app_structure/widgets/app_button.dart';
import 'package:app_structure/widgets/app_text_field.dart';
import 'package:app_structure/widgets/screen_header.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> with ValidationMixin {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding).copyWith(top: 0),
        physics: AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        clipBehavior: Clip.antiAlias,
        child: Form(
          key: controller.singUpFormKey,
          child: Column(
            children: [
              ScreenHeader(
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
                  onPressed: () => controller.onSignUp(context),
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
