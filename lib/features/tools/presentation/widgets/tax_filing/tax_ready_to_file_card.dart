import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

/// A card shown at the top of the Tax Dashboard prompting the user to file
/// their tax return for the current year.
class TaxReadyToFileCard extends StatelessWidget {
  /// The estimated tax payable amount (e.g. 118400.0).
  final double estimatedTaxPayable;

  /// The tax year being filed (defaults to current year).
  final int? taxYear;

  /// Called when the user taps "Yes, let's file".
  final VoidCallback onFileTap;

  /// Called when the user taps "Remind me later".
  final VoidCallback onRemindLaterTap;

  const TaxReadyToFileCard({
    super.key,
    required this.estimatedTaxPayable,
    this.taxYear,
    required this.onFileTap,
    required this.onRemindLaterTap,
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static TextStyle _gs(
    double fontSize, {
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.white,
  }) {
    return TextStyle(
      fontFamily: 'GeneralSans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: fontSize * 0.02,
    );
  }

  String _formatCurrency(double amount) {
    // Simple Nigerian Naira formatter without external deps.
    final intPart = amount.toInt();
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    return '₦$formatted';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final year = taxYear ?? DateTime.now().year;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // near-black, matching screenshot
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Badge row ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5C842), // yellow dot
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'READY TO FILE · $year',
                style: _gs(
                  11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF5C842),
                ),
              ),
            ],
          ),

          const Gap(12),

          // ── Body text ─────────────────────────────────────────────────────
          RichText(
            text: TextSpan(
              style: _gs(14, color: Colors.white),
              children: [
                TextSpan(
                  text:
                      "You're ready to file your $year tax return."
                      " Estimated payable: ",
                ),
                TextSpan(
                  text: _formatCurrency(estimatedTaxPayable),
                  style: _gs(
                    14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF5C842),
                  ),
                ),
                TextSpan(
                  text:
                      '\nSavvy Bee has everything it needs.'
                      ' Want us to handle this for you?',
                ),
              ],
            ),
          ),

          const Gap(18),

          // ── Action buttons ─────────────────────────────────────────────────
          Row(
            children: [
              // Primary – Yes, let's file
              Expanded(
                child: _PillButton(
                  label: "Yes, let's file",
                  backgroundColor: const Color(0xFFF5C842),
                  textColor: Colors.black,
                  onTap: onFileTap,
                ),
              ),
              const SizedBox(width: 10),
              // Secondary – Remind me later
              Expanded(
                child: _PillButton(
                  label: 'Remind me later',
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  textColor: Colors.white,
                  onTap: onRemindLaterTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _PillButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 13 * 0.02,
            ),
          ),
        ),
      ),
    );
  }
}
