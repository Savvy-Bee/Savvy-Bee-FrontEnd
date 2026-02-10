// lib/core/widgets/custom_button.dart

import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

enum ButtonType { primary, secondary, outline, text, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final FontWeight fontWeight;
  final bool expanded;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.padding,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    // Determine colors based on button type
    Color getBackgroundColor() {
      if (isDisabled) {
        return AppColors.grey.withOpacity(0.3);
      }
      if (backgroundColor != null) {
        return backgroundColor!;
      }

      switch (type) {
        case ButtonType.primary:
          return AppColors.primary;
        case ButtonType.secondary:
          return AppColors.secondary;
        case ButtonType.outline:
          return Colors.transparent;
        case ButtonType.text:
          return Colors.transparent;
        case ButtonType.danger:
          return AppColors.error;
      }
    }

    Color getTextColor() {
      if (isDisabled && type == ButtonType.outline) {
        return AppColors.grey;
      }
      if (textColor != null) {
        return textColor!;
      }

      switch (type) {
        case ButtonType.primary:
        case ButtonType.secondary:
        case ButtonType.danger:
          return Colors.white;
        case ButtonType.outline:
          return AppColors.primary;
        case ButtonType.text:
          return AppColors.primary;
      }
    }

    Color? getBorderColor() {
      if (borderColor != null) {
        return borderColor;
      }

      switch (type) {
        case ButtonType.outline:
          return isDisabled ? AppColors.grey : AppColors.primary;
        default:
          return null;
      }
    }

    Widget buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.outline || type == ButtonType.text
                    ? AppColors.primary
                    : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: getTextColor(),
                ),
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: getBackgroundColor(),
      foregroundColor: getTextColor(),
      elevation: type == ButtonType.outline || type == ButtonType.text ? 0 : 0,
      shadowColor: Colors.transparent,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: getBorderColor() != null
            ? BorderSide(color: getBorderColor()!, width: 1.5)
            : BorderSide.none,
      ),
      minimumSize: Size(width ?? 0, height ?? 0),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }
}

// Icon Button variant
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize, color: iconColor ?? AppColors.primary),
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
