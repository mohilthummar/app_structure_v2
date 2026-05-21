import 'package:flutter_test/flutter_test.dart';

import 'package:app_structure/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error when value is null', () {
      expect(Validators.required(null), 'This field is required');
    });

    test('returns error when value is empty', () {
      expect(Validators.required(''), 'This field is required');
    });

    test('returns error when value is whitespace only', () {
      expect(Validators.required('   '), 'This field is required');
    });

    test('returns null when value is non-empty', () {
      expect(Validators.required('hello'), isNull);
    });

    test('uses provided field name in the error message', () {
      expect(Validators.required(null, 'Email'), 'Email is required');
    });
  });

  group('Validators.email', () {
    test('rejects null', () {
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects empty string', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('rejects missing @-sign', () {
      expect(Validators.email('userexample.com'), 'Please enter a valid email');
    });

    test('rejects missing top-level domain', () {
      expect(Validators.email('user@example'), 'Please enter a valid email');
    });

    test('accepts a valid address', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('accepts addresses with + tags', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects null', () {
      expect(Validators.password(null), 'Password is required');
    });

    test('rejects empty', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('rejects under 8 chars', () {
      expect(
        Validators.password('Ab1'),
        'Password must be at least 8 characters',
      );
    });

    test('rejects digits-only', () {
      expect(
        Validators.password('12345678'),
        'Password must contain at least one letter',
      );
    });

    test('rejects letters-only', () {
      expect(
        Validators.password('abcdefgh'),
        'Password must contain at least one number',
      );
    });

    test('accepts a valid 8+ char letter+digit password', () {
      expect(Validators.password('Abcd1234'), isNull);
    });
  });

  group('Validators.otp', () {
    test('rejects null', () {
      expect(Validators.otp(null), 'Verification code is required');
    });

    test('rejects empty', () {
      expect(Validators.otp(''), 'Verification code is required');
    });

    test('rejects 5 digits', () {
      expect(Validators.otp('12345'), 'Enter the 6-digit code');
    });

    test('rejects 7 digits', () {
      expect(Validators.otp('1234567'), 'Enter the 6-digit code');
    });

    test('rejects non-numeric content', () {
      expect(Validators.otp('12345a'), 'Enter the 6-digit code');
    });

    test('accepts 6 digits', () {
      expect(Validators.otp('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects when value does not match', () {
      expect(
        Validators.confirmPassword('one', 'two'),
        'Passwords do not match',
      );
    });

    test('accepts when values match', () {
      expect(Validators.confirmPassword('Abcd1234', 'Abcd1234'), isNull);
    });
  });

  group('Validators.compose', () {
    test('returns the first failing validator error', () {
      final composed = Validators.compose([
        Validators.required,
        Validators.email,
      ]);

      expect(composed(''), 'This field is required');
    });

    test('returns null when all validators pass', () {
      final composed = Validators.compose([
        Validators.required,
        Validators.email,
      ]);

      expect(composed('user@example.com'), isNull);
    });
  });
}
