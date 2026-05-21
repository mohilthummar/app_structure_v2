import 'package:flutter_test/flutter_test.dart';

import 'package:app_structure/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils.formatDate', () {
    test('formats DateTime as dd/MM/yyyy', () {
      expect(
        AppDateUtils.formatDate(DateTime(2024, 6, 7)),
        '07/06/2024',
      );
    });
  });

  group('AppDateUtils.formatDateLong', () {
    test('formats DateTime as dd MMM yyyy', () {
      expect(
        AppDateUtils.formatDateLong(DateTime(2024, 6, 7)),
        '07 Jun 2024',
      );
    });
  });

  group('AppDateUtils.parseISO', () {
    test('returns null for null input', () {
      expect(AppDateUtils.parseISO(null), isNull);
    });

    test('returns null for empty string', () {
      expect(AppDateUtils.parseISO(''), isNull);
    });

    test('parses a valid ISO string', () {
      final parsed = AppDateUtils.parseISO('2024-06-07T12:34:56.000Z');
      expect(parsed, isNotNull);
      expect(parsed!.toUtc().year, 2024);
      expect(parsed.toUtc().month, 6);
      expect(parsed.toUtc().day, 7);
    });

    test('returns null on malformed input', () {
      expect(AppDateUtils.parseISO('not-a-date'), isNull);
    });
  });

  group('AppDateUtils.timeAgo', () {
    test('returns "Just now" for <60s', () {
      final t = DateTime.now().subtract(const Duration(seconds: 30));
      expect(AppDateUtils.timeAgo(t), 'Just now');
    });

    test('returns minutes for <1 hour', () {
      final t = DateTime.now().subtract(const Duration(minutes: 5));
      expect(AppDateUtils.timeAgo(t), '5m ago');
    });

    test('returns hours for <1 day', () {
      final t = DateTime.now().subtract(const Duration(hours: 3));
      expect(AppDateUtils.timeAgo(t), '3h ago');
    });

    test('returns days for <1 week', () {
      final t = DateTime.now().subtract(const Duration(days: 4));
      expect(AppDateUtils.timeAgo(t), '4d ago');
    });
  });

  group('AppDateUtils.formatDuration', () {
    test('formats hours and minutes', () {
      expect(
        AppDateUtils.formatDuration(const Duration(hours: 2, minutes: 15)),
        '2h 15m',
      );
    });

    test('formats hours only when minutes are zero', () {
      expect(
        AppDateUtils.formatDuration(const Duration(hours: 3)),
        '3h',
      );
    });

    test('formats minutes only when hours are zero', () {
      expect(
        AppDateUtils.formatDuration(const Duration(minutes: 45)),
        '45m',
      );
    });
  });
}
