import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';

/// Widget helper for displaying formatted chat messages
class FormattedChatMessage extends StatelessWidget {
  final String message;
  final TextStyle? style;
  final Color? linkColor;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const FormattedChatMessage({
    super.key,
    required this.message,
    this.style,
    this.linkColor = AppColors.primaryDark,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // Use RichText for formatted messages, Text for plain messages
    if (message.hasFormatting) {
      return RichText(
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.clip,
        textAlign: textAlign ?? TextAlign.start,
        text: TextSpan(
          children: message.toFormattedTextSpans(
            baseStyle: style ?? DefaultTextStyle.of(context).style,
            linkColor: linkColor ?? Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return Text(
      message.formatChatMessage(),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
