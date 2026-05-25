import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/base/base_controller.dart';
import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';

class ForgotPasswordController extends BaseController {
  ForgotPasswordController(this._repo);

  final AuthRepository _repo;

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<bool> onSend() async {
    if (formKey.currentState?.validate() != true) return false;

    await runGuarded(
      () => _repo.forgotPassword(emailController.text.trim()),
      errorTag: 'ForgotPasswordController.onSend',
    );

    if (state.value == ViewState.error) return false;

    AppSnackBar.success(message: I18n.resetLinkSent.tr);
    Get.back();
    return true;
  }
}
