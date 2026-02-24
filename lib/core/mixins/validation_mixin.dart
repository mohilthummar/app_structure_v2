mixin ValidationMixin {
  /// Check if the email is valid
  bool _isEmailValid(String? email) {
    const Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final RegExp regex = RegExp(pattern.toString());
    return email != null ? regex.hasMatch(email) : false;
  }

  /// Validate the email
  String? emailValidator(String? email) {
    if (email?.isNotEmpty ?? false) {
      if (_isEmailValid(email)) {
        return null;
      } else {
        return 'Please enter a valid email address';
      }
    } else {
      return 'Please enter your email address';
    }
  }

  /// Validate the password
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
    final RegExp letterRegex = RegExp(r'[a-z]');
    final RegExp capitalRegex = RegExp(r'[A-Z]');
    final RegExp numberRegex = RegExp(r'[0-9]');
    final RegExp symbolRegex = RegExp(r'[!@#\$%^&*()_+{}|:<>?~-]');
    if (!letterRegex.hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    if (!capitalRegex.hasMatch(password)) {
      return 'Password must contain at least one capital letter';
    }
    if (!numberRegex.hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!symbolRegex.hasMatch(password)) {
      return 'Password must contain at least one symbol';
    }
    return null;
  }

  /// Validate the new password
  String? newPasswordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.startsWith(' ')) {
      return 'No leading white spaces allowed.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final RegExp letterRegex = RegExp(r'[a-z]');
    final RegExp capitalRegex = RegExp(r'[A-Z]');
    final RegExp numberRegex = RegExp(r'[0-9]');
    final RegExp symbolRegex = RegExp(r'[!@#\$%^&*()_+{}|:<>?~-]');
    if (!letterRegex.hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    if (!capitalRegex.hasMatch(password)) {
      return 'Password must contain at least one capital letter';
    }
    if (!numberRegex.hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!symbolRegex.hasMatch(password)) {
      return 'Password must contain at least one symbol';
    }
    return null;
  }

  /// Validate the confirm password for forgot password
  String? confirmPasswordValidatorForForgotPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != newPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate the confirm password for general use
  String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate the phone number
  String? phoneValidator(String? value, int phoneLength) {
    final RegExp regExp = RegExp(r'^[+]*[(]?[0-9]{1,4}[)]?[-\s./0-9]*$');
    final bool isMatched = value != null ? regExp.hasMatch(value) : false;
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (value.length < phoneLength) {
      return 'Please enter a valid mobile number';
    } else if (isMatched) {
      return null;
    } else {
      return 'Please enter a valid mobile number';
    }
  }

  /// Validate the name
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

  /// Validate the address
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
