import 'package:app_structure/core/utils/validators.dart';

/// Form-field validation mixin. Methods delegate to `Validators` so the
/// rules stay in one place. New code can call `Validators.x` directly;
/// this mixin remains for backward compatibility with existing controllers.
mixin ValidationMixin {
  /// Validate the email
  String? emailValidator(String? email) => Validators.email(email);

  /// Validate the password (8+ chars, includes letter, capital, number, symbol)
  String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.startsWith(' ')) {
      return 'No leading white spaces allowed.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one capital letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$%^&*()_+{}|:<>?~-]').hasMatch(password)) {
      return 'Password must contain at least one symbol';
    }
    return null;
  }

  /// Validate a new password — same rules as `passwordValidator`.
  String? newPasswordValidator(String? password) => passwordValidator(password);

  /// Validate the confirm-password for forgot-password flow.
  String? confirmPasswordValidatorForForgotPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != newPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate the confirm-password for general use.
  String? confirmPasswordValidator(String? value, String password) => confirmPasswordValidatorForForgotPassword(value, password);

  /// Validate phone number with explicit length check.
  String? phoneValidator(String? value, int phoneLength) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length < phoneLength) {
      return 'Please enter a valid mobile number';
    }
    final regExp = RegExp(r'^[+]*[(]?[0-9]{1,4}[)]?[-\s./0-9]*$');
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  /// Validate a person's name.
  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.startsWith(' ')) {
      return 'No leading white spaces allowed';
    }
    return null;
  }

  /// Validate a street address.
  String? addressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    if (value.trim().length < 10) {
      return 'Address must be at least 10 characters long';
    }
    if (value.startsWith(' ')) {
      return 'No leading white spaces allowed';
    }
    return null;
  }
}
