import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingRecordScreen extends StatelessWidget {
  static const String path = FilingRoutes.filingRecord;

  const FilingRecordScreen({super.key});

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Header banner ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 20,
                    20,
                    20,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 6,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            'FILING COMPLETE · 2025',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _yellow,
                              letterSpacing: 11 * 0.02,
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      const Text(
                        "Here's how your 2025 taxes looked.",
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 26 * 0.02,
                          height: 1.2,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'A personal breakdown of your tax year — and what\'s next.',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 13,
                          color: AppColors.greyDark,
                          letterSpacing: 13 * 0.02,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Insight cards ─────────────────────────────
                      _InsightCard(
                        iconColor: const Color(0xFF5C6BC0),
                        iconBgColor: const Color(0xFFEDE7F6),
                        icon: Icons.bar_chart,
                        title: 'You paid ₦132,000 in taxes this year',
                        body:
                            'That\'s 14% of your gross income — below the national average for your income bracket.',
                        tag: '14% effective rate',
                        tagColor: const Color(0xFF5C6BC0),
                      ),
                      const Gap(12),
                      _InsightCard(
                        iconColor: const Color(0xFF1565C0),
                        iconBgColor: const Color(0xFFE3F2FD),
                        icon: Icons.shield_outlined,
                        title: 'Your Tax Pot covered 89% of your liability',
                        body:
                            'You weren\'t caught off guard. Consistent saving made filing stress-free.',
                        tag: '89% covered',
                        tagColor: const Color(0xFF1565C0),
                      ),
                      const Gap(12),
                      _InsightCard(
                        iconColor: const Color(0xFFF57C00),
                        iconBgColor: const Color(0xFFFFF3E0),
                        icon: Icons.lightbulb_outline,
                        title: 'Save up to ₦28,000 next year',
                        body:
                            'Contributing more to your pension could reduce your 2026 tax liability by up to ₦28,000.',
                        tag: 'Action available',
                        tagColor: const Color(0xFFF57C00),
                        actionLabel: 'Set up pension contributions',
                        onActionTap: () {},
                      ),
                      const Gap(24),

                      // ── 2025 Tax Summary dark card ────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: const Text(
                                '2025 Tax Summary',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 14 * 0.02,
                                ),
                              ),
                            ),
                            const Gap(12),
                            _DarkSummaryRow(
                              label: 'Gross income',
                              value: '₦9,600,000',
                            ),
                            _DarkSummaryRow(
                              label: 'Total deductions',
                              value: '-₦1,440,000',
                              isNegative: true,
                            ),
                            _DarkSummaryRow(
                              label: 'Taxable income',
                              value: '₦8,160,000',
                            ),
                            _DarkSummaryRow(
                              label: 'Effective rate',
                              value: '14.0%',
                            ),
                            _DarkSummaryRow(
                              label: 'Tax paid',
                              value: '₦132,000',
                              highlightValue: true,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),

                      // ── Next actions ──────────────────────────────
                      const Text(
                        'Next actions',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 16 * 0.02,
                        ),
                      ),
                      const Gap(12),
                      _NextActionTile(
                        icon: Icons.savings_outlined,
                        iconBgColor: const Color(0xFFE0F2F1),
                        iconColor: const Color(0xFF00796B),
                        label: 'Increase Tax Pot savings',
                        onTap: () {},
                      ),
                      const Gap(10),
                      _NextActionTile(
                        icon: Icons.trending_up,
                        iconBgColor: const Color(0xFFE8EAF6),
                        iconColor: const Color(0xFF3949AB),
                        label: 'Investment onboarding',
                        onTap: () {},
                      ),
                      const Gap(10),
                      _NextActionTile(
                        icon: Icons.lightbulb_outline,
                        iconBgColor: const Color(0xFFFFF8E1),
                        iconColor: const Color(0xFFF9A825),
                        label: 'Pension setup',
                        onTap: () {},
                      ),
                      const Gap(30),

                      // ── Footer note ───────────────────────────────
                      Column(
                        children: [
                          Text(
                            'See you next year. We\'ll be tracking all the way.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 13,
                              color: AppColors.greyDark,
                              letterSpacing: 13 * 0.02,
                            ),
                          ),
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: _yellow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'SB',
                                    style: TextStyle(
                                      fontFamily: 'GeneralSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Savvy Bee',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.greyDark,
                                  letterSpacing: 13 * 0.02,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Gap(24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Back to home button ──────────────────────────────────────
          BottomActionButton(
            label: 'Back to home',
            leadingIcon: Icons.home_outlined,
            onTap: () {
              // Pop all filing routes back to the root
              while (context.canPop()) {
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Insight card ──────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final Color iconColor;
  final Color iconBgColor;
  final IconData icon;
  final String title;
  final String body;
  final String tag;
  final Color tagColor;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _InsightCard({
    required this.iconColor,
    required this.iconBgColor,
    required this.icon,
    required this.title,
    required this.body,
    required this.tag,
    required this.tagColor,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 14 * 0.02,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      body,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12,
                        color: AppColors.greyDark,
                        letterSpacing: 12 * 0.02,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            spacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                    letterSpacing: 10 * 0.02,
                  ),
                ),
              ),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Row(
                    spacing: 4,
                    children: [
                      Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF57C00),
                          letterSpacing: 11 * 0.02,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: Color(0xFFF57C00),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dark summary row ──────────────────────────────────────────────────────────

class _DarkSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;
  final bool highlightValue;
  final bool isLast;

  const _DarkSummaryRow({
    required this.label,
    required this.value,
    this.isNegative = false,
    this.highlightValue = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: Colors.white70,
              letterSpacing: 13 * 0.02,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: highlightValue
                  ? const Color(0xFFF5C842)
                  : isNegative
                  ? Colors.redAccent.shade100
                  : Colors.white,
              letterSpacing: 13 * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next action tile ──────────────────────────────────────────────────────────

class _NextActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _NextActionTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 14 * 0.02,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
