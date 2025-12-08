import 'package:intl/intl.dart';

extension NumberFormatterExtension on num {
  static const String defaultLocale = 'en_US';
  static const String defaultSymbol = '₦';

  /// Formats a number as currency (e.g., $1,234.56).
  /// Uses the default locale if not specified.
  String formatCurrency({
    String? locale,
    String? symbol = '₦',
    int? decimalDigits = 2,
  }) {
    final format = NumberFormat.currency(
      locale: locale ?? defaultLocale,
      symbol: symbol ?? defaultSymbol,
      decimalDigits: decimalDigits,
    );
    return format.format(this);
  }

  /// Format a positive/negative number with currency symbol and sign (e.g., +$123.45 or -$123.45)
  String formatSignedCurrency({
    String? locale,
    String? symbol = '₦',
    int? decimalDigits,
  }) {
    final format = NumberFormat.currency(
      locale: locale ?? defaultLocale,
      symbol: symbol ?? defaultSymbol,
      decimalDigits: decimalDigits ?? 2,
    );
    final formatted = format.format(this);
    if (this > 0) {
      return '+${symbol ?? defaultSymbol}$formatted';
    }
    return '-${symbol ?? defaultSymbol}${formatted.substring(1)}';
  }

  /// Formats a number as a percentage (e.g., 12.34%).
  String formatPercentage({int decimalDigits = 2}) {
    final format = NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    );
    return '${format.format(this)}%';
  }

  /// Formats a number with commas for thousands (e.g., 1,234,567.89).
  String formatWithCommas({int decimalDigits = 2}) {
    final format = NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    );
    return format.format(this);
  }

  /// Formats an integer with commas (e.g., 1,234,567).
  String formatIntWithCommas() {
    final format = NumberFormat.decimalPattern();
    return format.format(this);
  }

  /// Converts a number to a string with a specified number of decimal places,
  /// useful for displaying fixed-point numbers.
  String formatDecimal({int decimalPlaces = 2}) {
    return toStringAsFixed(decimalPlaces);
  }

  /// Format a positive/negative number with sign (e.g., +123.45 or -123.45)
  String formatSignedNumber({int decimalPlaces = 2}) {
    final formatted = toStringAsFixed(decimalPlaces);
    if (this > 0) {
      return '+$formatted';
    }
    return formatted;

    /// Already has a '-' if negative
  }

  /// Format a positive/negative number with sign and percentage (e.g., +123.45% or -123.45%)
  String formatSignedPercentage({int decimalPlaces = 2}) {
    final formatted = toStringAsFixed(decimalPlaces);
    if (this > 0) return "+$formatted%";
    return '$formatted%';
  }

  /// Format to compact number (e.g. "1.2M" instead of "1,200,000")
  String compact() {
    final format = NumberFormat.compact();
    return format.format(this);
  }

  /// Format compact currency (e.g. "1.2M" instead of "1,200,000")
  String compactCurrency({String? locale, String? symbol = '₦'}) {
    final format = NumberFormat.compactCurrency(
      locale: locale ?? defaultLocale,
      symbol: symbol ?? defaultSymbol,
    );
    return format.format(this);
  }
}
