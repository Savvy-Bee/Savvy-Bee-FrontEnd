import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final String? logoutButtonText;
  final VoidCallback? onLogoutPressed;
  final Color? iconColor;
  final double? iconSize;
  final bool isActionButtonFilled;

  /// When true, the action button shows a small circular spinner instead of
  /// its label and its [onActionPressed] is disabled. Use this to indicate
  /// that a reload / retry is in progress.
  final bool isActionLoading;

  const CustomErrorWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.actionButtonText,
    this.onActionPressed,
    this.logoutButtonText,
    this.onLogoutPressed,
    this.iconColor,
    this.iconSize,
    this.isActionButtonFilled = false,
    this.isActionLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize ?? 48,
                color: iconColor ?? theme.colorScheme.error,
              ),
              const Gap(24),
            ],

            // Title
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(4),
            ],

            // Subtitle
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  fontFamily: 'GeneralSans',
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
            ],

            // Action Button — shows spinner when isActionLoading is true
            if (actionButtonText != null || isActionLoading)
              TextButton(
                onPressed: isActionLoading ? null : onActionPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.black,
                  backgroundColor:
                      isActionButtonFilled ? AppColors.primary : null,
                ),
                child: isActionLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.black),
                        ),
                      )
                    : Text(
                        actionButtonText!,
                        style: const TextStyle(fontFamily: 'GeneralSans'),
                      ),
              ),

            // Logout Button
            if (logoutButtonText != null && onLogoutPressed != null)
              TextButton(
                onPressed: onLogoutPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  backgroundColor:
                      isActionButtonFilled ? AppColors.primary : null,
                ),
                child: Text(
                  logoutButtonText!,
                  style: const TextStyle(fontFamily: 'GeneralSans'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Network error state
  factory CustomErrorWidget.network({
    String? title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      icon: Icons.wifi_off_rounded,
      title: title ?? 'No Internet Connection',
      subtitle: subtitle ?? 'Please check your connection and try again.',
      actionButtonText: 'Retry',
      onActionPressed: onRetry,
    );
  }

  /// Generic error state
  factory CustomErrorWidget.error({
    String? title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      icon: Icons.error_outline_rounded,
      title: title ?? 'Something Went Wrong',
      subtitle: subtitle ?? 'An unexpected error occurred. Please try again.',
      actionButtonText: onRetry != null ? 'Retry' : null,
      onActionPressed: onRetry,
    );
  }

  /// Empty state
  factory CustomErrorWidget.empty({
    String? title,
    String? subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return CustomErrorWidget(
      icon: Icons.inbox_rounded,
      title: title ?? 'No Data Available',
      subtitle: subtitle,
      actionButtonText: actionText,
      onActionPressed: onAction,
      iconColor: Colors.grey,
    );
  }

  /// Server error state
  factory CustomErrorWidget.serverError({
    String? title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      icon: Icons.cloud_off_rounded,
      title: title ?? 'Server Error',
      subtitle:
          subtitle ?? 'Unable to reach the server. Please try again later.',
      actionButtonText: 'Retry',
      onActionPressed: onRetry,
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

// class CustomErrorWidget extends StatelessWidget {
//   final String? title;
//   final String? subtitle;
//   final IconData? icon;
//   final String? actionButtonText;
//   final VoidCallback? onActionPressed;
//   final String? logoutButtonText;
//   final VoidCallback? onLogoutPressed;
//   final Color? iconColor;
//   final double? iconSize;
//   final bool isActionButtonFilled;

//   const CustomErrorWidget({
//     super.key,
//     this.title,
//     this.subtitle,
//     this.icon,
//     this.actionButtonText,
//     this.onActionPressed,
//     this.logoutButtonText,
//     this.onLogoutPressed,
//     this.iconColor,
//     this.iconSize,
//     this.isActionButtonFilled = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 48.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Icon
//             if (icon != null) ...[
//               Icon(
//                 icon,
//                 size: iconSize ?? 48,
//                 color: iconColor ?? theme.colorScheme.error,
//               ),
//               const Gap(24),
//             ],

//             // Title
//             if (title != null) ...[
//               Text(
//                 title!,
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'GeneralSans',
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const Gap(4),
//             ],

//             // Subtitle
//             if (subtitle != null) ...[
//               Text(
//                 subtitle!,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.textTheme.bodySmall?.color,
//                   fontFamily: 'GeneralSans',
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const Gap(16),
//             ],

//             // Action Button
//             if (actionButtonText != null && onActionPressed != null)
//               TextButton(
//                 onPressed: onActionPressed,
//                 style: TextButton.styleFrom(
//                   foregroundColor: AppColors.black,
//                   backgroundColor: isActionButtonFilled
//                       ? AppColors.primary
//                       : null,
//                 ),
//                 child: Text(
//                   actionButtonText!,
//                   style: TextStyle(fontFamily: 'GeneralSans'),
//                 ),
//               ),
//             if (logoutButtonText != null && onLogoutPressed != null)
//               TextButton(
//                 onPressed: onLogoutPressed,
//                 style: TextButton.styleFrom(
//                   foregroundColor: AppColors.error,
//                   backgroundColor: isActionButtonFilled
//                       ? AppColors.primary
//                       : null,
//                 ),
//                 child: Text(
//                   logoutButtonText!,
//                   style: TextStyle(fontFamily: 'GeneralSans'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Network error state
//   factory CustomErrorWidget.network({
//     String? title,
//     String? subtitle,
//     VoidCallback? onRetry,
//   }) {
//     return CustomErrorWidget(
//       icon: Icons.wifi_off_rounded,
//       title: title ?? 'No Internet Connection',
//       subtitle: subtitle ?? 'Please check your connection and try again.',
//       actionButtonText: 'Retry',
//       onActionPressed: onRetry,
//     );
//   }

//   /// Generic error state
//   factory CustomErrorWidget.error({
//     String? title,
//     String? subtitle,
//     VoidCallback? onRetry,
//   }) {
//     return CustomErrorWidget(
//       icon: Icons.error_outline_rounded,
//       title: title ?? 'Something Went Wrong',
//       subtitle: subtitle ?? 'An unexpected error occurred. Please try again.',
//       actionButtonText: onRetry != null ? 'Retry' : null,
//       onActionPressed: onRetry,
//     );
//   }

//   /// Empty state
//   factory CustomErrorWidget.empty({
//     String? title,
//     String? subtitle,
//     String? actionText,
//     VoidCallback? onAction,
//   }) {
//     return CustomErrorWidget(
//       icon: Icons.inbox_rounded,
//       title: title ?? 'No Data Available',
//       subtitle: subtitle,
//       actionButtonText: actionText,
//       onActionPressed: onAction,
//       iconColor: Colors.grey,
//     );
//   }

//   /// Server error state
//   factory CustomErrorWidget.serverError({
//     String? title,
//     String? subtitle,
//     VoidCallback? onRetry,
//   }) {
//     return CustomErrorWidget(
//       icon: Icons.cloud_off_rounded,
//       title: title ?? 'Server Error',
//       subtitle:
//           subtitle ?? 'Unable to reach the server. Please try again later.',
//       actionButtonText: 'Retry',
//       onActionPressed: onRetry,
//     );
//   }
// }
