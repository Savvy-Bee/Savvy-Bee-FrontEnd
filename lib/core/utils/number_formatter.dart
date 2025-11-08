import 'package:intl/intl.dart';

class NumberFormatter {
  static const String defaultLocale = 'en_US';
  static const String defaultSymbol = '\$';
  /// Formats a double as currency (e.g., $1,234.56).
  /// Uses the default locale if not specified.
  static String formatCurrency(
    double amount, {
    String? locale,
    // String? symbol = '₦',
    String? symbol = '\$',
    int? decimalDigits = 2,
  }) {
    final format = NumberFormat.currency(
      locale: locale ?? defaultLocale,
      symbol: symbol ?? defaultSymbol,
      decimalDigits: decimalDigits,
    );
    return format.format(amount);
  }

  /// Format a positive/negative number with currency symbol and sign (e.g., +$123.45 or -$123.45)
  static String formatSignedCurrency(
    double amount, {
    String? locale,
    String? symbol = '\$',
    int? decimalDigits,
  }) {
    final format = NumberFormat.currency(
      locale: locale ?? defaultLocale,
      symbol: symbol ?? defaultSymbol,
      decimalDigits: decimalDigits ?? 2,
    );
    final formatted = format.format(amount);
    if (amount > 0) {
      return '+${symbol ?? defaultSymbol}$formatted';
    }
    return '-${symbol ?? defaultSymbol}${formatted.substring(1)}';

  }

  /// Formats a double as a percentage (e.g., 12.34%).
  static String formatPercentage(double value, {int decimalDigits = 2}) {
    final format = NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    );
    return '${format.format(value)}%';
  }

  /// Formats a double with commas for thousands (e.g., 1,234,567.89).
  static String formatWithCommas(double number, {int decimalDigits = 2}) {
    final format = NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    );
    return format.format(number);
  }

  /// Formats an inbteger with commas (e.g., 1,234,567).
  static String formatIntWithCommas(int number) {
    final format = NumberFormat.decimalPattern();
    return format.format(number);
  }

  /// Converts a double to a string with a specified number of decimal places,
  /// useful for displaying fixed-point numbers.
  static String formatDecimal(double number, {int decimalPlaces = 2}) {
    return number.toStringAsFixed(decimalPlaces);
  }

  /// Format a positive/negative number with sign (e.g., +123.45 or -123.45)
  static String formatSignedNumber(double number, {int decimalPlaces = 2}) {
    final formatted = number.toStringAsFixed(decimalPlaces);
    if (number > 0) {
      return '+$formatted';
    }
    return formatted;

    /// Already has a '-' if negative
  }

  /// Format a positive/negative number with sign and percentage (e.g., +123.45% or -123.45%)
  static String formatSignedPercentage(double number, {int decimalPlaces = 2}) {
    final formatted = number.toStringAsFixed(decimalPlaces);
    if (number > 0) return "+$formatted%";
    return '$formatted%';
  }

  /// Format to compact number (e.g. "1.2M" instead of "1,200,000")
  static String compact(num number) {
    final format = NumberFormat.compact();

    return format.format(number);
  }

  /// Format compact currency (e.g. "1.2M" instead of "1,200,000")
  static String compactCurrency(
    num number, {
    String? locale,
    String? symbol = '\$',
  }) {
    final format = NumberFormat.compactCurrency(
      locale: locale ?? defaultLocale,
      symbol: symbol ?? defaultSymbol,
    );
    return format.format(number);
  }
}
