import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it as is.
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Clean the input: Remove all non-digit and non-decimal-point characters.
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Prevent multiple decimal points.
    if (cleanText.split('.').length > 2) {
      return oldValue; // Revert to the old value if a second '.' is typed.
    }

    // Handle edge cases for decimal input.
    if (cleanText == '.') {
      return newValue.copyWith(text: '0.');
    }

    // Split into integer and decimal parts.
    List<String> parts = cleanText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // 2. Format the integer part with commas.
    // Parse the integer part (remove existing commas for parsing).
    final integerValue = int.tryParse(integerPart.replaceAll(RegExp(r','), ''));

    if (integerValue == null) {
      // This can happen if the integer part is empty (e.g., user typed ".12").
      integerPart = "0";
    } else {
      // Use NumberFormat to add commas.
      final formatter = NumberFormat('#,###');
      integerPart = formatter.format(integerValue);
    }

    // 3. Reconstruct the text.
    String newFormattedText;
    if (decimalPart != null) {
      // Limit to 2 decimal places.
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }
      newFormattedText = '$integerPart.$decimalPart';
    } else if (newValue.text.endsWith('.')) {
      // User just typed the decimal point.
      newFormattedText = '$integerPart.';
    } else {
      // Just the integer part.
      newFormattedText = integerPart;
    }

    // 4. Calculate the new cursor position.
    // This logic ensures the cursor stays in the correct place,
    // even after commas are added or removed.
    int lengthDifference = newFormattedText.length - newValue.text.length;
    int selectionOffset = newValue.selection.baseOffset + lengthDifference;

    // Ensure the cursor position is valid.
    if (selectionOffset < 0) {
      selectionOffset = 0;
    }
    if (selectionOffset > newFormattedText.length) {
      selectionOffset = newFormattedText.length;
    }

    return TextEditingValue(
      text: newFormattedText,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}
