import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension BuildContextExtensions on BuildContext {
  /// Format currency in Naira
  String currencyFormat(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: showSymbol ? '₦' : '',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format currency without decimal places
  String currencyFormatCompact(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: showSymbol ? '₦' : '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format large numbers in compact form (e.g., 1.2M, 500K)
  String compactFormat(double amount) {
    final formatter = NumberFormat.compact(locale: 'en_NG');
    return formatter.format(amount);
  }

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if device is in dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

extension DoubleExtensions on double {
  /// Format as currency
  String toCurrency({bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: showSymbol ? '₦' : '',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  /// Format as compact currency (e.g., ₦1.2M)
  String toCompactCurrency() {
    if (this >= 1000000) {
      return '₦${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '₦${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return '₦${toStringAsFixed(0)}';
    }
  }
}

extension DateTimeExtensions on DateTime {
  /// Format as day/month/year
  String toFormattedDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format as month and year
  String toMonthYear() {
    return DateFormat('MMM yyyy').format(this);
  }

  /// Format as relative time (e.g., "2 days ago")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}