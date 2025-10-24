import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

enum CustomButtonColor { yellow, white, black }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonColor appButtonColor;
  final bool isFullWidth;
  final bool rounded;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.appButtonColor = CustomButtonColor.yellow,
    this.isFullWidth = true,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: switch (appButtonColor) {
            CustomButtonColor.yellow => AppColors.primary,
            CustomButtonColor.white => AppColors.white,
            CustomButtonColor.black => AppColors.black,
          },
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: rounded
                ? BorderRadius.circular(99)
                : BorderRadius.circular(12),
            side: appButtonColor == CustomButtonColor.white
                ? BorderSide(color: AppColors.primary, width: 1.0)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: switch (appButtonColor) {
              CustomButtonColor.yellow => AppColors.black,
              CustomButtonColor.white => AppColors.primary,
              CustomButtonColor.black => AppColors.white,
            },
          ),
        ),
      ),
    );
  }
}
