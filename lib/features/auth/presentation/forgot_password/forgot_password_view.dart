import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/utils/validators.dart';
import 'package:app_structure/features/auth/presentation/forgot_password/forgot_password_controller.dart';
import 'package:app_structure/shared/widgets/app_button.dart';
import 'package:app_structure/shared/widgets/app_text_field.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing20.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppDimensions.spacing24.h),
                const AppText.multiLine(
                  'Enter your email and we will send a reset link.',
                  textSize: TextSize.medium_14,
                ),
                SizedBox(height: AppDimensions.spacing16.h),

                AppTextField(
                  controller: controller.emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                SizedBox(height: AppDimensions.spacing24.h),

                Obx(
                  () => AppButton(
                    label: 'Send reset link',
                    onPressed: controller.onSend,
                    isLoading: controller.state.value == ViewState.loading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
