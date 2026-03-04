import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingStep1Screen extends StatelessWidget {
  static const String path = FilingRoutes.step1;

  const FilingStep1Screen({super.key});

  // ── Hardcoded summary data (replace with model/provider as needed) ──────
  static const _items = [
    _SummaryItem(label: 'Total income tracked this year', value: '₦9,600,000'),
    _SummaryItem(label: 'Amount classified as taxable', value: '₦8,400,000'),
    _SummaryItem(label: 'Amount saved in your Tax Pot', value: '₦121,000'),
    _SummaryItem(label: 'Estimated tax liability', value: '₦118,400'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Filing Summary'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              children: [
                // ── Step badge ──────────────────────────────────────────
                _StepBadge(label: 'STEP 1 OF 6 · READINESS CHECK'),
                const Gap(16),

                // ── Headline ────────────────────────────────────────────
                Text(
                  "Here's everything we already know.",
                  style: _headline(context),
                ),
                const Gap(8),
                Text(
                  'Before any decisions are made, here\'s a clean summary of what Savvy Bee has prepared for your 2025 filing.',
                  style: _body(context),
                ),
                const Gap(24),

                // // ── Summary items ───────────────────────────────────────
                // ..._items.map((item) => _CheckRow(item: item)),
                // const Gap(16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      children: _items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            _CheckRow(item: item),
                            if (index < _items.length - 1)
                              const Divider(
                                height: 28,
                                color: Color(0xFFF0F0F0),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Gap(24),

                // ── Info note ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFe8ebff).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(0xFFe0e7ff),
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFFe8ebff)),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 15,
                          color: Color(0xFF4948ab),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Savvy Bee has been preparing this since March.',
                              style: const TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4948ab),
                              ),
                            ),
                            const Gap(2),
                            Text(
                              'All figures are sourced from your connected accounts and transactions.',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 12,
                                color: Color(0xFF4948ab),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                // ── Estimated payable dark card ─────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated payable for 2025',
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₦118,400',
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 28 * 0.02,
                        ),
                      ),
                      const Gap(6),
                      Row(
                        spacing: 6,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFF5C842),
                            size: 14,
                          ),
                          Text(
                            'Your Tax Pot of ₦121,000 fully covers this',
                            style: const TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),

          // ── CTA button ──────────────────────────────────────────────
          BottomActionButton(
            label: 'Looks good — choose my filing plan',
            onTap: () => context.pushNamed(FilingRoutes.step2),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

TextStyle _headline(BuildContext context) => const TextStyle(
  fontFamily: 'GeneralSans',
  fontSize: 26,
  fontWeight: FontWeight.w700,
  letterSpacing: 26 * 0.02,
  height: 1.2,
);

TextStyle _body(BuildContext context) => TextStyle(
  fontFamily: 'GeneralSans',
  fontSize: 13,
  color: AppColors.greyDark,
  letterSpacing: 13 * 0.02,
);

class _SummaryItem {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});
}

class _CheckRow extends StatelessWidget {
  final _SummaryItem item;
  const _CheckRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ), // ← softer vertical spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // better alignment
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, color: Color(0xFF43A047), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            item.value,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: Colors.black,
            letterSpacing: 11 * 0.02,
          ),
        ),
      ],
    );
  }
}
