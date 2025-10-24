import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextUtils {
  /// Capitalizes the first letter of a given string.
  ///
  /// Returns the string with its first letter capitalized, and the rest unchanged.
  /// If the string is null, empty, or consists only of whitespace, returns the original string.
  static String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) {
      return text ??
          ''; // Return empty string if null, or original empty string
    }
    if (text.length == 1) {
      return text.toUpperCase();
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Converts the first letter of a given string to lowercase.
  ///
  /// Returns the string with its first letter decapitalized, and the rest unchanged.
  /// If the string is null, empty, or consists only of whitespace, returns the original string.
  static String deCapitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) {
      return text ??
          ''; // Return empty string if null, or original empty string
    }
    if (text.length == 1) {
      return text.toLowerCase();
    }
    return text[0].toLowerCase() + text.substring(1);
  }

  /// Extracts initials from a full name or string.
  static String getInitials(String text) {
    if (text.isEmpty) return '';
    final words = text.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }

  /// Capitalizes the first letter of each word in a given string.
  ///
  /// Splits the string by whitespace, capitalizes each word, and joins them back.
  /// Returns the title-cased string.
  static String capitalizeWords(String? text) {
    if (text == null || text.isEmpty) {
      return text ?? '';
    }
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return '';
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Truncates a string to a specified maximum length, optionally adding an ellipsis.
  ///
  /// [text] The string to truncate.
  /// [maxLength] The maximum length of the string.
  /// [addEllipsis] Whether to add "..." if the string is truncated. Defaults to true.
  ///
  /// Returns the truncated string.
  static String truncate(
    String? text,
    int maxLength, {
    bool addEllipsis = true,
  }) {
    if (text == null || text.length <= maxLength) {
      return text ?? '';
    }
    if (addEllipsis) {
      return '${text.substring(0, maxLength - 3)}...';
    } else {
      return text.substring(0, maxLength);
    }
  }

  /// Removes all whitespace characters from a string.
  static String removeAllWhitespace(String? text) {
    if (text == null || text.isEmpty) {
      return text ?? '';
    }
    return text.replaceAll(
      RegExp(r'\s+'),
      '',
    ); // Replaces one or more whitespace chars with nothing
  }

  /// Checks if a string contains only digits.
  static bool isNumeric(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }
    return double.tryParse(text) != null; // Simpler check for numbers
  }

  /// Checks if the text contains at least one lowercase letter
  static bool hasLowercase(String? text) {
    if (text == null || text.isEmpty) return false;
    return text.contains(RegExp(r'[a-z]'));
  }

  /// Checks if the text contains at least one uppercase letter
  static bool hasUppercase(String? text) {
    if (text == null || text.isEmpty) return false;
    return text.contains(RegExp(r'[A-Z]'));
  }

  /// Checks if the text contains at least one special character
  static bool hasSpecialCharacter(String? text) {
    if (text == null || text.isEmpty) return false;
    return text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  /// Checks if the text contains at least one number
  static bool hasNumber(String? text) {
    if (text == null || text.isEmpty) return false;
    return text.contains(RegExp(r'[0-9]'));
  }

  /// Checks if the text is at least 8 to 64 characters long
  static bool isAtLeastEightChars(String? text) {
    if (text == null) return false;
    return text.length >= 8 && text.length <= 64;
  }

  /// Checks if the text meets all password requirements:
  /// - Contains at least one lowercase letter
  /// - Contains at least one uppercase letter
  /// - Contains at least one special character
  /// - Contains at least one number
  /// - Is at least eight characters long
  static bool isPasswordValid(String? text) {
    return hasLowercase(text) &&
        hasUppercase(text) &&
        hasSpecialCharacter(text) &&
        hasNumber(text) &&
        isAtLeastEightChars(text);
  }

  /// Get password strength (0-5)
  static int getPasswordStrength(String password) {
    int strength = 0;
    if (hasUppercase(password)) strength++;
    if (hasLowercase(password)) strength++;
    if (hasNumber(password)) strength++;
    if (hasSpecialCharacter(password)) strength++;
    if (isAtLeastEightChars(password)) strength++;
    return strength;
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(String password) {
    final strength = getPasswordStrength(password);
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
  static List<TextSpan> buildTextSpansWithMentions(
    String? text, {
    TextStyle? normalStyle,
    TextStyle? mentionStyle,
    VoidCallback? onMentionPressed,
  }) {
    if (text == null || text.isEmpty) return [TextSpan(text: text ?? '')];

    final List<TextSpan> spans = [];
    final RegExp mentionRegex = RegExp(r'@[\w]+');
    final matches = mentionRegex.allMatches(text);

    int currentIndex = 0;

    for (final match in matches) {
      // Add text before the mention
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
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
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(text: text.substring(currentIndex), style: normalStyle),
      );
    }

    return spans;
  }
}
