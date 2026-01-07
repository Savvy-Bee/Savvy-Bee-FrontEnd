import 'package:intl/intl.dart';

extension DateFormatter on DateTime {
  // Format to show short month, day, year (e.g., Jun 20, 2025)
  String formatShortDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  // Format to show date for API request (e.g., 2025-06-20)
  String formatDateForRequest() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  // Format to show short month, day, year, and time (e.g., Jun 20, 2025, 03:07 PM)
  String formatDateTime() {
    return DateFormat('MMM dd, yyyy, hh:mm a').format(this);
  }

  // Format to show only time (e.g., 03:07 PM)
  String formatTime() {
    return DateFormat('hh:mm a').format(this);
  }

  // Format to show short month and day (e.g., Jun 20)
  String formatMonthDay() {
    return DateFormat('MMM dd').format(this);
  }

  // Format to show only the year (e.g., 2025)
  String formatYear() {
    return DateFormat('yyyy').format(this);
  }

  // Format to show relative time (e.g. "2 hours ago", "in 3 days")
  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);

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
  String formatDayOrToday() {
    final now = DateTime.now();
    if (year == now.year && month == now.month && day == now.day) {
      return 'Today';
    }
    return formatShortDate();
  }

  // Format datetime from int timestamp (milliseconds since epoch)
  String formatFromTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return dateTime.formatDateTime();
  }

  // Format short date from int timestamp (milliseconds since epoch)
  String formatShortDateFromTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return dateTime.formatShortDate();
  }

  // Format relative time from int timestamp (milliseconds since epoch)
  String formatRelativeFromTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return dateTime.formatRelative();
  }
}
