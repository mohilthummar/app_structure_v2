import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._repo);

  final AuthRepository _repo;

  final state = ViewState.idle.obs;
  final errorMessage = ''.obs;

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<bool> onSend() async {
    if (formKey.currentState?.validate() != true) return false;

    state.value = ViewState.loading;
    try {
      await _repo.forgotPassword(emailController.text.trim());
      state.value = ViewState.success;
      AppSnackBar.success(message: 'Reset link sent. Check your email.');
      Get.back();
      return true;
    } catch (e) {
      state.value = ViewState.error;
      errorMessage.value = e.toString();
      AppSnackBar.error(message: e.toString());
      return false;
    }
  }
}
