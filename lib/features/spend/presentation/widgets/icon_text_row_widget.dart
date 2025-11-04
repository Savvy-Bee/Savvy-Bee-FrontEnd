import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';

class IconTextRowWidget extends StatelessWidget {
  final String text;
  const IconTextRowWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.0),
        const Gap(4.0),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontFamily: Constants.exconFontFamily),
        ),
      ],
    );
  }
}
