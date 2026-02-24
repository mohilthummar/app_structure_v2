import 'package:app_structure/core/storage/preferences.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final AuthRepository _repository;

  SignUpController(this._repository);

  GlobalKey<FormState> singUpFormKey = GlobalKey<FormState>();

  TextEditingController yourNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isResendLoading = false.obs;

  /// Returns true if sign-up succeeded and the OTP dialog should be shown.
  Future<bool> onSignUp() async {
    if (singUpFormKey.currentState?.validate() ?? false) {
      FocusManager.instance.primaryFocus?.unfocus();

      isLoading.value = true;

      try {
        await _repository.signUp(
          name: yourNameController.text.trim(),
          mobileNumber: phoneNumberController.text.trim(),
          address: addressController.text.trim(),
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
      final user = await _repository.validateSignUpOtp(
        mobileNumber: phoneNumberController.text.trim(),
        otp: otpController.text.trim(),
      );

      isLoading.value = false;
      Get.back();
      // Handle successful signup
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
    yourNameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
