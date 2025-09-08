# Core Utilities

This folder contains reusable, modular utilities for the TredPlus app. Utilities are grouped by purpose and are designed for easy use, testing, and extension.

## Structure

- **validation/**: Modular validation mixins for forms (email, password, phone, PAN, Aadhaar, IFSC, etc.)
- **formatters/**: Input formatters for text fields (uppercase, double input, etc.)
- **UI Utilities**: Snackbars, loaders, shimmer, image sheets, etc.
- **Device/Platform Utilities**: Device info, file utils, preferences, etc.

## Usage Examples

### Validation
```dart
import 'package:tredplus_app/core/utils/validation_mixin.dart';

class MyFormValidator with EmailValidationMixin, PasswordValidationMixin {
  // ...
}

final validator = MyFormValidator();
validator.emailValidator('test@example.com'); // returns null if valid
```

### Input Formatters
```dart
import 'package:tredplus_app/core/utils/formatters/input_formatters.dart';

TextField(
  inputFormatters: [UpperCaseTextFormatter()],
)
```

### Snackbars
```dart
import 'package:tredplus_app/core/utils/app_snack_bar.dart';

AppSnackBar.success(message: 'Operation successful!');
```

### Loader
```dart
import 'package:tredplus_app/core/utils/app_loader.dart';

showDialog(
  context: context,
  builder: (_) => const AppLoader(label: 'Loading...'),
);
```

### Preferences
```dart
import 'package:tredplus_app/core/utils/preferences.dart';

Preferences.set<String>('key', 'value');
final value = Preferences.get<String>('key');
```

---

## Contributing
- Add new utilities in a modular way.
- Document all public APIs with Dart doc comments.
- Add usage examples in this README or the relevant subfolder README. 