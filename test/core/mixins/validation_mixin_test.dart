import 'package:flutter_test/flutter_test.dart';

import 'package:app_structure/core/mixins/validation_mixin.dart';

class _Validators with ValidationMixin {}

void main() {
  final v = _Validators();

  group('requiredValidator', () {
    test('returns error when value is null', () {
      expect(v.requiredValidator(null), 'This field is required');
    });

    test('returns error when value is empty', () {
      expect(v.requiredValidator(''), 'This field is required');
    });

    test('returns error when value is whitespace only', () {
      expect(v.requiredValidator('   '), 'This field is required');
    });

    test('returns null when value is non-empty', () {
      expect(v.requiredValidator('hello'), isNull);
    });

    test('uses provided field name in the error message', () {
      expect(v.requiredValidator(null, 'Email'), 'Email is required');
    });
  });

  group('emailValidator', () {
    test('rejects null', () {
      expect(v.emailValidator(null), 'Email is required');
    });

    test('rejects empty string', () {
      expect(v.emailValidator(''), 'Email is required');
    });

    test('rejects missing @-sign', () {
      expect(v.emailValidator('userexample.com'), 'Please enter a valid email');
    });

    test('rejects missing top-level domain', () {
      expect(v.emailValidator('user@example'), 'Please enter a valid email');
    });

    test('accepts a valid address', () {
      expect(v.emailValidator('user@example.com'), isNull);
    });

    test('accepts addresses with + tags', () {
      expect(v.emailValidator('user+tag@example.com'), isNull);
    });
  });

  group('passwordValidator', () {
    test('rejects null', () {
      expect(v.passwordValidator(null), 'Please enter your password');
    });

    test('rejects empty', () {
      expect(v.passwordValidator(''), 'Please enter your password');
    });

    test('rejects under 8 chars', () {
      expect(
        v.passwordValidator('Ab1!'),
        'Password must be at least 8 characters long',
      );
    });

    test('rejects digits-only', () {
      expect(
        v.passwordValidator('12345678'),
        'Password must contain at least one letter',
      );
    });

    test('rejects missing capital letter', () {
      expect(
        v.passwordValidator('abcd1234!'),
        'Password must contain at least one capital letter',
      );
    });

    test('rejects missing number', () {
      expect(
        v.passwordValidator('Abcdefg!'),
        'Password must contain at least one number',
      );
    });

    test('rejects missing symbol', () {
      expect(
        v.passwordValidator('Abcd1234'),
        'Password must contain at least one symbol',
      );
    });

    test('accepts a password that meets every rule', () {
      expect(v.passwordValidator('Abcd1234!'), isNull);
    });
  });

  group('otpValidator', () {
    test('rejects null', () {
      expect(v.otpValidator(null), 'Verification code is required');
    });

    test('rejects empty', () {
      expect(v.otpValidator(''), 'Verification code is required');
    });

    test('rejects 5 digits', () {
      expect(v.otpValidator('12345'), 'Enter the 6-digit code');
    });

    test('rejects 7 digits', () {
      expect(v.otpValidator('1234567'), 'Enter the 6-digit code');
    });

    test('rejects non-numeric content', () {
      expect(v.otpValidator('12345a'), 'Enter the 6-digit code');
    });

    test('accepts 6 digits', () {
      expect(v.otpValidator('123456'), isNull);
    });
  });

  group('confirmPasswordValidator', () {
    test('rejects when value does not match', () {
      expect(
        v.confirmPasswordValidator('one', 'two'),
        'Passwords do not match',
      );
    });

    test('accepts when values match', () {
      expect(v.confirmPasswordValidator('Abcd1234!', 'Abcd1234!'), isNull);
    });
  });

  group('compose', () {
    test('returns the first failing validator error', () {
      final composed = v.compose([
        v.requiredValidator,
        v.emailValidator,
      ]);

      expect(composed(''), 'This field is required');
    });

    test('returns null when all validators pass', () {
      final composed = v.compose([
        v.requiredValidator,
        v.emailValidator,
      ]);

      expect(composed('user@example.com'), isNull);
    });
  });
}
