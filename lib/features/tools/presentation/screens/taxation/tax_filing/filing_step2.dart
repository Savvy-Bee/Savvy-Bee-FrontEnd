import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

// ── Data model ──────────────────────────────────────────────────────────────

class _FilingPlan {
  final String title;
  final String subtitle;
  final String priceRange;
  final bool isRecommended;
  final String? emoji;
  final List<String> features;
  final bool isCustomQuote;

  const _FilingPlan({
    required this.title,
    required this.subtitle,
    required this.priceRange,
    this.isRecommended = false,
    this.emoji,
    this.features = const [],
    this.isCustomQuote = false,
  });
}

const _plans = [
  _FilingPlan(
    title: 'Basic PAYE',
    subtitle: 'You earn a salary. Simple and fast.',
    priceRange: '₦7,500',
    emoji: '🏦',
    features: [
      'Single employer income',
      'PAYE auto-computed',
      'Standard deductions',
    ],
  ),
  _FilingPlan(
    title: 'Freelancer',
    subtitle: 'You have mixed income sources.',
    priceRange: '₦25,000',
    isRecommended: true,
    emoji: '💻',
    features: [
      'Multiple income streams',
      'Self-employment expenses',
      'VAT reconciliation',
    ],
  ),
  _FilingPlan(
    title: 'SME Lite',
    subtitle: 'You run a small business.',
    priceRange: '₦75,000',
    emoji: '🏢',
    features: [
      'Business income & expenses',
      'CAC filing coordination',
      'Director\'s remuneration',
    ],
  ),
  _FilingPlan(
    title: 'Pro / Complex',
    subtitle: 'FX income, investments, or high earnings.',
    priceRange: 'Custom quote',
    isCustomQuote: true,
    emoji: '📈', 
    features: [
      'Capital gains & CGT',
      'FX & offshore income',
      'Dedicated tax consultant',
    ],
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class FilingStep2Screen extends StatefulWidget {
  static const String path = FilingRoutes.step2;

  const FilingStep2Screen({super.key});

  @override
  State<FilingStep2Screen> createState() => _FilingStep2ScreenState();
}

class _FilingStep2ScreenState extends State<FilingStep2Screen> {
  /// Index of the currently expanded plan card (-1 = none expanded).
  int _expandedIndex = 1; // Freelancer expanded by default (recommended)

  /// Index of the selected (radio-checked) plan.
  int _selectedIndex = 1;

  void _onPlanTap(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? -1 : index;
      _selectedIndex = index;
    });
  }

  void _onSelectPlan() {
    AppNotification.show(
      context,
      message:
          'Good choice! A filing partner will be assigned. Your return is being prepared for review.',
      icon: Icons.handshake_outlined,
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) context.pushNamed(FilingRoutes.step3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Filing Plans'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              children: [
                _StepBadge(label: 'STEP 2 OF 6 · CHOOSE PLAN'),
                const Gap(16),
                const Text(
                  'Choose your filing plan',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 24 * 0.02,
                  ),
                ),
                const Gap(6),
                Text(
                  'Each plan is tailored to a different income profile.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    color: AppColors.greyDark,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(20),

                // ── Accordion plan cards ──────────────────────────────
                ...List.generate(_plans.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PlanCard(
                      plan: _plans[i],
                      isExpanded: _expandedIndex == i,
                      isSelected: _selectedIndex == i,
                      onTap: () => _onPlanTap(i),
                    ),
                  );
                }),
                const Gap(8),
              ],
            ),
          ),

          // ── Fixed bottom button ───────────────────────────────────
          BottomActionButton(label: 'Select this plan', onTap: _onSelectPlan),
        ],
      ),
    );
  }
}

// ── Plan card with animated expand/collapse ──────────────────────────────────

class _PlanCard extends StatelessWidget {
  final _FilingPlan plan;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
  });

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? _yellow : AppColors.borderLight;
    final bgColor = isSelected ? _yellow.withValues(alpha: 0.06) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────
              Row(
                children: [
                  if (plan.emoji != null)
                    Text(plan.emoji!, style: const TextStyle(fontSize: 22)),
                  if (plan.emoji != null) const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Text(
                              plan.title,
                              style: const TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 15 * 0.02,
                              ),
                            ),
                            if (plan.isRecommended)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _yellow,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text(
                                  'RECOMMENDED',
                                  style: TextStyle(
                                    fontFamily: 'GeneralSans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    letterSpacing: 9 * 0.02,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(2),
                        Text(
                          plan.subtitle,
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
                  // ── Radio indicator ─────────────────────────────
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _yellow : AppColors.grey,
                        width: 2,
                      ),
                      color: isSelected ? _yellow : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 12, color: Colors.black)
                        : null,
                  ),
                ],
              ),

              // ── Price range ─────────────────────────────────────
              const Gap(8),
              Text(
                plan.priceRange,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 15 * 0.02,
                ),
              ),

              // ── Animated feature list ───────────────────────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    if (plan.isRecommended)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Based on your activity, this looks right for you',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 11,
                            color: AppColors.greyDark,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 11 * 0.02,
                          ),
                        ),
                      ),
                    ...plan.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          spacing: 8,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 14,
                              color: Color(0xFF43A047),
                            ),
                            Text(
                              f,
                              style: const TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 13,
                                letterSpacing: 13 * 0.02,
                              ),
                            ),
                          ],
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

// ── Shared step badge ────────────────────────────────────────────────────────

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
