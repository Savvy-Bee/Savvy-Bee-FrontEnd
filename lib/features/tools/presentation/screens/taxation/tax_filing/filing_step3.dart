// lib/features/tools/presentation/screens/taxation/filing/filing_step3_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/tax_calculator_result.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/selected_filing_plan_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/tax_calculator_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class FilingStep3Screen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.step3;

  const FilingStep3Screen({super.key});

  @override
  ConsumerState<FilingStep3Screen> createState() => _FilingStep3ScreenState();
}

class _FilingStep3ScreenState extends ConsumerState<FilingStep3Screen> {
  // Which sections are expanded
  final Set<_Section> _expanded = {
    _Section.personalInfo,
    _Section.incomeSummary,
    _Section.deductionsReliefs,
    _Section.taxComputation,
  };

  // ── Deduction controllers ─────────────────────────────────────────────────
  final _nhfCtrl = TextEditingController();
  final _nhisCtrl = TextEditingController();
  final _pensionCtrl = TextEditingController();
  final _loanCtrl = TextEditingController();
  final _lifeCtrl = TextEditingController();

  bool _deductionsInitialized = false;

  @override
  void dispose() {
    _nhfCtrl.dispose();
    _nhisCtrl.dispose();
    _pensionCtrl.dispose();
    _loanCtrl.dispose();
    _lifeCtrl.dispose();
    super.dispose();
  }

  /// Populate text controllers once from the API data (runs only once).
  void _initDeductions(FilingHomeData data) {
    if (_deductionsInitialized) return;
    _deductionsInitialized = true;
    // The API doesn't return individual deduction line items, so we default
    // all editable fields to 0. If your API ever returns them, map here.
    _nhfCtrl.text = '0';
    _nhisCtrl.text = '0';
    _pensionCtrl.text = '0';
    _loanCtrl.text = '0';
    _lifeCtrl.text = '0';
  }

  double _parseField(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;

  void _toggle(_Section section) {
    setState(() {
      _expanded.contains(section)
          ? _expanded.remove(section)
          : _expanded.add(section);
    });
  }

  Future<void> _recalculate(FilingHomeData filingData) async {
    await ref.read(taxCalculatorProvider.notifier).calculate(
          earnings: filingData.totalEarnings,
          nhf: _parseField(_nhfCtrl),
          nhis: _parseField(_nhisCtrl),
          pension: _parseField(_pensionCtrl),
          loanInterest: _parseField(_loanCtrl),
          lifeInsurance: _parseField(_lifeCtrl),
        );

    final calcState = ref.read(taxCalculatorProvider);
    if (calcState.error != null && mounted) {
      AppNotification.show(
        context,
        message: 'Recalculation failed. Please try again.',
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filingAsync = ref.watch(filingHomeProvider);
    final profileAsync = ref.watch(homeDataProvider);
    final selectedPlan = ref.watch(selectedFilingPlanProvider);
    final calcState = ref.watch(taxCalculatorProvider);

    final filingData = filingAsync.value;
    if (filingData != null) _initDeductions(filingData);

    // Tax year = current year - 1
    final taxYear = DateTime.now().year - 1;

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
                const _StepBadge(label: 'STEP 3 OF 6 · REVIEW RETURN'),
                const Gap(16),
                Text(
                  'Your pre-filled $taxYear return',
                  style: const TextStyle(
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
                profileAsync.when(
                  data: (home) {
                    final user = home.data;
                    final initials =
                        '${user.firstName[0]}${user.lastName[0]}'.toUpperCase();
                    final fullName = '${user.firstName} ${user.lastName}';
                    return _IdentityCard(
                      initials: initials,
                      fullName: fullName,
                      taxYear: taxYear,
                    );
                  },
                  loading: () => const _IdentityCard(
                    initials: '...',
                    fullName: 'Loading...',
                    taxYear: 0,
                  ),
                  error: (_, __) => const _IdentityCard(
                    initials: '?',
                    fullName: 'Unknown',
                    taxYear: 0,
                  ),
                ),
                const Gap(16),

                // ── Personal Information ──────────────────────────────
                _CollapsibleSection(
                  title: 'Personal Information',
                  isExpanded: _expanded.contains(_Section.personalInfo),
                  onToggle: () => _toggle(_Section.personalInfo),
                  child: profileAsync.when(
                    data: (home) {
                      final user = home.data;
                      return _PersonalInfoContent(
                        fullName: '${user.firstName} ${user.lastName}',
                        email: user.email,
                        // phone: user?.phone ?? '',
                        // phone: '09032825450',
                        countryOfResidence: user.country,
                        filingStatus: selectedPlan,
                        taxYear: taxYear,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(
                      'Could not load profile: $e',
                      style: const TextStyle(
                          fontFamily: 'GeneralSans', fontSize: 12),
                    ),
                  ),
                ),
                const Gap(12),

                // ── Income Summary ────────────────────────────────────
                _CollapsibleSection(
                  title: 'Income Summary',
                  isExpanded: _expanded.contains(_Section.incomeSummary),
                  onToggle: () => _toggle(_Section.incomeSummary),
                  child: filingData != null
                      ? _IncomeSummaryContent(incomes: filingData.incomes)
                      : const Center(child: CircularProgressIndicator()),
                ),
                const Gap(12),

                // ── Deductions & Reliefs ──────────────────────────────
                _CollapsibleSection(
                  title: 'Deductions & Reliefs',
                  isExpanded:
                      _expanded.contains(_Section.deductionsReliefs),
                  onToggle: () => _toggle(_Section.deductionsReliefs),
                  child: _DeductionsContent(
                    nhfCtrl: _nhfCtrl,
                    nhisCtrl: _nhisCtrl,
                    pensionCtrl: _pensionCtrl,
                    loanCtrl: _loanCtrl,
                    lifeCtrl: _lifeCtrl,
                    isLoading: calcState.isLoading,
                    onRecalculate: filingData != null
                        ? () => _recalculate(filingData)
                        : null,
                    // Total deductions: from calculator if available, else 0
                    totalDeductions: calcState.result?.exemption ?? 0,
                  ),
                ),
                const Gap(12),

                // ── Tax Computation ───────────────────────────────────
                _CollapsibleSection(
                  title: 'Tax Computation',
                  isExpanded: _expanded.contains(_Section.taxComputation),
                  onToggle: () => _toggle(_Section.taxComputation),
                  child: filingData != null
                      ? _TaxComputationContent(
                          grossIncome: filingData.totalEarnings,
                          calcResult: calcState.result,
                          // Fallback to filing API data before first recalc
                          fallbackTaxableIncome: filingData.taxableIncome,
                          fallbackStages: filingData.stages,
                          fallbackEstimatedTax: filingData.estimatedTax,
                        )
                      : const Center(child: CircularProgressIndicator()),
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
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.blueAccent),
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

// ── Section enum ──────────────────────────────────────────────────────────────

enum _Section { personalInfo, incomeSummary, deductionsReliefs, taxComputation }

// ── Identity card ─────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  final String initials;
  final String fullName;
  final int taxYear;

  const _IdentityCard({
    required this.initials,
    required this.fullName,
    required this.taxYear,
  });

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
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
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
            child: Text(
              fullName,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 14 * 0.02,
              ),
            ),
          ),
          if (taxYear > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF5C842).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFFF5C842).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '$taxYear Return',
                style: const TextStyle(
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
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
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

// ── Info row (read-only) ──────────────────────────────────────────────────────

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

// ── Editable deduction row ────────────────────────────────────────────────────

class _EditableDeductionRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _EditableDeductionRow({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                color: AppColors.greyDark,
                letterSpacing: 13 * 0.02,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            height: 38,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 13,
                  color: AppColors.greyDark,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFFF5C842), width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: AppColors.borderLight, height: 1),
      );
}

// ── Section content widgets ───────────────────────────────────────────────────

class _PersonalInfoContent extends StatelessWidget {
  final String fullName;
  final String email;
  // final String phone;
  final String countryOfResidence;
  final String filingStatus;
  final int taxYear;

  const _PersonalInfoContent({
    required this.fullName,
    required this.email,
    // required this.phone,
    required this.countryOfResidence,
    required this.filingStatus,
    required this.taxYear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(label: 'Full Name', value: fullName, showTag: true),
        _InfoRow(label: 'Email', value: email, showTag: true),
        // if (phone.isNotEmpty)
        //   _InfoRow(label: 'Phone', value: phone, showTag: true),
        _InfoRow(
          label: 'Country of Residence',
          value: countryOfResidence,
          showTag: true,
        ),
        _InfoRow(
          label: 'Filing Status',
          value: filingStatus,
          showTag: true,
        ),
        _InfoRow(
          label: 'Tax Year',
          value: 'January – December $taxYear',
        ),
      ],
    );
  }
}

class _IncomeSummaryContent extends StatelessWidget {
  final List<FilingIncomeSource> incomes;

  const _IncomeSummaryContent({required this.incomes});

  @override
  Widget build(BuildContext context) {
    final total = incomes.fold(0.0, (sum, i) => sum + i.amount);

    return Column(
      children: [
        ...incomes.map(
          (income) => _InfoRow(
            label: income.source,
            value: income.amount.formatCurrency(decimalDigits: 0),
            showTag: true,
          ),
        ),
        const _SectionDivider(),
        _InfoRow(
          label: 'Gross Income',
          value: total.formatCurrency(decimalDigits: 0),
        ),
      ],
    );
  }
}

class _DeductionsContent extends StatelessWidget {
  final TextEditingController nhfCtrl;
  final TextEditingController nhisCtrl;
  final TextEditingController pensionCtrl;
  final TextEditingController loanCtrl;
  final TextEditingController lifeCtrl;
  final bool isLoading;
  final VoidCallback? onRecalculate;
  final double totalDeductions;

  const _DeductionsContent({
    required this.nhfCtrl,
    required this.nhisCtrl,
    required this.pensionCtrl,
    required this.loanCtrl,
    required this.lifeCtrl,
    required this.isLoading,
    required this.onRecalculate,
    required this.totalDeductions,
  });

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditableDeductionRow(
          label: 'NHF Contribution (Annual)',
          controller: nhfCtrl,
        ),
        _EditableDeductionRow(
          label: 'NHIS Contribution',
          controller: nhisCtrl,
        ),
        _EditableDeductionRow(
          label: 'Pension Contribution',
          controller: pensionCtrl,
        ),
        _EditableDeductionRow(
          label: 'Interest on Loan (Owner Occupied)',
          controller: loanCtrl,
        ),
        _EditableDeductionRow(
          label: 'Life Insurance Premium (You & Spouse)',
          controller: lifeCtrl,
        ),
        const Gap(4),

        // ── Recalculate button ──────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onRecalculate,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _yellow, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: _yellow.withValues(alpha: 0.05),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black54,
                    ),
                  )
                : const Icon(Icons.calculate_outlined,
                    size: 16, color: Colors.black87),
            label: Text(
              isLoading ? 'Recalculating…' : 'Recalculate Tax',
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 13 * 0.02,
              ),
            ),
          ),
        ),
        const Gap(12),
        const _SectionDivider(),

        // ── Total deductions (updated after recalculate) ─────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Deductions',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                color: AppColors.greyDark,
                letterSpacing: 13 * 0.02,
              ),
            ),
            Text(
              totalDeductions > 0
                  ? '-${totalDeductions.formatCurrency(decimalDigits: 0)}'
                  : '₦0',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    totalDeductions > 0 ? Colors.red.shade700 : Colors.black87,
                letterSpacing: 13 * 0.02,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaxComputationContent extends StatelessWidget {
  final double grossIncome;
  final TaxCalculatorResult? calcResult;
  final double fallbackTaxableIncome;
  final FilingStages fallbackStages;
  final double fallbackEstimatedTax;

  const _TaxComputationContent({
    required this.grossIncome,
    required this.calcResult,
    required this.fallbackTaxableIncome,
    required this.fallbackStages,
    required this.fallbackEstimatedTax,
  });

  @override
  Widget build(BuildContext context) {
    // After recalculate → use calculator result; otherwise → filing API data
    final taxableIncome =
        calcResult?.taxableIncome ?? fallbackTaxableIncome;
    final totalDeductions =
        calcResult?.exemption ?? (grossIncome - fallbackTaxableIncome);
    final finalTaxDue = calcResult?.finalTaxDue ?? fallbackEstimatedTax;

    // Build stage rows
    List<MapEntry<String, double>> stageEntries;
    if (calcResult != null) {
      stageEntries = calcResult!.stages.nonZeroEntries;
    } else {
      // Map fallback stages using standard labels
      final labels = [
        'First ₦300,000 @ 7%',
        'Next ₦300,000 @ 11%',
        'Next ₦500,000 @ 15%',
        'Next ₦500,000 @ 19%',
        'Balance @ 21%–24%',
        'Additional',
      ];
      final vals = [
        fallbackStages.stage1,
        fallbackStages.stage2,
        fallbackStages.stage3,
        fallbackStages.stage4,
        fallbackStages.stage5,
        fallbackStages.stage6,
      ];
      stageEntries = [
        for (int i = 0; i < 6; i++)
          if (vals[i] != 0) MapEntry(labels[i], vals[i]),
      ];
    }

    return Column(
      children: [
        _InfoRow(
          label: 'Gross Income',
          value: grossIncome.formatCurrency(decimalDigits: 0),
        ),
        _InfoRow(
          label: 'Total Deductions',
          value: totalDeductions > 0
              ? '-${totalDeductions.formatCurrency(decimalDigits: 0)}'
              : '₦0',
          isNegative: totalDeductions > 0,
        ),
        _InfoRow(
          label: 'Taxable Income',
          value: taxableIncome.formatCurrency(decimalDigits: 0),
        ),
        const _SectionDivider(),
        ...stageEntries.map(
          (e) => _InfoRow(
            label: e.key,
            value: e.value.formatCurrency(decimalDigits: 0),
          ),
        ),
        const _SectionDivider(),
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
            Text(
              finalTaxDue.formatCurrency(decimalDigits: 0),
              style: const TextStyle(
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
            color: Colors.black,
            letterSpacing: 11 * 0.02,
          ),
        ),
      ],
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

// class FilingStep3Screen extends StatefulWidget {
//   static const String path = FilingRoutes.step3;

//   const FilingStep3Screen({super.key});

//   @override
//   State<FilingStep3Screen> createState() => _FilingStep3ScreenState();
// }

// class _FilingStep3ScreenState extends State<FilingStep3Screen> {
//   // Which sections are expanded
//   final Set<_Section> _expanded = {
//     _Section.personalInfo,
//     _Section.incomeSummary,
//     _Section.deductionsReliefs,
//     _Section.taxComputation,
//   };

//   void _toggle(_Section section) {
//     setState(() {
//       _expanded.contains(section)
//           ? _expanded.remove(section)
//           : _expanded.add(section);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text('Review Return'),
//         centerTitle: false,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//               children: [
//                 _StepBadge(label: 'STEP 3 OF 6 · REVIEW RETURN'),
//                 const Gap(16),
//                 const Text(
//                   'Your pre-filled 2026 return',
//                   style: TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 24 * 0.02,
//                   ),
//                 ),
//                 const Gap(6),
//                 Text(
//                   'Everything is already filled in. Tap any section to expand and review.',
//                   style: TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 13,
//                     color: AppColors.greyDark,
//                     letterSpacing: 13 * 0.02,
//                   ),
//                 ),
//                 const Gap(20),

//                 // ── Identity card ─────────────────────────────────────
//                 _IdentityCard(),
//                 const Gap(16),

//                 // ── Personal Information ──────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Personal Information',
//                   isExpanded: _expanded.contains(_Section.personalInfo),
//                   onToggle: () => _toggle(_Section.personalInfo),
//                   child: _PersonalInfoContent(),
//                 ),
//                 const Gap(12),

//                 // ── Income Summary ────────────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Income Summary',
//                   isExpanded: _expanded.contains(_Section.incomeSummary),
//                   onToggle: () => _toggle(_Section.incomeSummary),
//                   child: _IncomeSummaryContent(),
//                 ),
//                 const Gap(12),

//                 // ── Deductions & Reliefs ──────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Deductions & Reliefs',
//                   isExpanded: _expanded.contains(_Section.deductionsReliefs),
//                   onToggle: () => _toggle(_Section.deductionsReliefs),
//                   child: _DeductionsContent(),
//                 ),
//                 const Gap(12),

//                 // ── Tax Computation ───────────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Tax Computation',
//                   isExpanded: _expanded.contains(_Section.taxComputation),
//                   onToggle: () => _toggle(_Section.taxComputation),
//                   child: _TaxComputationContent(),
//                 ),
//                 const Gap(16),

//                 // ── Info note ─────────────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF0F4FF),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     spacing: 10,
//                     children: [
//                       const Icon(
//                         Icons.info_outline,
//                         size: 16,
//                         color: Colors.blueAccent,
//                       ),
//                       Expanded(
//                         child: Text(
//                           'Once you confirm this return, you\'ll be asked to complete your filing payment before we submit.',
//                           style: TextStyle(
//                             fontFamily: 'GeneralSans',
//                             fontSize: 12,
//                             color: Colors.blueAccent.shade700,
//                             letterSpacing: 12 * 0.02,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Gap(24),
//               ],
//             ),
//           ),
//           BottomActionButton(
//             label: 'This looks right — proceed to payment',
//             onTap: () => context.pushNamed(FilingRoutes.step4),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Section enum ─────────────────────────────────────────────────────────────

// enum _Section { personalInfo, incomeSummary, deductionsReliefs, taxComputation }

// // ── Identity card ─────────────────────────────────────────────────────────────

// class _IdentityCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.borderLight),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: const BoxDecoration(
//               color: Color(0xFF1A1A1A),
//               shape: BoxShape.circle,
//             ),
//             child: const Center(
//               child: Text(
//                 'AO',
//                 style: TextStyle(
//                   fontFamily: 'GeneralSans',
//                   fontSize: 13,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Adewale Okonkwo',
//                   style: TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 14 * 0.02,
//                   ),
//                 ),
//                 Text(
//                   'TIN: 1234-5678-901',
//                   style: TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 12,
//                     color: AppColors.greyDark,
//                     letterSpacing: 12 * 0.02,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5C842).withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(50),
//               border: Border.all(
//                 color: const Color(0xFFF5C842).withValues(alpha: 0.4),
//               ),
//             ),
//             child: const Text(
//               '2026 Return',
//               style: TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 11 * 0.02,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Collapsible section wrapper ───────────────────────────────────────────────

// class _CollapsibleSection extends StatelessWidget {
//   final String title;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final Widget child;

//   const _CollapsibleSection({
//     required this.title,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.borderLight),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(14),
//             onTap: onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       title,
//                       style: const TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 14 * 0.02,
//                       ),
//                     ),
//                   ),
//                   Icon(
//                     isExpanded
//                         ? Icons.keyboard_arrow_up
//                         : Icons.keyboard_arrow_down,
//                     color: AppColors.grey,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 250),
//             crossFadeState: isExpanded
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             firstChild: const SizedBox.shrink(),
//             secondChild: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
//               child: child,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Auto-filled tag ───────────────────────────────────────────────────────────

// class _AutoFilledTag extends StatelessWidget {
//   const _AutoFilledTag();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE0F2F1),
//         borderRadius: BorderRadius.circular(50),
//         border: Border.all(color: const Color(0xFF80CBC4)),
//       ),
//       child: const Text(
//         'C AUTO-FILLED',
//         style: TextStyle(
//           fontFamily: 'GeneralSans',
//           fontSize: 9,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF00796B),
//           letterSpacing: 9 * 0.02,
//         ),
//       ),
//     );
//   }
// }

// // ── Row helpers ───────────────────────────────────────────────────────────────

// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool showTag;
//   final bool isNegative;

//   const _InfoRow({
//     required this.label,
//     required this.value,
//     this.showTag = false,
//     this.isNegative = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (showTag) ...[const _AutoFilledTag(), const Gap(3)],
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 13,
//                     color: AppColors.greyDark,
//                     letterSpacing: 13 * 0.02,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: isNegative ? Colors.red.shade700 : Colors.black87,
//               letterSpacing: 13 * 0.02,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Divider extends StatelessWidget {
//   const _Divider();
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Divider(color: AppColors.borderLight, height: 1),
//   );
// }

// // ── Section content widgets ───────────────────────────────────────────────────

// class _PersonalInfoContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: const [
//         _InfoRow(label: 'Full Name', value: 'Adewale Okonkwo', showTag: true),
//         _InfoRow(
//           label: 'State of Residence',
//           value: 'Lagos State',
//           showTag: true,
//         ),
//         _InfoRow(
//           label: 'Filing Status',
//           value: 'Individual (Freelancer)',
//           showTag: true,
//         ),
//         _InfoRow(label: 'Tax Year', value: 'January – December 2026'),
//       ],
//     );
//   }
// }

// class _IncomeSummaryContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const _InfoRow(
//           label: 'Primary Employment Income',
//           value: '₦4,800,000',
//           showTag: true,
//         ),
//         const _InfoRow(
//           label: 'Freelance & Contract Income',
//           value: '₦3,600,000',
//           showTag: true,
//         ),
//         const _InfoRow(
//           label: 'Other Income',
//           value: '₦1,200,000',
//           showTag: true,
//         ),
//         const _Divider(),
//         const _InfoRow(label: 'Gross Income', value: '₦9,600,000'),
//       ],
//     );
//   }
// }

// class _DeductionsContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const _InfoRow(
//           label: 'Pension Contribution (8%)',
//           value: '-₦768,000',
//           showTag: true,
//           isNegative: true,
//         ),
//         const _InfoRow(
//           label: 'NHF Contribution',
//           value: '-₦192,000',
//           showTag: true,
//           isNegative: true,
//         ),
//         const _InfoRow(
//           label: 'Life Insurance Relief',
//           value: '-₦120,000',
//           showTag: true,
//           isNegative: true,
//         ),
//         const _InfoRow(
//           label: 'Personal Relief (CRA)',
//           value: '-₦360,000',
//           showTag: true,
//           isNegative: true,
//         ),
//         const _Divider(),
//         const _InfoRow(
//           label: 'Total Deductions',
//           value: '-₦1,440,000',
//           isNegative: true,
//         ),
//       ],
//     );
//   }
// }

// class _TaxComputationContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const _InfoRow(label: 'Gross Income', value: '₦9,600,000'),
//         const _InfoRow(
//           label: 'Total Deductions',
//           value: '-₦1,440,000',
//           isNegative: true,
//         ),
//         const _InfoRow(label: 'Taxable Income', value: '₦8,160,000'),
//         const _Divider(),
//         const _InfoRow(label: 'First ₦300,000 @ 7%', value: '₦21,000'),
//         const _InfoRow(label: 'Next ₦300,000 @ 11%', value: '₦33,000'),
//         const _InfoRow(label: 'Next ₦500,000 @ 15%', value: '₦75,000'),
//         const _InfoRow(
//           label: 'Balance @ 19%–24%',
//           value: '-₦10,600',
//           isNegative: true,
//         ),
//         const _Divider(),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Final Tax Due',
//               style: TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 14 * 0.02,
//               ),
//             ),
//             const Text(
//               '₦118,400',
//               style: TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 14 * 0.02,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // ── Shared step badge ─────────────────────────────────────────────────────────

// class _StepBadge extends StatelessWidget {
//   final String label;
//   const _StepBadge({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: const BoxDecoration(
//             color: Color(0xFFF5C842),
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: const TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//             letterSpacing: 11 * 0.02,
//           ),
//         ),
//       ],
//     );
//   }
// }
