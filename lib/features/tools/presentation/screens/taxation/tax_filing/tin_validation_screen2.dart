// lib/features/tools/presentation/screens/taxation/filing/tin_validation_screen2.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';

class TinValidationScreen2 extends StatelessWidget {
  static const String path = FilingRoutes.tinValidation2;

  const TinValidationScreen2({super.key});

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('TIN Validation', style: _gs(16, weight: FontWeight.w600)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Badge ─────────────────────────────────────────────────────
              _StepBadge(label: 'EXISTING TAXPAYER · TIN LOOKUP'),
              const Gap(20),

              // ── Headline ──────────────────────────────────────────────────
              Text(
                'Enter your Tax\nIdentification Number',
                style: _gs(26, weight: FontWeight.w700),
              ),
              const Gap(10),
              Text(
                "We'll verify your TIN with the Joint Tax Board (JTB)\nportal and pull in your tax records automatically.",
                style: _gs(13, color: AppColors.greyDark),
              ),
              const Gap(24),

              // ── Validated card ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIN Validated',
                              style: _gs(
                                13,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Verified via Joint Tax Board',
                              style: _gs(11, color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(18),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.12),
                      height: 1,
                    ),
                    const Gap(14),

                    // Record rows
                    _DarkInfoRow(label: 'Full Name', value: 'Adewale Okafor'),
                    _DarkInfoRow(label: 'TIN', value: '1111111111'),
                    _DarkInfoRow(
                      label: 'State of Residence',
                      value: 'Lagos State',
                    ),
                    _DarkInfoRow(label: 'Tax Authority', value: 'LIRS'),
                    _DarkInfoRow(label: 'Filing Status', value: 'Active'),
                  ],
                ),
              ),
              const Gap(16),

              // ── Success note ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF43A047).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 15,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your tax records have been fetched and your return pre-filled. You can review everything before confirming.',
                        style: _gs(12, color: const Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── CTA ───────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pushNamed(FilingRoutes.step1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    'Proceed to filing',
                    style: _gs(
                      15,
                      weight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dark card info row ────────────────────────────────────────────────────────

class _DarkInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DarkInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: Colors.white60,
              letterSpacing: 13 * 0.02,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 13 * 0.02,
            ),
          ),
        ],
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
