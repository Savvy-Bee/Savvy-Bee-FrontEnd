import 'package:flutter/material.dart';

import '../utils/constants.dart';

class IconTextRowWidget extends StatelessWidget {
  final String text;
  final Widget icon;
  final TextDirection? textDirection;
  final VoidCallback? onTap;

  const IconTextRowWidget(
    this.text,
    this.icon, {
    super.key,
    this.textDirection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 5,
        textDirection: textDirection,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.exconFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
