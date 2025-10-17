import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

enum TextAlignment { center, left, right }

class IntroText extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextAlignment alignment;
  final bool showLogo;
  final bool isLarge;
  final Color? mainTextColor;
  final Color? subTextColor;

  const IntroText({
    super.key,
    required this.title,
    required this.subtitle,
    this.alignment = TextAlignment.center,
    this.showLogo = false,
    this.isLarge = false,
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
          Image.asset(Assets.logo),
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
            fontSize: isLarge ? 50 : 32,
            fontWeight: FontWeight.w900,
            fontFamily: Constants.exconFontFamily,
            height: 0.9,
            color: mainTextColor,
          ),
        ),
        const Gap(12.0),
        Text(
          subtitle,
          textAlign: alignment == TextAlignment.center
              ? TextAlign.center
              : alignment == TextAlignment.left
              ? TextAlign.left
              : TextAlign.right,
          style: TextStyle(
            fontSize: isLarge
                ? 14
                : 16, // Sub text is smaller when main text is larger
            fontWeight: FontWeight.normal,
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}
