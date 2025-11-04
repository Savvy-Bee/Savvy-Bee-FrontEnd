import 'package:intl/intl.dart';

class DateFormatter {
  // Format to show short month, day, year (e.g., Jun 20, 2025)
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  // Format to show date for API request (e.g., 2025-06-20)
  static String formatDateForRequest(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  // Format to show short month, day, year, and time (e.g., Jun 20, 2025, 03:07 PM)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy, hh:mm a').format(dateTime);
  }

  // Format to show only time (e.g., 03:07 PM)
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Format to show short month and day (e.g., Jun 20)
  static String formatMonthDay(DateTime dateTime) {
    return DateFormat('MMM dd').format(dateTime);
  }

  // Format to show only the year (e.g., 2025)
  static String formatYear(DateTime dateTime) {
    return DateFormat('yyyy').format(dateTime);
  }

  // Format to show relative time (e.g. "2 hours ago", "in 3 days")
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If the date is in the future
    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 365) {
        return 'in ${(absDifference.inDays / 365).floor()} yrs';
      } else if (absDifference.inDays > 30) {
        return 'in ${(absDifference.inDays / 30).floor()} mons';
      } else if (absDifference.inDays > 0) {
        return 'in ${absDifference.inDays} days';
      } else if (absDifference.inHours > 0) {
        return 'in ${absDifference.inHours} hrs';
      } else if (absDifference.inMinutes > 0) {
        return 'in ${absDifference.inMinutes} mins';
      } else {
        return 'in a moment';
      }
    }

    // If the date is in the past
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yrs ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mons ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} wks ago';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hrs ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inSeconds > 30) {
      return '${difference.inSeconds} secs ago';
    } else {
      return 'Just now';
    }
  }

  // Format to show 'today' if the date is today, otherwise show the date
  static String formatDayOrToday(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    }
    return formatShortDate(dateTime);
  }

  // Format datetime from int timestamp (milliseconds since epoch)
  static String formatFromTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatDateTime(dateTime);
  }

  // Format short date from int timestamp (milliseconds since epoch)
  static String formatShortDateFromTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatShortDate(dateTime);
  }

  // Format relative time from int timestamp (milliseconds since epoch)
  static String formatRelativeFromTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatRelative(dateTime);
  }
}
