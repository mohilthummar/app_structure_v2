/// The single home for form-field validation in the app. Mix into any
/// controller that drives a `Form`, then pass the `*Validator` tear-offs
/// straight to a field's `validator:` argument.
///
/// All methods return `null` when the input is valid, or a short,
/// user-safe error string otherwise. There is no separate static
/// `Validators` class — keep every rule here so the whole app validates
/// the same way (see [.claude/rules/code-quality.md] "No duplicate
/// implementations").
///
/// Usage:
/// ```dart
/// class LoginController extends BaseController with ValidationMixin {
///   final emailController = TextEditingController();
/// }
///
/// // in the view (GetView<LoginController>):
/// AppTextField(
///   controller: controller.emailController,
///   validator: controller.emailValidator,
/// );
///
/// // compose several rules — first error wins:
/// validator: controller.compose([
///   controller.requiredValidator,
///   controller.emailValidator,
/// ]);
/// ```
mixin ValidationMixin {
  // ── Generic ────────────────────────────────────────────────────────────
  /// Non-empty check. [fieldName] personalises the message.
  String? requiredValidator(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? minLengthValidator(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  String? maxLengthValidator(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Accepts empty (use [requiredValidator] to forbid that); rejects
  /// non-numeric input otherwise.
  String? numericValidator(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  // ── Email / URL ──────────────────────────────────────────────────────────
  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w-\.+]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Accepts empty; validates the shape only when a value is present.
  String? urlValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // ── Password ───────────────────────────────────────────────────────────
  /// Strong-password policy: 8+ chars, at least one lowercase letter, one
  /// capital, one number, and one symbol. No leading whitespace.
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

  /// Same policy as [passwordValidator] — alias for set-new-password flows.
  String? newPasswordValidator(String? password) => passwordValidator(password);

  String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Phone ────────────────────────────────────────────────────────────────
  /// [minLength] is the minimum digit count to accept (defaults to 7).
  String? phoneValidator(String? value, [int minLength = 7]) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length < minLength) {
      return 'Please enter a valid mobile number';
    }
    final regExp = RegExp(r'^[+]*[(]?[0-9]{1,4}[)]?[-\s./0-9]*$');
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  // ── OTP ────────────────────────────────────────────────────────────────
  /// 6-digit numeric one-time password.
  String? otpValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter the 6-digit code';
    }
    return null;
  }

  // ── Name / address ─────────────────────────────────────────────────────
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

  // ── Combinator ───────────────────────────────────────────────────────────
  /// Chains validators left-to-right and returns the first error found.
  String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
