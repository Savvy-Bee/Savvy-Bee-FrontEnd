import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

class TextIconButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const TextIconButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
            AppIcon(AppIcons.arrowRightIcon),
          ],
        ),
      ),
    );
  }
}
