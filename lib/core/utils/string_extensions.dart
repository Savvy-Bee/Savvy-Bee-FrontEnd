import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Extension for formatting chat messages with rich text support
extension ChatMessageFormatting on String {
  /// Format message for display with proper line breaks, lists, and styling
  ///
  /// Handles:
  /// - Numbered lists (1), 2), 3))
  /// - Bullet points (-, *, •)
  /// - Line breaks and spacing
  /// - Bold text (**text** or __text__)
  /// - Italic text (*text* or _text_)
  /// - Code blocks (`code`)
  /// - Emojis
  String formatChatMessage() {
    String formatted = this;

    // Normalize line breaks (handle \n, \r\n, etc.)
    formatted = formatted.replaceAll('\r\n', '\n');
    formatted = formatted.replaceAll('\r', '\n');

    // Remove excessive spacing while preserving intentional breaks
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Clean up spaces around line breaks
    formatted = formatted.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    formatted = formatted.replaceAll(RegExp(r'\n[ \t]+'), '\n');

    return formatted.trim();
  }

  /// Convert formatted text to Flutter RichText widgets
  /// This provides proper rendering of styled text
  List<TextSpan> toFormattedTextSpans({
    TextStyle? baseStyle,
    Color? linkColor,
  }) {
    final List<TextSpan> spans = [];
    final lines = formatChatMessage().split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        // Add spacing for empty lines
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // Check if line is a list item
      final listMatch = RegExp(r'^(\s*)([-*•]|\d+\))\s+(.+)$').firstMatch(line);

      if (listMatch != null) {
        final indent = listMatch.group(1) ?? '';
        final marker = listMatch.group(2) ?? '';
        final content = listMatch.group(3) ?? '';

        // Calculate indentation level (4 spaces = 1 level)
        final indentLevel = indent.length ~/ 4;
        final indentSpaces = '    ' * indentLevel; // 4 spaces per level

        // Add indentation
        if (indentSpaces.isNotEmpty) {
          spans.add(TextSpan(text: indentSpaces));
        }

        // Convert marker to proper format
        String displayMarker;
        if (marker.startsWith(RegExp(r'\d'))) {
          // Number format: "1)" -> "1. "
          final number = marker.substring(0, marker.length - 1);
          displayMarker = '\t\t\t\t$number. ';
        } else {
          // Bullet format: convert all to bullet point character
          displayMarker = '\t\t\t\t• ';
        }

        // Add bullet/number with special styling
        spans.add(
          TextSpan(
            text: displayMarker,
            style: baseStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
        );

        // Add content with inline formatting
        spans.addAll(
          _parseInlineFormatting(
            content,
            baseStyle: baseStyle,
            linkColor: linkColor,
          ),
        );
      } else {
        // Regular line with inline formatting
        spans.addAll(
          _parseInlineFormatting(
            line,
            baseStyle: baseStyle,
            linkColor: linkColor,
          ),
        );
      }

      // Add line break if not last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  /// Parse inline formatting like bold, italic, code, and links
  List<TextSpan> _parseInlineFormatting(
    String text, {
    TextStyle? baseStyle,
    Color? linkColor,
  }) {
    final List<TextSpan> spans = [];
    final buffer = StringBuffer();
    int i = 0;

    while (i < text.length) {
      // Check for markdown links [text](url)
      if (text[i] == '[') {
        final linkMatch = RegExp(
          r'\[([^\]]+)\]\(([^\)]+)\)',
        ).matchAsPrefix(text, i);

        if (linkMatch != null) {
          if (buffer.isNotEmpty) {
            spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
            buffer.clear();
          }

          final linkText = linkMatch.group(1) ?? '';
          final url = linkMatch.group(2) ?? '';

          spans.add(
            TextSpan(
              text: linkText,
              style: baseStyle?.copyWith(
                color: linkColor ?? Colors.blue,
                decoration: TextDecoration.underline,
              ),
              // Note: For clickable links, use url_launcher with GestureRecognizer
              // recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url)),
            ),
          );

          i += linkMatch.group(0)!.length;
          continue;
        }
      }

      // Check for bold (**text** or __text__)
      if (_matchesAt(text, i, '**') || _matchesAt(text, i, '__')) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }

        final delimiter = text.substring(i, i + 2);
        final endIndex = text.indexOf(delimiter, i + 2);

        if (endIndex != -1) {
          final boldText = text.substring(i + 2, endIndex);
          spans.add(
            TextSpan(
              text: boldText,
              style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
          i = endIndex + 2;
          continue;
        }
      }

      // Check for italic (*text* or _text_) - only if not part of bold
      if ((text[i] == '*' || text[i] == '_') &&
          (i == 0 || text[i - 1] != text[i])) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }

        final delimiter = text[i];
        final endIndex = _findNextDelimiter(text, i + 1, delimiter);

        if (endIndex != -1) {
          final italicText = text.substring(i + 1, endIndex);
          spans.add(
            TextSpan(
              text: italicText,
              style: baseStyle?.copyWith(fontStyle: FontStyle.italic),
            ),
          );
          i = endIndex + 1;
          continue;
        }
      }

      // Check for code (`text`)
      if (text[i] == '`') {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }

        final endIndex = text.indexOf('`', i + 1);

        if (endIndex != -1) {
          final codeText = text.substring(i + 1, endIndex);
          spans.add(
            TextSpan(
              text: codeText,
              style: baseStyle?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          );
          i = endIndex + 1;
          continue;
        }
      }

      buffer.write(text[i]);
      i++;
    }

    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  bool _matchesAt(String text, int index, String pattern) {
    if (index + pattern.length > text.length) return false;
    return text.substring(index, index + pattern.length) == pattern;
  }

  int _findNextDelimiter(String text, int start, String delimiter) {
    for (int i = start; i < text.length; i++) {
      if (text[i] == delimiter) {
        // Make sure it's not escaped or part of a double delimiter
        if (i + 1 < text.length && text[i + 1] == delimiter) {
          continue;
        }
        return i;
      }
    }
    return -1;
  }

  /// Extract plain text without formatting markers
  String get plainText {
    String plain = this;

    // Remove markdown links [text](url) -> text
    plain = plain.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');

    // Remove markdown formatting
    plain = plain.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1'); // Bold
    plain = plain.replaceAll(RegExp(r'__(.+?)__'), r'$1'); // Bold
    plain = plain.replaceAll(RegExp(r'\*(.+?)\*'), r'$1'); // Italic
    plain = plain.replaceAll(RegExp(r'_(.+?)_'), r'$1'); // Italic
    plain = plain.replaceAll(RegExp(r'`(.+?)`'), r'$1'); // Code

    return plain.formatChatMessage();
  }

  /// Check if message contains formatting
  bool get hasFormatting {
    return contains(RegExp(r'\*\*|\*|__| _|`|\[[^\]]+\]\([^\)]+\)')) ||
        contains(RegExp(r'^\s*[-*•\d+\)]\s+', multiLine: true));
  }

  /// Get a preview of the message (first line or truncated)
  String preview({int maxLength = 50}) {
    final plain = plainText;
    final firstLine = plain.split('\n').first.trim();

    if (firstLine.length <= maxLength) {
      return firstLine;
    }

    return '${firstLine.substring(0, maxLength)}...';
  }

  /// Extract all URLs from the message (both plain and markdown links)
  List<String> extractUrls() {
    final urls = <String>[];

    // Extract from markdown links [text](url)
    final markdownLinkPattern = RegExp(r'\[([^\]]+)\]\(([^\)]+)\)');
    for (final match in markdownLinkPattern.allMatches(this)) {
      urls.add(match.group(2)!);
    }

    // Extract plain URLs
    final urlPattern = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    for (final match in urlPattern.allMatches(this)) {
      final url = match.group(0)!;
      if (!urls.contains(url)) {
        urls.add(url);
      }
    }

    return urls;
  }

  /// Extract markdown links with their text
  List<({String text, String url})> extractMarkdownLinks() {
    final links = <({String text, String url})>[];
    final pattern = RegExp(r'\[([^\]]+)\]\(([^\)]+)\)');

    for (final match in pattern.allMatches(this)) {
      links.add((text: match.group(1)!, url: match.group(2)!));
    }

    return links;
  }

  /// Check if message is a list
  bool get isList {
    final lines = split('\n').where((l) => l.trim().isNotEmpty);
    return lines.any((line) => RegExp(r'^\s*[-*•\d+\)]\s+').hasMatch(line));
  }

  /// Count list items
  int get listItemCount {
    if (!isList) return 0;
    return split(
      '\n',
    ).where((line) => RegExp(r'^\s*[-*•\d+\)]\s+').hasMatch(line)).length;
  }
}

/// Extension for formatting chat messages with rich text support including clickable links
extension ChatMessageFormattingWithLinks on String {
  /// Convert formatted text to Flutter TextSpans with clickable links
  List<TextSpan> toFormattedTextSpansWithLinks({
    TextStyle? baseStyle,
    Color? linkColor,
    Function(String url)? onLinkTap,
  }) {
    final List<TextSpan> spans = [];
    final lines = formatChatMessage().split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // Check if line is a list item
      final listMatch = RegExp(r'^(\s*)([-*•]|\d+\))\s+(.+)$').firstMatch(line);

      if (listMatch != null) {
        final indent = listMatch.group(1) ?? '';
        final marker = listMatch.group(2) ?? '';
        final content = listMatch.group(3) ?? '';

        // Calculate indentation
        final indentLevel = indent.length ~/ 4;
        final indentSpaces = '    ' * indentLevel;

        if (indentSpaces.isNotEmpty) {
          spans.add(TextSpan(text: indentSpaces));
        }

        // Convert marker to proper format
        String displayMarker;
        if (marker.startsWith(RegExp(r'\d'))) {
          final number = marker.substring(0, marker.length - 1);
          displayMarker = '$number. ';
        } else {
          displayMarker = '● ';
        }

        spans.add(
          TextSpan(
            text: displayMarker,
            style: baseStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
        );

        // Add content with inline formatting and clickable links
        spans.addAll(
          _parseInlineFormattingWithLinks(
            content,
            baseStyle: baseStyle,
            linkColor: linkColor,
            onLinkTap: onLinkTap,
          ),
        );
      } else {
        spans.addAll(
          _parseInlineFormattingWithLinks(
            line,
            baseStyle: baseStyle,
            linkColor: linkColor,
            onLinkTap: onLinkTap,
          ),
        );
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  /// Parse inline formatting with clickable links
  List<TextSpan> _parseInlineFormattingWithLinks(
    String text, {
    TextStyle? baseStyle,
    Color? linkColor,
    Function(String url)? onLinkTap,
  }) {
    final List<TextSpan> spans = [];
    final buffer = StringBuffer();
    int i = 0;

    while (i < text.length) {
      // Check for markdown links [text](url)
      if (text[i] == '[') {
        final linkMatch = RegExp(
          r'\[([^\]]+)\]\(([^\)]+)\)',
        ).matchAsPrefix(text, i);

        if (linkMatch != null) {
          if (buffer.isNotEmpty) {
            spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
            buffer.clear();
          }

          final linkText = linkMatch.group(1) ?? '';
          final url = linkMatch.group(2) ?? '';

          spans.add(
            TextSpan(
              text: linkText,
              style: baseStyle?.copyWith(
                color: linkColor ?? Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (onLinkTap != null) {
                    onLinkTap(url);
                  } else {
                    _launchURL(url);
                  }
                },
            ),
          );

          i += linkMatch.group(0)!.length;
          continue;
        }
      }

      // Check for bold (**text** or __text__)
      if (_matchesAt(text, i, '**') || _matchesAt(text, i, '__')) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }

        final delimiter = text.substring(i, i + 2);
        final endIndex = text.indexOf(delimiter, i + 2);

        if (endIndex != -1) {
          final boldText = text.substring(i + 2, endIndex);
          spans.add(
            TextSpan(
              text: boldText,
              style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
          i = endIndex + 2;
          continue;
        }
      }

      // Check for italic (*text* or _text_)
      if ((text[i] == '*' || text[i] == '_') &&
          (i == 0 || text[i - 1] != text[i])) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }

        final delimiter = text[i];
        final endIndex = _findNextDelimiter(text, i + 1, delimiter);

        if (endIndex != -1) {
          final italicText = text.substring(i + 1, endIndex);
          spans.add(
            TextSpan(
              text: italicText,
              style: baseStyle?.copyWith(fontStyle: FontStyle.italic),
            ),
          );
          i = endIndex + 1;
          continue;
        }
      }

      // Check for code (`text`)
      if (text[i] == '`') {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }

        final endIndex = text.indexOf('`', i + 1);

        if (endIndex != -1) {
          final codeText = text.substring(i + 1, endIndex);
          spans.add(
            TextSpan(
              text: codeText,
              style: baseStyle?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.grey.withOpacity(0.1),
              ),
            ),
          );
          i = endIndex + 1;
          continue;
        }
      }

      buffer.write(text[i]);
      i++;
    }

    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  bool _matchesAt(String text, int index, String pattern) {
    if (index + pattern.length > text.length) return false;
    return text.substring(index, index + pattern.length) == pattern;
  }

  int _findNextDelimiter(String text, int start, String delimiter) {
    for (int i = start; i < text.length; i++) {
      if (text[i] == delimiter) {
        if (i + 1 < text.length && text[i + 1] == delimiter) {
          continue;
        }
        return i;
      }
    }
    return -1;
  }

  /// Helper to launch URLs
  static Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
