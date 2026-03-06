// lib/features/tools/presentation/screens/taxation/filing/taxpayer_id_screen.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';

class TaxpayerIdScreen extends StatelessWidget {
  static const String path = FilingRoutes.taxpayerId;

  const TaxpayerIdScreen({super.key});

  static const _yellow = Color(0xFFF5C842);

  static TextStyle _gs(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black87,
  }) => TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * 0.02,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Taxpayer ID', style: _gs(16, weight: FontWeight.w600)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step badge ────────────────────────────────────────────
              _StepBadge(label: 'STEP 1 · TAXPAYER IDENTIFICATION'),
              const Gap(18),

              // ── Headline ──────────────────────────────────────────────
              Text(
                'Have you filed taxes\nbefore?',
                style: _gs(26, weight: FontWeight.w700),
              ),
              const Gap(10),
              Text(
                'This helps us get you to the right place — whether\nyou already have a TIN or you\'re registering for the\nfirst time.',
                style: _gs(13, color: AppColors.greyDark),
              ),
              const Gap(24),

              // ── Option 1: Yes, I have a TIN ──────────────────────────
              _OptionTile(
                icon: Icons.person_outline,
                filled: true,
                title: 'Yes, I have a TIN',
                subtitle:
                    'Existing taxpayer — I\'ll validate my\nTax Identification Number',
                onTap: () => context.pushNamed(FilingRoutes.tinValidation1),
              ),
              const Gap(12),

              // ── Option 2: No, first time ──────────────────────────────
              _OptionTile(
                icon: Icons.person_add_outlined,
                filled: false,
                title: 'No, I\'m filing for the\nfirst time',
                subtitle:
                    'New taxpayer — I\'ll register to get\nmy TIN from FIRS',
                onTap: () => context.pushNamed(FilingRoutes.tinReg1),
              ),
              const Gap(20),

              // ── Info note ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBE6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE58F)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Color(0xFF856404),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A Tax Identification Number (TIN) is required by FIRS for all Nigerian taxpayers. If you\'re unsure, check your payslip or contact your employer\'s HR department.',
                        style: _gs(12, color: const Color(0xFF856404)),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── JTB badge ─────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Powered by JTB Portal',
                      style: _gs(12, color: AppColors.greyDark),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'JTB',
                        style: _gs(
                          11,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Option tile ───────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.filled,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const _yellow = Color(0xFFF5C842);

  static TextStyle _gs(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black87,
  }) => TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * 0.02,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5),
          ),
        ),
        child: Row(
          children: [
            // ── Icon circle ──────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: filled ? _yellow : Colors.black54,
              ),
            ),
            const SizedBox(width: 14),

            // ── Text ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _gs(
                      14,
                      weight: FontWeight.w600,
                      color: filled ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    subtitle,
                    style: _gs(
                      12,
                      color: filled ? Colors.white60 : const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: filled ? Colors.white54 : const Color(0xFFAAAAAA),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step badge ────────────────────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  final String label;
  const _StepBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFF5C842),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF5C842),
            letterSpacing: 11 * 0.02,
          ),
        ),
      ],
    );
  }
}
