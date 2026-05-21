import 'package:intl/intl.dart';

/// Date / time / duration formatting helpers. English-only — projects that
/// need locales add `intl` localisation at the call site.
abstract class AppDateUtils {
  static String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  static String formatDateLong(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);

  static String formatDateTime(DateTime date) => DateFormat('dd/MM/yyyy hh:mm a').format(date);

  static String formatDateTimeLong(DateTime date) => DateFormat('dd MMM yyyy, hh:mm a').format(date);

  static String formatISO(DateTime date) => date.toIso8601String();

  static DateTime? parseISO(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }

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

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }
}
