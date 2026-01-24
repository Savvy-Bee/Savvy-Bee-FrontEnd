import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/constants.dart';

enum InfoWidgetTextAlignment { right, center, left }

class InfoWidget extends StatelessWidget {
  final String title, subtitle;
  final Widget? icon;
  final InfoWidgetTextAlignment textAlignment;

  const InfoWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.textAlignment = InfoWidgetTextAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: switch (textAlignment) {
        InfoWidgetTextAlignment.center => CrossAxisAlignment.center,
        InfoWidgetTextAlignment.left => CrossAxisAlignment.start,
        InfoWidgetTextAlignment.right => CrossAxisAlignment.end,
      },
      children: [
        if (icon != null) SizedBox.square(dimension: 100, child: icon),
        if (icon != null) const Gap(16),
        Text(
          title,
          textAlign: switch (textAlignment) {
            InfoWidgetTextAlignment.center => TextAlign.center,
            InfoWidgetTextAlignment.left => TextAlign.left,
            InfoWidgetTextAlignment.right => TextAlign.right,
          },
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Gap(8),
        Text(
          subtitle,
          textAlign: switch (textAlignment) {
            InfoWidgetTextAlignment.center => TextAlign.center,
            InfoWidgetTextAlignment.left => TextAlign.left,
            InfoWidgetTextAlignment.right => TextAlign.right,
          },
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
