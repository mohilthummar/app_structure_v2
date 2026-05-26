import 'package:intl/intl.dart';

/// Date / time / duration helpers. English-only — projects that need
/// localised formats add `intl` localisation at the call site.
///
/// Two APIs in one file:
///
/// * [AppDateUtils] — static helpers when you need a one-off format
///   without an instance (parsing an ISO string, formatting a `Duration`).
/// * [DateExtension] — extension methods on `DateTime` for the most
///   common per-instance formats and predicates.
///
/// Usage:
/// ```dart
/// final picked = AppDateUtils.parseISO(json['created_at']);
/// final ago    = picked?.timeAgo() ?? 'unknown';
/// final pretty = DateTime.now().formatDate();    // 26/05/2026
/// final years  = birthday.age;                   // → 28
/// ```
abstract class AppDateUtils {
  static String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  static String formatDateLong(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);
  static String formatDateTime(DateTime date) => DateFormat('dd/MM/yyyy hh:mm a').format(date);
  static String formatDateTimeLong(DateTime date) => DateFormat('dd MMM yyyy, hh:mm a').format(date);
  static String formatMonth(DateTime date) => DateFormat('MMMM yyyy').format(date);
  static String formatISO(DateTime date) => date.toIso8601String();

  /// Safe ISO parser. Returns `null` for null / empty / malformed input.
  static DateTime? parseISO(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }

  /// Format an arbitrary `DateTime` with a custom `intl` pattern. Returns
  /// `'N/A'` when [date] or [pattern] is null.
  static String formatCustom({DateTime? date, String? pattern}) {
    if (date == null || pattern == null) return 'N/A';
    return DateFormat(pattern).format(date);
  }

  /// Relative time label: `Just now`, `5m ago`, `3h ago`, `4d ago`, `2w ago`,
  /// `6mo ago`, `1y ago`.
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Compact duration label: `2h 15m`, `3h`, `45m`.
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }
}

/// Convenience extensions on [DateTime]. Use these when you already have
/// a `DateTime` instance — they read more naturally than the static
/// [AppDateUtils] equivalents.
extension DateExtension on DateTime {
  // ── Formatting ───────────────────────────────────────────────────────────
  /// ISO date only — `2026-05-26`.
  String toDate() {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  String formatDate() => AppDateUtils.formatDate(this);
  String formatDateLong() => AppDateUtils.formatDateLong(this);
  String formatTime() => AppDateUtils.formatTime(this);
  String formatDateTime() => AppDateUtils.formatDateTime(this);
  String formatMonth() => AppDateUtils.formatMonth(this);

  /// Converts to Indian Standard Time (UTC+5:30) and formats as
  /// `dd/MM/yyyy - hh:mm a`. Use only when the backend timestamps are
  /// already UTC; calling on an already-IST `DateTime` will double-shift.
  String convertToISTFormat() {
    final ist = add(const Duration(hours: 5, minutes: 30));
    return DateFormat('dd/MM/yyyy - hh:mm a').format(ist);
  }

  String timeAgo() => AppDateUtils.timeAgo(this);

  // ── Predicates ───────────────────────────────────────────────────────────
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return year == y.year && month == y.month && day == y.day;
  }

  bool get isFuture => isAfter(DateTime.now());
  bool get isPast => isBefore(DateTime.now());
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  // ── Calculations ─────────────────────────────────────────────────────────
  /// Age in whole years. Handles birthdays not yet reached this calendar year.
  int get age {
    final now = DateTime.now();
    var years = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      years--;
    }
    return years;
  }

  /// Difference in whole days from `DateTime.now`. Negative for past dates,
  /// positive for future dates.
  int get daysFromNow => difference(DateTime.now()).inDays;

  /// Inclusive day-count label: `1 Day` / `5 Days`. Today counts as day 1
  /// — useful for "X days remaining" UI.
  String daysFromNowLabel() {
    final n = daysFromNow + 1;
    return n == 1 ? '$n Day' : '$n Days';
  }

  // ── Boundaries ───────────────────────────────────────────────────────────
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  // ── Relative labels ──────────────────────────────────────────────────────
  /// `Today` / `Yesterday` / `N days ago` / `N days from now`, falling
  /// back to [formatDate] for distant dates.
  String getRelativeTime() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    final diff = daysFromNow;
    if (diff < -1) return '${diff.abs()} days ago';
    if (diff > 1) return '$diff days from now';
    return formatDate();
  }
}
