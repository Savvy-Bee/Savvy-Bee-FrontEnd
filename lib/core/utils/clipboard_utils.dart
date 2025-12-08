import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';

/// Utility class for clipboard operations
class ClipboardUtils {
  ClipboardUtils._();

  // ============================================
  // BASIC CLIPBOARD OPERATIONS
  // ============================================

  /// Get clipboard data in the specified format
  static Future<ClipboardData?> getClipboardData(String format) async {
    try {
      return await Clipboard.getData(format);
    } catch (e) {
      debugPrint('Error getting clipboard data: $e');
      return null;
    }
  }

  /// Get text from clipboard
  static Future<String?> getText() async {
    try {
      final data = await getClipboardData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      debugPrint('Error getting clipboard text: $e');
      return null;
    }
  }

  /// Copy text to clipboard
  static Future<bool> copyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      debugPrint('Error copying text to clipboard: $e');
      return false;
    }
  }

  /// Copy text to clipboard and show a snackbar
  static Future<bool> copyTextWithFeedback(
    BuildContext context,
    String text, {
    String? successMessage,
    Duration duration = const Duration(seconds: 2),
  }) async {
    final success = await copyText(text);

    if (context.mounted) {
      CustomSnackbar.show(
        context,
        success
            ? (successMessage ?? 'Copied to clipboard')
            : 'Failed to copy to clipboard',
        type: success ? SnackbarType.success : SnackbarType.error,
      );
    }

    return success;
  }

  // ============================================
  // SPECIALIZED PASTE OPERATIONS
  // ============================================

  /// Paste and extract numbers only (useful for account numbers, phone numbers, etc.)
  static Future<String?> pasteNumbersOnly({
    int? maxLength,
    int? minLength,
  }) async {
    final clipboardData = await getText();

    if (clipboardData == null) return null;

    final numbers = clipboardData.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.isEmpty) return null;
    if (minLength != null && numbers.length < minLength) return null;
    if (maxLength != null && numbers.length > maxLength) return null;

    return numbers;
  }

  /// Paste account number into a controller with validation
  static Future<bool> pasteAccountNumber(
    TextEditingController controller, {
    int maxLength = 10,
    int? minLength,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
    Function(String)? onValidNumber,
  }) async {
    final numbers = await pasteNumbersOnly(
      maxLength: maxLength,
      minLength: minLength,
    );

    if (numbers != null && numbers.isNotEmpty) {
      controller.text = numbers;
      onSuccess?.call();
      onValidNumber?.call(numbers);
      return true;
    } else {
      onFailure?.call();
      return false;
    }
  }

  /// Paste phone number with optional country code handling
  static Future<String?> pastePhoneNumber({
    String? countryCode,
    bool removeCountryCode = false,
    int? maxLength,
  }) async {
    final numbers = await pasteNumbersOnly();

    if (numbers == null) return null;

    String processed = numbers;

    // Remove country code if specified
    if (removeCountryCode && countryCode != null) {
      if (processed.startsWith(countryCode)) {
        processed = processed.substring(countryCode.length);
      }
    }

    // Add country code if specified and not present
    if (!removeCountryCode &&
        countryCode != null &&
        !processed.startsWith(countryCode)) {
      processed = countryCode + processed;
    }

    if (maxLength != null && processed.length > maxLength) {
      processed = processed.substring(0, maxLength);
    }

    return processed;
  }

  /// Paste email address with validation
  static Future<String?> pasteEmail({bool validateFormat = true}) async {
    final text = await getText();

    if (text == null || text.isEmpty) return null;

    final trimmed = text.trim();

    if (validateFormat) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(trimmed)) return null;
    }

    return trimmed;
  }

  /// Paste and extract amount/currency value
  static Future<double?> pasteAmount({bool allowNegative = false}) async {
    final text = await getText();

    if (text == null) return null;

    // Remove currency symbols and keep only numbers, decimal point, and optionally minus
    final pattern = allowNegative ? r'[^\d.-]' : r'[^\d.]';
    final cleaned = text.replaceAll(RegExp(pattern), '');

    return double.tryParse(cleaned);
  }

  // ============================================
  // VALIDATION HELPERS
  // ============================================

  /// Check if clipboard contains a valid account number
  static Future<bool> hasValidAccountNumber({
    int maxLength = 10,
    int minLength = 10,
  }) async {
    final numbers = await pasteNumbersOnly(
      maxLength: maxLength,
      minLength: minLength,
    );

    return numbers != null && numbers.length >= minLength;
  }

  /// Check if clipboard contains a valid email
  static Future<bool> hasValidEmail() async {
    final email = await pasteEmail(validateFormat: true);
    return email != null;
  }

  /// Check if clipboard contains a valid phone number
  static Future<bool> hasValidPhoneNumber({
    int? minLength,
    int? maxLength,
  }) async {
    final numbers = await pasteNumbersOnly(
      minLength: minLength,
      maxLength: maxLength,
    );

    return numbers != null;
  }
}
