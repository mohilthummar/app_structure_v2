import 'package:app_structure/core/themes/app_style.dart';
import 'package:app_structure/core/themes/app_text.dart';
import 'package:app_structure/core/utils/validation_mixin.dart';
import 'package:app_structure/data/constants/app_colors.dart';
import 'package:app_structure/data/constants/app_strings.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:app_structure/widgets/app_app_bar.dart';
import 'package:app_structure/widgets/app_button.dart';
import 'package:app_structure/widgets/app_text_field.dart';
import 'package:app_structure/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'sign_in_controller.dart';

class SignInView extends GetView<SignInController> with ValidationMixin {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(showBack: false),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(defaultPadding).copyWith(top: 0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        clipBehavior: Clip.antiAlias,
        child: Form(
          key: controller.signInFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Screen Header
              ScreenHeader(
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
                  onPressed: () => controller.onSignIn(context),
                  label: AppStrings.signIn,
                  isLoading: controller.isLoading.value,
                ),
              ),

              12.verticalSpace,

              // Did not have account view
              AppText(
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
                child: AppText(
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
