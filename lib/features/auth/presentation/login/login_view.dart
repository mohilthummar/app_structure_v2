import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/utils/validators.dart';
import 'package:app_structure/features/auth/presentation/login/login_controller.dart';
import 'package:app_structure/shared/widgets/app_button.dart';
import 'package:app_structure/shared/widgets/app_text_field.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing20.w),
          child: Form(
            key: controller.loginFormKey,
            child: ListView(
              children: [
                SizedBox(height: AppDimensions.spacing40.h),
                AppText(
                  I18n.signIn.tr,
                  textSize: TextSize.headline_24,
                  textWeight: TextWeight.w600,
                  textColor: AppColors.primaryTextColor,
                ),
                SizedBox(height: AppDimensions.spacing24.h),

                AppTextField(
                  controller: controller.emailController,
                  hintText: I18n.email.tr,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                SizedBox(height: AppDimensions.spacing16.h),

                Obx(
                  () => AppTextField(
                    controller: controller.passwordController,
                    hintText: I18n.password.tr,
                    obscureText: controller.isPasswordHidden.value,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: controller.onTogglePassword,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spacing8.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.onForgotPassword,
                    child: Text(I18n.forgotPassword.tr),
                  ),
                ),
                SizedBox(height: AppDimensions.spacing24.h),

                Obx(
                  () => AppButton(
                    label: I18n.signIn.tr,
                    onPressed: controller.onLogin,
                    isLoading: controller.state.value == ViewState.loading,
                  ),
                ),
                SizedBox(height: AppDimensions.spacing16.h),
                TextButton.icon(
                  onPressed: () => Get.toNamed<void>(RouteNames.showcase),
                  icon: const Icon(Icons.widgets_outlined),
                  label: Text(I18n.showcase.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
