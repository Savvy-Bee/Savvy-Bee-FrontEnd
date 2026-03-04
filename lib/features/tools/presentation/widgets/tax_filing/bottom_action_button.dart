import 'package:flutter/material.dart';

/// A reusable full-width yellow pill button that stays fixed at the bottom
/// of every filing-flow step screen.
///
/// Usage:
/// ```dart
/// BottomActionButton(
///   label: "Looks good — choose my filing plan",
///   onTap: () => context.pushNamed(FilingStep2Screen.path),
/// )
/// ```
class BottomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  /// Optional leading icon (e.g. Icons.home_outlined for "Back to home").
  final IconData? leadingIcon;

  /// Whether the button is in a loading / disabled state.
  final bool isLoading;

  const BottomActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.isLoading = false,
  });

  static const _yellow = Color(0xFFF5C842);
  static const double _fontSize = 15;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Material(
          color: _yellow,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: isLoading ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        if (leadingIcon != null)
                          Icon(leadingIcon, size: 18, color: Colors.black87),
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: _fontSize,
                            letterSpacing: _fontSize * 0.02,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
