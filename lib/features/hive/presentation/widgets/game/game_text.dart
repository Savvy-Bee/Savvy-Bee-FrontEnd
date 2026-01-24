import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/constants.dart';

class GameText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double? height, outlineWidth;
  const GameText({
    super.key,
    required this.text,
    required this.fontSize,
    this.height,
    this.outlineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outline
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize + 1,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
            height: height,
            fontFamily: Constants.londrinaSolidFontFamily,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth ?? 1
              ..color = AppColors.primaryDark,
          ),
        ),
        // Foreground text
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
            height: height,
            fontFamily: Constants.londrinaSolidFontFamily,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
