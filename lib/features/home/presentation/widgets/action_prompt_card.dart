import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class ActionPromptCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final Color backgroundColor;
  final Color? textColor;
  final Color? buttonBorderColor;
  final Color? buttonTextColor;
  final VoidCallback onButtonPressed;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;

  const ActionPromptCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.backgroundColor,
    required this.onButtonPressed,
    this.textColor,
    this.buttonBorderColor,
    this.buttonTextColor,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.black;
    final effectiveButtonBorderColor = buttonBorderColor ?? Colors.black;
    final effectiveButtonTextColor = buttonTextColor ?? Colors.black;

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 32),
        border: BoxBorder.all(
          width: borderWidth ?? 1,
          color: borderColor ?? Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              color: effectiveTextColor,
              height: 1.3,
            ),
          ),
          const Gap(12),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              color: effectiveTextColor,
              height: 1.5,
            ),
          ),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onButtonPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: backgroundColor,
                side: BorderSide(color: effectiveButtonBorderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  color: effectiveButtonTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
