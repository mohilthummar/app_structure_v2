import 'package:intl/intl.dart';

import '../utils/utils.dart';

/// Extension on DateTime to provide convenient date formatting and manipulation methods
/// Offers various date formatting options and utility functions for date calculations
///
/// Example usage:
/// ```dart
/// class DateUtils {
///   void formatUserDate(DateTime date) {
///     String formatted = date.toDate(); // Returns "2024-01-15"
///     String readable = date.formatDate(); // Returns "15/01/2024"
///     int daysDiff = date.getDifference(); // Returns days difference from now
///   }
/// }
/// ```
extension DateExtension on DateTime {
  /// Converts DateTime to ISO date format (YYYY-MM-DD)
  ///
  /// Returns a string in the format "2024-01-15"
  /// Ensures proper zero-padding for month and day values
  String toDate() {
    String month = this.month >= 10 ? this.month.toString() : '0${this.month}';
    String day = this.day >= 10 ? this.day.toString() : '0${this.day}';
    return '$year-$month-$day';
  }

  /// Calculates the difference in days between this date and current date
  ///
  /// Returns the number of days difference (can be negative for past dates)
  /// Uses DateTime.difference() for accurate calculation
  int getDifference() {
    DateTime currentDateTime = DateTime.now();
    int days = difference(currentDateTime).inDays;
    return days;
  }

  /// Gets the difference in days with proper singular/plural formatting
  ///
  /// Returns a human-readable string like "1 day" or "5 days"
  /// Adds 1 to the difference for inclusive counting
  String getDifferenceWithDayOrDays() {
    DateTime currentDateTime = DateTime.now();
    int days = difference(currentDateTime).inDays;
    days += 1; // Inclusive counting

    return days == 1 ? '$days Day' : '$days Days';
  }

  /// Formats the date in DD/MM/YYYY format
  ///
  /// Returns a string like "15/01/2024"
  /// Uses the Utils.changeDateFormat method for consistent formatting
  String formatDate() {
    return DateUtils.changeDateFormat(date: this, outputFormat: 'dd/MM/yyyy');
  }

  /// Formats the date to show month and year
  ///
  /// Returns a string like "January 2024"
  /// Uses the Utils.changeDateFormat method for consistent formatting
  String formatMonth() {
    return DateUtils.changeDateFormat(date: this, outputFormat: 'MMMM yyyy');
  }

  /// Converts the date to Indian Standard Time (IST) format
  ///
  /// Adds 5 hours and 30 minutes to convert to IST
  /// Returns a formatted string like "15/01/2024 - 02:30 PM"
  String convertToISTFormat() {
    DateTime istDateTime = add(const Duration(hours: 5, minutes: 30));
    DateFormat dateFormat = DateFormat('dd/MM/yyyy - hh:mm a');
    return dateFormat.format(istDateTime);
  }

  /// Checks if this date is today
  ///
  /// Returns true if the date is today, false otherwise
  bool get isToday {
    DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if this date is yesterday
  ///
  /// Returns true if the date is yesterday, false otherwise
  bool get isYesterday {
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Checks if this date is in the future
  ///
  /// Returns true if the date is after today, false otherwise
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Checks if this date is in the past
  ///
  /// Returns true if the date is before today, false otherwise
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Gets the age in years from this date to now
  ///
  /// Returns the age in years as an integer
  int get age {
    DateTime now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Formats the date for display with relative time
  ///
  /// Returns strings like "Today", "Yesterday", "2 days ago", or formatted date
  String getRelativeTime() {
    if (isToday) {
      return 'Today';
    } else if (isYesterday) {
      return 'Yesterday';
    } else {
      int diff = getDifference();
      if (diff > 0) {
        return '$diff days ago';
      } else if (diff < 0) {
        return '${diff.abs()} days from now';
      } else {
        return formatDate();
      }
    }
  }

  /// Gets the start of the day (00:00:00)
  ///
  /// Returns a DateTime object set to the beginning of this date
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Gets the end of the day (23:59:59)
  ///
  /// Returns a DateTime object set to the end of this date
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Checks if this date falls on a weekend
  ///
  /// Returns true if the date is Saturday or Sunday, false otherwise
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Gets the day name in short format
  ///
  /// Returns strings like "Mon", "Tue", "Wed", etc.
  String get shortDayName {
    const List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[weekday - 1];
  }

  /// Gets the month name in short format
  ///
  /// Returns strings like "Jan", "Feb", "Mar", etc.
  String get shortMonthName {
    const List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return monthNames[month - 1];
  }
}
