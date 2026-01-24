import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  final Widget? actionWidget;

  const SectionTitleWidget({super.key, required this.title, this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        if (actionWidget != null) actionWidget!,
      ],
    );
  }
}
