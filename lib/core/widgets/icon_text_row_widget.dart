import 'package:flutter/material.dart';

import '../utils/constants.dart';

class IconTextRowWidget extends StatelessWidget {
  final String text;
  final Widget icon;
  final TextDirection? textDirection;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final double? spacing;
  final EdgeInsetsGeometry? padding;

  const IconTextRowWidget(
    this.text,
    this.icon, {
    super.key,
    this.textDirection,
    this.onTap,
    this.textStyle,
    this.spacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(5),
        child: Row(
          spacing: spacing ?? 5,
          textDirection: textDirection,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            Text(
              text,
              style:
                  textStyle ??
                  TextStyle(
                    fontSize: 12,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
