import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';

enum CustomButtonColor { yellow, white, black }

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonColor buttonColor;
  final bool isFullWidth;
  final bool rounded;
  final bool showArrow;
  final bool isLoading;
  final bool isSmall;
  final Widget? icon;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.buttonColor = CustomButtonColor.yellow,
    this.isFullWidth = true,
    this.rounded = false,
    this.showArrow = false,
    this.isLoading = false,
    this.isSmall = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var forgroundColor = switch (buttonColor) {
      CustomButtonColor.yellow => AppColors.black,
      CustomButtonColor.white => AppColors.black,
      CustomButtonColor.black => AppColors.white,
    };

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: switch (buttonColor) {
            CustomButtonColor.yellow => AppColors.primary,
            CustomButtonColor.white => AppColors.white,
            CustomButtonColor.black => AppColors.black,
          },
          padding: EdgeInsets.symmetric(
            vertical: isSmall ? 10 : 14,
            horizontal: 44,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: rounded
                ? BorderRadius.circular(99)
                : BorderRadius.circular(8),
            side: BorderSide.none,
          ),
          elevation: 0,
        ),
        icon: isLoading
            ? SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: forgroundColor,
                ),
              )
            : icon ??
                  (showArrow
                      ? AppIcon(AppIcons.arrowRightIcon, color: forgroundColor)
                      : null),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: forgroundColor,
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool rounded;
  final bool showArrow;
  final bool isLoading;
  final bool isSmall;
  final Widget? icon;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isFullWidth = true,
    this.rounded = false,
    this.showArrow = false,
    this.isLoading = false,
    this.isSmall = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          iconAlignment: IconAlignment.end,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.grey),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isSmall ? 10 : 14,
            horizontal: 44,
          ),
        ),
        icon: isLoading
            ? SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.black,
                ),
              )
            : icon ??
                  (showArrow
                      ? AppIcon(AppIcons.arrowRightIcon, color: AppColors.black)
                      : null),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}
