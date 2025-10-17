import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

enum AppButtonColor { yellow, white, black }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonColor appButtonColor;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.appButtonColor = AppButtonColor.yellow,
    this.isFullWidth = true,
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
            AppButtonColor.yellow => AppColors.primary,
            AppButtonColor.white => AppColors.white,
            AppButtonColor.black => AppColors.black,
          },
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: appButtonColor == AppButtonColor.white
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
              AppButtonColor.yellow => AppColors.black,
              AppButtonColor.white => AppColors.primary,
              AppButtonColor.black => AppColors.white,
            },
          ),
        ),
      ),
    );
  }
}
