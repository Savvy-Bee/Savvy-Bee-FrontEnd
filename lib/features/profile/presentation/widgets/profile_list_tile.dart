import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

class ProfileListTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;
  final Color? textColor;
  final bool useDefaultTrailing;
  final Widget? trailing;

  const ProfileListTile({
    super.key,
    required this.title,
    required this.iconPath,
    this.onTap,
    this.textColor,
    this.useDefaultTrailing = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(iconPath, useOriginal: true),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: Constants.neulisNeueFontFamily,
                    color: textColor,
                  ),
                ),
              ],
            ),
            if (useDefaultTrailing) Icon(Icons.keyboard_arrow_right),
            if (!useDefaultTrailing && trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
