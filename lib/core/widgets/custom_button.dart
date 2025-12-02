import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';

enum CustomButtonColor { yellow, white, black, red, green }

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonColor buttonColor;
  final bool isFullWidth;
  final bool rounded;
  final bool showArrow;
  final bool isLoading;
  final bool isSmall;
  final bool isGamePlay;
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
    this.isGamePlay = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var forgroundColor = switch (buttonColor) {
      CustomButtonColor.yellow => AppColors.black,
      CustomButtonColor.white => AppColors.black,
      CustomButtonColor.black => AppColors.white,
      CustomButtonColor.red => AppColors.white,
      CustomButtonColor.green => AppColors.white,
    };

    final disabledForegroundColor = AppColors.grey;

    var backgroundColor = switch (buttonColor) {
      CustomButtonColor.yellow => AppColors.primary,
      CustomButtonColor.white => AppColors.white,
      CustomButtonColor.black => AppColors.black,
      CustomButtonColor.red => AppColors.error,
      CustomButtonColor.green => AppColors.success,
    };
    var boxShadow = [
      BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 0,
        spreadRadius: 0,
        color: backgroundColor.withValues(alpha: 0.5),
      ),
    ];

    return Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        boxShadow: isGamePlay ? boxShadow : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
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
                  color: onPressed == null
                      ? disabledForegroundColor
                      : forgroundColor,
                ),
              )
            : icon ??
                  (showArrow
                      ? AppIcon(
                          AppIcons.arrowRightIcon,
                          color: onPressed == null
                              ? disabledForegroundColor
                              : forgroundColor,
                        )
                      : null),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: onPressed == null ? disabledForegroundColor : forgroundColor,
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
          backgroundColor: AppColors.white,
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

class ShareButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ShareButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(8);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 0,
            spreadRadius: 0,
            color: AppColors.greyMid,
          ),
        ],
        borderRadius: borderRadius,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: AppIcon(AppIcons.shareIcon, color: AppColors.black),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: BorderSide(
            color: AppColors.greyMid,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          padding: const EdgeInsets.all(14),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
        ),
      ),
    );
  }
}
