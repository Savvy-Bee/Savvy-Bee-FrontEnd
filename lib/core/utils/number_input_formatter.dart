import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// TextInputFormatter that automatically adds commas to numerical values.
///
/// Example:
/// - User types "1000" → displays "1,000"
/// - User types "1000000" → displays "1,000,000"
///
/// Usage:
/// ```dart
/// CustomTextFormField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [
///     FilteringTextInputFormatter.digitsOnly,
///     NumberInputFormatter(),
///   ],
/// )
/// ```
class NumberInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the field is empty, return as-is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all commas from the new input
    final numericString = newValue.text.replaceAll(',', '');

    // If it's not a valid number, reject the change
    final number = int.tryParse(numericString);
    if (number == null) {
      return oldValue;
    }

    // Format the number with commas
    final formattedText = _formatter.format(number);

    // Calculate the new cursor position
    // We need to account for added/removed commas
    final oldCommaCount = oldValue.text.split(',').length - 1;
    final newCommaCount = formattedText.split(',').length - 1;
    final commaDifference = newCommaCount - oldCommaCount;

    // Calculate new cursor position
    int newOffset = newValue.selection.baseOffset + commaDifference;

    // Ensure cursor position is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
