import 'package:intl/intl.dart';

extension NumExtensions on num {
  /// Format number as currency with NaN protection
  String formatCurrency({int decimalDigits = 2, String symbol = '₦'}) {
    // CRITICAL: Check for NaN or Infinity before formatting
    if (isNaN || isInfinite) {
      // Return formatted zero instead of showing NaN
      return decimalDigits == 0
          ? '$symbol 0'
          : '$symbol 0.${'0' * decimalDigits}';
    }

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );

    return formatter.format(this);
  }

  /// Safe conversion to double with NaN protection
  double toSafeDouble() {
    if (isNaN || isInfinite) return 0.0;
    return toDouble();
  }

  /// Safe conversion to int with NaN protection
  int toSafeInt() {
    if (isNaN || isInfinite) return 0;
    return toInt();
  }
}
