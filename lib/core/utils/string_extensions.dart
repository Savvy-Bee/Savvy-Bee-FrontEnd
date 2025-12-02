import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Returns the string with its first letter capitalized, and the rest unchanged.
  /// If the string is empty, returns the original string.
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }

  /// Converts the first letter of the string to lowercase.
  ///
  /// Returns the string with its first letter decapitalized, and the rest unchanged.
  /// If the string is empty, returns the original string.
  String decapitalizeFirstLetter() {
    if (isEmpty) return this;
    if (length == 1) return toLowerCase();
    return this[0].toLowerCase() + substring(1);
  }

  /// Extracts initials from a full name or string.
  String getInitials() {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }

  /// Capitalizes the first letter of each word in the string.
  ///
  /// Splits the string by whitespace, capitalizes each word, and joins them back.
  /// Returns the title-cased string.
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Truncates the string to a specified maximum length, optionally adding an ellipsis.
  ///
  /// [maxLength] The maximum length of the string.
  /// [addEllipsis] Whether to add "..." if the string is truncated. Defaults to true.
  ///
  /// Returns the truncated string.
  String truncate(int maxLength, {bool addEllipsis = true}) {
    if (length <= maxLength) return this;
    if (addEllipsis) {
      return '${substring(0, maxLength - 3)}...';
    } else {
      return substring(0, maxLength);
    }
  }

  /// Removes all whitespace characters from the string.
  String removeAllWhitespace() {
    if (isEmpty) return this;
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Checks if the string contains only digits.
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  /// Checks if the string contains at least one lowercase letter
  bool get hasLowercase {
    if (isEmpty) return false;
    return contains(RegExp(r'[a-z]'));
  }

  /// Checks if the string contains at least one uppercase letter
  bool get hasUppercase {
    if (isEmpty) return false;
    return contains(RegExp(r'[A-Z]'));
  }

  /// Checks if the string contains at least one special character
  bool get hasSpecialCharacter {
    if (isEmpty) return false;
    return contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  /// Checks if the string contains at least one number
  bool get hasNumber {
    if (isEmpty) return false;
    return contains(RegExp(r'[0-9]'));
  }

  /// Checks if the string is at least 8 to 64 characters long
  bool get isAtLeastEightChars {
    return length >= 8 && length <= 64;
  }

  /// Checks if the string meets all password requirements:
  /// - Contains at least one lowercase letter
  /// - Contains at least one uppercase letter
  /// - Contains at least one special character
  /// - Contains at least one number
  /// - Is at least 8 characters long
  bool get isPasswordValid {
    return hasLowercase &&
        hasUppercase &&
        hasSpecialCharacter &&
        hasNumber &&
        isAtLeastEightChars;
  }

  /// Get password strength (0-5)
  int get passwordStrength {
    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasNumber) strength++;
    if (hasSpecialCharacter) strength++;
    if (isAtLeastEightChars) strength++;
    return strength;
  }

  /// Get password strength label
  String get passwordStrengthLabel {
    final strength = passwordStrength;
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return 'Unknown';
    }
  }

  /// Creates a list of TextSpan widgets with highlighted mentions
  List<TextSpan> buildTextSpansWithMentions({
    TextStyle? normalStyle,
    TextStyle? mentionStyle,
    VoidCallback? onMentionPressed,
  }) {
    if (isEmpty) return [TextSpan(text: this)];

    final List<TextSpan> spans = [];
    final RegExp mentionRegex = RegExp(r'@[\w]+');
    final matches = mentionRegex.allMatches(this);

    int currentIndex = 0;

    for (final match in matches) {
      // Add text before the mention
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: substring(currentIndex, match.start),
            style: normalStyle,
          ),
        );
      }

      // Add the highlighted mention
      spans.add(
        TextSpan(
          text: match.group(0),
          style: mentionStyle,
          recognizer: TapGestureRecognizer()..onTap = onMentionPressed,
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text after the last mention
    if (currentIndex < length) {
      spans.add(TextSpan(text: substring(currentIndex), style: normalStyle));
    }

    return spans;
  }
}

/// Extension for nullable strings
extension NullableStringExtensions on String? {
  /// Capitalizes the first letter of a given string.
  ///
  /// Returns the string with its first letter capitalized, and the rest unchanged.
  /// If the string is null or empty, returns empty string.
  String capitalizeFirstLetter() {
    if (this == null || this!.isEmpty) return '';
    return this!.capitalizeFirstLetter();
  }

  /// Converts the first letter of a given string to lowercase.
  ///
  /// Returns the string with its first letter decapitalized, and the rest unchanged.
  /// If the string is null or empty, returns empty string.
  String decapitalizeFirstLetter() {
    if (this == null || this!.isEmpty) return '';
    return this!.decapitalizeFirstLetter();
  }

  /// Capitalizes the first letter of each word in a given string.
  ///
  /// Returns the title-cased string or empty string if null.
  String capitalizeWords() {
    if (this == null || this!.isEmpty) return '';
    return this!.capitalizeWords();
  }

  /// Truncates a string to a specified maximum length, optionally adding an ellipsis.
  String truncate(int maxLength, {bool addEllipsis = true}) {
    if (this == null) return '';
    return this!.truncate(maxLength, addEllipsis: addEllipsis);
  }

  /// Removes all whitespace characters from a string.
  String removeAllWhitespace() {
    if (this == null || this!.isEmpty) return '';
    return this!.removeAllWhitespace();
  }

  /// Checks if a string contains only digits.
  bool get isNumeric {
    if (this == null || this!.isEmpty) return false;
    return this!.isNumeric;
  }

  /// Safe way to check if string is null or empty
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }

  /// Safe way to check if string is not null and not empty
  bool get isNotNullOrEmpty {
    return this != null && this!.isNotEmpty;
  }

  /// Returns the string or a default value if null or empty
  String orDefault(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}
