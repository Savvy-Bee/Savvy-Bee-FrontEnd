import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

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
            // side: buttonColor == CustomButtonColor.white
            //     ? BorderSide(color: AppColors.primary, width: 1.0)
            //     : BorderSide.none,
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
                      ? Icon(Icons.arrow_forward, color: forgroundColor)
                      : null),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: forgroundColor,
          ),
          // style: theme.textTheme.titleMedium?.copyWith(
          //   fontWeight: FontWeight.w600,
          //   color: switch (buttonColor) {
          //     CustomButtonColor.yellow => AppColors.black,
          //     CustomButtonColor.white => AppColors.primary,
          //     CustomButtonColor.black => AppColors.white,
          //   },
          // ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.grey),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(8),
          if (icon != null) icon!,
        ],
      ),
    );
  }
}
