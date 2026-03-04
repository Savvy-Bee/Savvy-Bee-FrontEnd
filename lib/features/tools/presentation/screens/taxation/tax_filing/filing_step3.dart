import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingStep3Screen extends StatefulWidget {
  static const String path = FilingRoutes.step3;

  const FilingStep3Screen({super.key});

  @override
  State<FilingStep3Screen> createState() => _FilingStep3ScreenState();
}

class _FilingStep3ScreenState extends State<FilingStep3Screen> {
  // Which sections are expanded
  final Set<_Section> _expanded = {
    _Section.personalInfo,
    _Section.incomeSummary,
    _Section.deductionsReliefs,
    _Section.taxComputation,
  };

  void _toggle(_Section section) {
    setState(() {
      _expanded.contains(section)
          ? _expanded.remove(section)
          : _expanded.add(section);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Review Return'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              children: [
                _StepBadge(label: 'STEP 3 OF 6 · REVIEW RETURN'),
                const Gap(16),
                const Text(
                  'Your pre-filled 2026 return',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 24 * 0.02,
                  ),
                ),
                const Gap(6),
                Text(
                  'Everything is already filled in. Tap any section to expand and review.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    color: AppColors.greyDark,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(20),

                // ── Identity card ─────────────────────────────────────
                _IdentityCard(),
                const Gap(16),

                // ── Personal Information ──────────────────────────────
                _CollapsibleSection(
                  title: 'Personal Information',
                  isExpanded: _expanded.contains(_Section.personalInfo),
                  onToggle: () => _toggle(_Section.personalInfo),
                  child: _PersonalInfoContent(),
                ),
                const Gap(12),

                // ── Income Summary ────────────────────────────────────
                _CollapsibleSection(
                  title: 'Income Summary',
                  isExpanded: _expanded.contains(_Section.incomeSummary),
                  onToggle: () => _toggle(_Section.incomeSummary),
                  child: _IncomeSummaryContent(),
                ),
                const Gap(12),

                // ── Deductions & Reliefs ──────────────────────────────
                _CollapsibleSection(
                  title: 'Deductions & Reliefs',
                  isExpanded: _expanded.contains(_Section.deductionsReliefs),
                  onToggle: () => _toggle(_Section.deductionsReliefs),
                  child: _DeductionsContent(),
                ),
                const Gap(12),

                // ── Tax Computation ───────────────────────────────────
                _CollapsibleSection(
                  title: 'Tax Computation',
                  isExpanded: _expanded.contains(_Section.taxComputation),
                  onToggle: () => _toggle(_Section.taxComputation),
                  child: _TaxComputationContent(),
                ),
                const Gap(16),

                // ── Info note ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                      Expanded(
                        child: Text(
                          'Once you confirm this return, you\'ll be asked to complete your filing payment before we submit.',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 12,
                            color: Colors.blueAccent.shade700,
                            letterSpacing: 12 * 0.02,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
          BottomActionButton(
            label: 'This looks right — proceed to payment',
            onTap: () => context.pushNamed(FilingRoutes.step4),
          ),
        ],
      ),
    );
  }
}

// ── Section enum ─────────────────────────────────────────────────────────────

enum _Section { personalInfo, incomeSummary, deductionsReliefs, taxComputation }

// ── Identity card ─────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'AO',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adewale Okonkwo',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                Text(
                  'TIN: 1234-5678-901',
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5C842).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color(0xFFF5C842).withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              '2026 Return',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 11 * 0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collapsible section wrapper ───────────────────────────────────────────────

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 14 * 0.02,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Auto-filled tag ───────────────────────────────────────────────────────────

class _AutoFilledTag extends StatelessWidget {
  const _AutoFilledTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF80CBC4)),
      ),
      child: const Text(
        'C AUTO-FILLED',
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00796B),
          letterSpacing: 9 * 0.02,
        ),
      ),
    );
  }
}

// ── Row helpers ───────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showTag;
  final bool isNegative;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showTag = false,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTag) ...[const _AutoFilledTag(), const Gap(3)],
                Text(
                  label,
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
          Text(
            value,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isNegative ? Colors.red.shade700 : Colors.black87,
              letterSpacing: 13 * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(color: AppColors.borderLight, height: 1),
  );
}

// ── Section content widgets ───────────────────────────────────────────────────

class _PersonalInfoContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _InfoRow(label: 'Full Name', value: 'Adewale Okonkwo', showTag: true),
        _InfoRow(
          label: 'State of Residence',
          value: 'Lagos State',
          showTag: true,
        ),
        _InfoRow(
          label: 'Filing Status',
          value: 'Individual (Freelancer)',
          showTag: true,
        ),
        _InfoRow(label: 'Tax Year', value: 'January – December 2026'),
      ],
    );
  }
}

class _IncomeSummaryContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _InfoRow(
          label: 'Primary Employment Income',
          value: '₦4,800,000',
          showTag: true,
        ),
        const _InfoRow(
          label: 'Freelance & Contract Income',
          value: '₦3,600,000',
          showTag: true,
        ),
        const _InfoRow(
          label: 'Other Income',
          value: '₦1,200,000',
          showTag: true,
        ),
        const _Divider(),
        const _InfoRow(label: 'Gross Income', value: '₦9,600,000'),
      ],
    );
  }
}

class _DeductionsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _InfoRow(
          label: 'Pension Contribution (8%)',
          value: '-₦768,000',
          showTag: true,
          isNegative: true,
        ),
        const _InfoRow(
          label: 'NHF Contribution',
          value: '-₦192,000',
          showTag: true,
          isNegative: true,
        ),
        const _InfoRow(
          label: 'Life Insurance Relief',
          value: '-₦120,000',
          showTag: true,
          isNegative: true,
        ),
        const _InfoRow(
          label: 'Personal Relief (CRA)',
          value: '-₦360,000',
          showTag: true,
          isNegative: true,
        ),
        const _Divider(),
        const _InfoRow(
          label: 'Total Deductions',
          value: '-₦1,440,000',
          isNegative: true,
        ),
      ],
    );
  }
}

class _TaxComputationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _InfoRow(label: 'Gross Income', value: '₦9,600,000'),
        const _InfoRow(
          label: 'Total Deductions',
          value: '-₦1,440,000',
          isNegative: true,
        ),
        const _InfoRow(label: 'Taxable Income', value: '₦8,160,000'),
        const _Divider(),
        const _InfoRow(label: 'First ₦300,000 @ 7%', value: '₦21,000'),
        const _InfoRow(label: 'Next ₦300,000 @ 11%', value: '₦33,000'),
        const _InfoRow(label: 'Next ₦500,000 @ 15%', value: '₦75,000'),
        const _InfoRow(
          label: 'Balance @ 19%–24%',
          value: '-₦10,600',
          isNegative: true,
        ),
        const _Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Final Tax Due',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 14 * 0.02,
              ),
            ),
            const Text(
              '₦118,400',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 14 * 0.02,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Shared step badge ─────────────────────────────────────────────────────────

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
