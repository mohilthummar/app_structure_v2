import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/data/repositories/auth_repository.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:app_structure/view/auth_flow/sign_in/components/otp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  GlobalKey<FormState> singUpFormKey = GlobalKey<FormState>();

  TextEditingController yourNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  final AuthRepository authRepository = AuthRepository();

  RxBool isLoading = false.obs;
  RxBool isResendLoading = false.obs;

  Future<void> onSignUp(BuildContext context) async {
    if (singUpFormKey.currentState?.validate() ?? false) {
      FocusManager.instance.primaryFocus?.unfocus();

      Map<String, dynamic> data = {
        'name': yourNameController.text.trim(),
        'mobileNumber': phoneNumberController.text.trim(),
        'address': addressController.text.trim(),
      };
      isLoading(true);
      final result = await authRepository.signUp(data: data);
      isLoading(false);

      result.when(
        (value) {
          showDialog(
            context: context,
            builder: (context) => OtpDialog(
              otpController: otpController,
              isLoading: isLoading,
              isResendLoading: isResendLoading,
              onResend: onResend,
              onVerify: onVerify,
            ),
          );
        },
        (error) => AppSnackBar.error(message: error),
      );
    }
  }

  Future<void> onVerify() async {
    Map<String, dynamic> data = {
      'mobileNumber': phoneNumberController.text.trim(),
      'otp': otpController.text.trim(),
    };

    isLoading(true);
    final result = await authRepository.validateSignUpOtp(data: data);
    isLoading(false);

    result.when(
      (value) {
        Get.back();
        // Handle successful signup
        if (value.data != null) {
          // Parse user data from response
          // final user = User.fromJson(value.data);
          // Preferences.user = user;
          // Preferences.isLogged = true;
          // Preferences.token = user.token;
        }
        Get.offAllNamed(RoutesName.signInView);
      },
      (error) => AppSnackBar.error(message: error),
    );
  }

  Future<void> onResend() async {
    Map<String, dynamic> data = {
      'mobileNumber': phoneNumberController.text.trim(),
    };
    isResendLoading(true);
    final result = await authRepository.resendOtp(data: data);
    isResendLoading(false);

    result.when(
      (value) => AppSnackBar.success(message: "OTP sent successfully"),
      (error) => AppSnackBar.error(message: error),
    );
  }
}
