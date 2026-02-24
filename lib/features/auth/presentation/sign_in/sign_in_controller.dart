import 'package:app_structure/core/storage/preferences.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final AuthRepository _repository;

  SignInController(this._repository);

  GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isResendLoading = false.obs;

  /// Returns true if sign-in succeeded and the OTP dialog should be shown.
  Future<bool> onSignIn() async {
    if (signInFormKey.currentState?.validate() ?? false) {
      FocusManager.instance.primaryFocus?.unfocus();

      isLoading.value = true;

      try {
        // Repository handles Result internally - returns User or throws
        await _repository.signIn(
          mobileNumber: phoneNumberController.text.trim(),
        );

        isLoading.value = false;
        return true;
      } catch (e) {
        isLoading.value = false;
        AppSnackBar.error(message: e.toString());
        return false;
      }
    }
    return false;
  }

  Future<void> onVerify() async {
    isLoading.value = true;

    try {
      final user = await _repository.validateSignInOtp(
        mobileNumber: phoneNumberController.text.trim(),
        otp: otpController.text.trim(),
      );

      isLoading.value = false;
      Get.back();
      // Handle successful login
      Preferences.user = user;
      Preferences.isLogged = true;
      Preferences.token = user.token;
      Get.offAllNamed(RoutesName.signInView);
    } catch (e) {
      isLoading.value = false;
      AppSnackBar.error(message: e.toString());
    }
  }

  Future<void> onResend() async {
    isResendLoading.value = true;

    try {
      await _repository.resendOtp(
        mobileNumber: phoneNumberController.text.trim(),
      );

      isResendLoading.value = false;
      AppSnackBar.success(message: 'OTP sent successfully');
    } catch (e) {
      isResendLoading.value = false;
      AppSnackBar.error(message: e.toString());
    }
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
