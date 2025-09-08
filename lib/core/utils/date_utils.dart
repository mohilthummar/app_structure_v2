import 'package:intl/intl.dart';

class DateUtils {
  static String convertDurationToMinutes(String text) {
    String data = '00:00:30';
    List<String> splitData = data.toString().split(':');
    int result = (int.parse(splitData[0].toString()) * 60) + int.parse(splitData[1].toString());
    int duration = result;
    if (splitData[2].toString() != '0') {
      duration = result + 1;
    }
    return "$duration Min";
  }

  static String changeDateFormat({DateTime? date, String? outputFormat}) {
    if (date != null && outputFormat != null) {
      DateFormat formatter = DateFormat(outputFormat);
      String formatted = formatter.format(date);
      return formatted;
    }
    return 'N/A';
  }

  static String utcToLocal(String utcDateTime) {
    DateTime dateTime = DateTime.parse(utcDateTime).toLocal();
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
  }

  static String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    DateTime dateUtc = DateTime.parse(dateString);
    var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateUtc.toString(), true);
    DateTime date = dateTime.toLocal();
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return (numericDates) ? '${(difference.inDays / 365).floor()} Y' : '${(difference.inDays / 365).floor()} Years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 Y' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} M';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 M' : 'Last Month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return (numericDates) ? '${(difference.inDays / 7).floor()} w' : '${(difference.inDays / 7).floor()} Weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 w' : 'Last week';
    } else if (difference.inDays >= 2) {
      return (numericDates) ? '${difference.inDays} d' : '${difference.inDays} Days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} min';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} sec';
    } else {
      return 'now';
    }
  }
}
