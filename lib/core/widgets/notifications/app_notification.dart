import 'package:flutter/material.dart';

/// A reusable notification helper that shows a styled floating [SnackBar].
///
/// Usage:
/// ```dart
/// AppNotification.show(
///   context,
///   message: "We'll remind you in 24 hours.",
/// );
///
/// // With custom colours and icon:
/// AppNotification.show(
///   context,
///   message: 'Profile updated successfully!',
///   backgroundColor: Colors.green,
///   textColor: Colors.white,
///   icon: Icons.check_circle_outline,
///   iconColor: Colors.white,
/// );
/// ```
abstract class AppNotification {
  AppNotification._();

  static void show(
    BuildContext context, {
    required String message,

    /// Background colour of the snack bar. Defaults to near-black.
    Color backgroundColor = const Color(0xFF1A1A1A),

    /// Colour of the message text. Defaults to white.
    Color textColor = Colors.white,

    /// Optional leading icon. Defaults to [Icons.notifications_active_outlined].
    IconData icon = Icons.notifications_active_outlined,

    /// Colour of the leading icon. Defaults to the yellow brand accent.
    Color iconColor = const Color(0xFFF5C842),

    /// How long the notification stays on screen.
    Duration duration = const Duration(seconds: 3),

    /// Border radius of the floating card.
    double borderRadius = 14,
  }) {
    // Remove any currently visible snack bar before showing the new one.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        duration: duration,
        content: Row(
          spacing: 10,
          children: [
            Icon(icon, color: iconColor, size: 20),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 13,
                  letterSpacing: 13 * 0.02,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}