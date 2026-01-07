import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';

enum TextAlignment { center, left, right }

class IntroText extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlignment alignment;
  final bool showLogo;
  final bool isLarge;
  final Color? mainTextColor;
  final Color? subTextColor;

  const IntroText({
    super.key,
    required this.title,
    this.subtitle,
    this.alignment = TextAlignment.left,
    this.showLogo = false,
    this.isLarge = true,
    this.mainTextColor,
    this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment == TextAlignment.center
          ? CrossAxisAlignment.center
          : alignment == TextAlignment.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        if (showLogo) ...[
          const Gap(8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(Logos.logo, scale: 5),
              Image.asset(Logos.logoText),
            ],
          ),
          const Gap(16.0),
        ],
        Text(
          title,
          textAlign: alignment == TextAlignment.center
              ? TextAlign.center
              : alignment == TextAlignment.left
              ? TextAlign.left
              : TextAlign.right,
          style: TextStyle(
            fontSize: isLarge ? 32 : 24,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: mainTextColor,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) const Gap(12.0),
        if (subtitle != null && subtitle!.isNotEmpty)
          Text(
            subtitle!,
            textAlign: alignment == TextAlignment.center
                ? TextAlign.center
                : alignment == TextAlignment.left
                ? TextAlign.left
                : TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: subTextColor,
            ),
          ),
      ],
    );
  }
}
