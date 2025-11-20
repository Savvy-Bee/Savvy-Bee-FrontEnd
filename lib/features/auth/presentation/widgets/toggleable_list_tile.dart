import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

class ToggleableListTile extends StatelessWidget {
  final String? iconPath;
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? leading;

  const ToggleableListTile({
    super.key,
    this.iconPath,
    required this.text,
    this.isSelected = false,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      borderRadius: 8,
      borderColor: isSelected ? AppColors.grey : AppColors.greyMid,
      bgColor: isSelected ? AppColors.primaryFaint : null,
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) leading!,
          if (iconPath != null && iconPath!.isNotEmpty) AppIcon(iconPath!),
          // if (iconPath != null && iconPath!.isNotEmpty) const Gap(8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
