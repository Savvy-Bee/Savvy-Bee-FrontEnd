import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/dot.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';

class QuizeOptionTile extends StatelessWidget {
  final String quizType;
  final String text;
  final Color? color;
  final VoidCallback? onTap;
  final bool isSelected;
  final TextAlign? textAlign;

  const QuizeOptionTile({
    super.key,
    this.quizType = 'multiChoice',
    required this.text,
    this.color,
    this.onTap,
    this.isSelected = false,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: quizType == 'multiChoice' ? 30 : 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          border: Border.all(
            width: isSelected ? 2 : 1,
            color:
                color ??
                (isSelected
                    ? AppColors.primary
                    : AppColors.grey.withOpacity(0.6)),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              color: AppColors.grey.withOpacity(0.6),
            ),
          ],
        ),
        child: Row(
          children: [
            if (quizType == 'reorder') ...[
              AppIcon(AppIcons.gripIcon, size: 20),
              const SizedBox(width: 16),
            ],
            if (quizType == 'multiChoice') ...[
              Dot(
                size: 20,
                color: color ?? (isSelected ? null : AppColors.greyMid),
                border: Border.all(
                  color: AppColors.greyMid,
                  width: 4,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                text,
                textAlign: textAlign,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
