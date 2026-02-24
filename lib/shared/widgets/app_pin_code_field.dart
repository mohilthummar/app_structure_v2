import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AppPinCodeField extends StatelessWidget {
  final TextEditingController? controller;

  final String? label;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool? autoFocus;
  final MainAxisAlignment? mainAxisAlignment;
  final void Function(String)? onChanged;
  final void Function(String)? onCompleted;
  final FormFieldValidator<String>? validator;

  const AppPinCodeField({
    super.key,
    this.controller,
    this.label,
    this.textStyle,
    this.hintStyle,
    this.autoFocus,
    this.mainAxisAlignment,
    this.validator,
    this.onChanged,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[AppText(label!, textColor: AppColors.darkGreyTextColor), 4.verticalSpace],
        PinCodeTextField(
          length: 4,
          appContext: context,
          controller: controller,

          /// Box Decorations
          autoFocus: autoFocus ?? true,
          enableActiveFill: true,
          autoDisposeControllers: false,
          cursorHeight: 20.h,
          cursorWidth: 1.4,
          cursorColor: AppColors.primaryColor,
          animationCurve: Curves.easeInOut,
          animationType: AnimationType.scale,
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,

          errorTextSpace: 22.h,

          /// OTP text style
          textStyle: textStyle ?? Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.primaryColor),
          hintStyle: hintStyle ?? Theme.of(context).textTheme.titleLarge,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],

          /// Box separator builder
          separatorBuilder: (context, index) => 14.horizontalSpace,

          pinTheme: PinTheme(
            /// Box size and look
            fieldHeight: Get.width < 380 ? 58.h : 48.h,
            fieldWidth: Get.width < 380 ? 60.h : 50.h,
            shape: PinCodeFieldShape.box,

            /// Border
            activeBorderWidth: 1,
            inactiveBorderWidth: 1,
            selectedBorderWidth: 1,
            borderRadius: BorderRadius.circular(defaultRadius),

            /// Border Color
            activeColor: AppColors.primaryColor,
            inactiveColor: AppColors.dividerAndBorderColor,
            selectedColor: AppColors.primaryColor,

            /// Box fill color
            activeFillColor: AppColors.backgroundColor,
            inactiveFillColor: AppColors.backgroundColor,
            selectedFillColor: AppColors.backgroundColor,

            /// Box shadow
            activeBoxShadow: [
              const BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 0,
                spreadRadius: 0,
                color: AppColors.primaryColor,
              ),
            ],
          ),

          /// OnChanged, Validators, and OnComplete getter
          onChanged: onChanged,
          validator: validator,
          onCompleted: onCompleted,
        ),
      ],
    );
  }
}
