import 'package:flutter_test/flutter_test.dart';

import 'package:app_structure/core/utils/string_utils.dart';

void main() {
  group('prettyType', () {
    test('returns empty for null', () {
      expect(prettyType(null), '');
    });

    test('returns empty for empty string', () {
      expect(prettyType(''), '');
    });

    test('returns empty for whitespace-only input', () {
      expect(prettyType('   '), '');
    });

    test('converts snake_case to Title Case', () {
      expect(
        prettyType('new_team_member_added'),
        'New Team Member Added',
      );
    });

    test('converts camelCase to Title Case', () {
      expect(prettyType('vetAppointment'), 'Vet Appointment');
    });

    test('trims surrounding whitespace', () {
      expect(prettyType('  booking_request  '), 'Booking Request');
    });

    test('handles mixed casing and dashes', () {
      expect(prettyType('mixed-CaseInput'), 'Mixed Case Input');
    });

    test('upper-cases a single-letter word', () {
      expect(prettyType('a_b_c'), 'A B C');
    });
  });
}
