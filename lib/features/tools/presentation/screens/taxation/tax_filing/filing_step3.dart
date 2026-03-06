// lib/features/tools/presentation/screens/taxation/filing/filing_step3_screen.dart
//
// CHANGES vs previous version:
//   • _onProceed() now calls payment/init endpoint instead of just writing to provider
//   • TIN read from filingTinProvider
//   • NoneTaxableRevenues built from the 5 deduction fields (fixed order)
//   • Keyboard dismiss via GestureDetector on root
//   • Errors shown via AppNotification

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
import 'package:savvy_bee_mobile/features/tools/presentation/providers/tax_calculator_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class FilingStep3Screen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.step3;

  const FilingStep3Screen({super.key});

  @override
  ConsumerState<FilingStep3Screen> createState() => _FilingStep3ScreenState();
}

class _FilingStep3ScreenState extends ConsumerState<FilingStep3Screen> {
  final Set<_Section> _expanded = {
    _Section.personalInfo,
    _Section.incomeSummary,
    _Section.deductionsReliefs,
    _Section.taxComputation,
  };

  final _rentCtrl = TextEditingController();
  final _nhfCtrl = TextEditingController();
  final _nhisCtrl = TextEditingController();
  final _pensionCtrl = TextEditingController();
  final _loanCtrl = TextEditingController();
  final _lifeCtrl = TextEditingController();

  bool _deductionsInitialized = false;
  bool _isProceeding = false;

  @override
  void dispose() {
    for (final c in [
      _rentCtrl,
      _nhfCtrl,
      _nhisCtrl,
      _pensionCtrl,
      _loanCtrl,
      _lifeCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _initDeductions(FilingHomeData data) {
    if (_deductionsInitialized) return;
    _deductionsInitialized = true;

    // If there's an existing process, pre-fill from its finance details
    final process = data.fillingProcess;
    if (process != null) {
      final fd = process.financeDetails;
      _rentCtrl.text = fd.deductionFor('Rent').toStringAsFixed(0);
      _nhfCtrl.text = fd.deductionFor('NHF').toStringAsFixed(0);
      _nhisCtrl.text = fd.deductionFor('NHIS').toStringAsFixed(0);
      _pensionCtrl.text = fd.deductionFor('Pension').toStringAsFixed(0);
      _loanCtrl.text = fd.deductionFor('Loan').toStringAsFixed(0);
      _lifeCtrl.text = fd.deductionFor('Life Insurance').toStringAsFixed(0);
    } else {
      for (final c in [
        _rentCtrl,
        _nhfCtrl,
        _nhisCtrl,
        _pensionCtrl,
        _loanCtrl,
        _lifeCtrl,
      ]) {
        c.text = '0';
      }
    }
  }

  double _parseField(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;

  void _toggle(_Section section) => setState(() {
    _expanded.contains(section)
        ? _expanded.remove(section)
        : _expanded.add(section);
  });

  Future<void> _recalculate(FilingHomeData filingData) async {
    FocusScope.of(context).unfocus();
    await ref
        .read(taxCalculatorProvider.notifier)
        .calculate(
          earnings: filingData.totalEarnings,
          rent: _parseField(_rentCtrl),
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

  Future<void> _onProceed(FilingHomeData? filingData) async {
    if (_isProceeding) return;
    FocusScope.of(context).unfocus();
    setState(() => _isProceeding = true);

    try {
      final tin = ref.read(filingTinProvider);
      final plan = ref.read(selectedFilingPlanProvider);
      final calcState = ref.read(taxCalculatorProvider);

      // Build income list from filing data
      final revenues = filingData?.incomes ?? [];

      // Build the 5 deduction items in exact API order
      final noneTaxable = [
        FilingIncomeSource(source: 'Rent', amount: _parseField(_rentCtrl)),
        FilingIncomeSource(
          source: 'NHF Contribution',
          amount: _parseField(_nhfCtrl),
        ),
        FilingIncomeSource(
          source: 'Pension Contribution',
          amount: _parseField(_pensionCtrl),
        ),
        FilingIncomeSource(
          source: 'Interest on Loan for Owner Occupied House',
          amount: _parseField(_loanCtrl),
        ),
        FilingIncomeSource(
          source: 'Life Insurance Premium (You & Spouse)',
          amount: _parseField(_lifeCtrl),
        ),
      ];

      final repo = ref.read(filingPaymentRepositoryProvider);
      final result = await repo.initPayment(
        plan: plan,
        tin: tin,
        revenues: revenues,
        noneTaxableRevenues: noneTaxable,
      );

      // Use the TaxAmount returned by the API as the authoritative figure
      final taxDue = result.financeDetails.taxAmount > 0
          ? result.financeDetails.taxAmount
          : (calcState.result?.finalTaxDue ?? filingData?.estimatedTax ?? 0.0);

      ref.read(filingTaxDueProvider.notifier).state = taxDue;

      if (mounted) {
        setState(() => _isProceeding = false);
        context.pushNamed(FilingRoutes.step4);
      }
    } catch (e) {
      setState(() => _isProceeding = false);
      if (mounted) {
        AppNotification.show(
          context,
          message: 'Could not initialise payment: ${e.toString()}',
          icon: Icons.error_outline,
          iconColor: Colors.redAccent,
        );
      }
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

    final taxYear = DateTime.now().year - 1;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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

                  // ── Identity card ──────────────────────────────────
                  profileAsync.when(
                    data: (home) {
                      final user = home.data;
                      final initials = '${user.firstName[0]}${user.lastName[0]}'
                          .toUpperCase();
                      return _IdentityCard(
                        initials: initials,
                        fullName: '${user.firstName} ${user.lastName}',
                        taxYear: taxYear,
                      );
                    },
                    loading: () => const _IdentityCard(
                      initials: '..',
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
                          countryOfResidence: user.country,
                          filingStatus: selectedPlan,
                          taxYear: taxYear,
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Could not load profile: $e'),
                    ),
                  ),
                  const Gap(12),

                  _CollapsibleSection(
                    title: 'Income Summary',
                    isExpanded: _expanded.contains(_Section.incomeSummary),
                    onToggle: () => _toggle(_Section.incomeSummary),
                    child: filingData != null
                        ? _IncomeSummaryContent(incomes: filingData.incomes)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const Gap(12),

                  _CollapsibleSection(
                    title: 'Deductions & Reliefs',
                    isExpanded: _expanded.contains(_Section.deductionsReliefs),
                    onToggle: () => _toggle(_Section.deductionsReliefs),
                    child: _DeductionsContent(
                      rentCtrl: _rentCtrl,
                      nhfCtrl: _nhfCtrl,
                      nhisCtrl: _nhisCtrl,
                      pensionCtrl: _pensionCtrl,
                      loanCtrl: _loanCtrl,
                      lifeCtrl: _lifeCtrl,
                      isLoading: calcState.isLoading,
                      onRecalculate: filingData != null
                          ? () => _recalculate(filingData)
                          : null,
                      totalDeductions: calcState.result?.exemption ?? 0,
                    ),
                  ),
                  const Gap(12),

                  _CollapsibleSection(
                    title: 'Tax Computation',
                    isExpanded: _expanded.contains(_Section.taxComputation),
                    onToggle: () => _toggle(_Section.taxComputation),
                    child: filingData != null
                        ? _TaxComputationContent(
                            grossIncome: filingData.totalEarnings,
                            calcResult: calcState.result,
                            fallbackTaxableIncome: filingData.taxableIncome,
                            fallbackStages: filingData.stages,
                            fallbackEstimatedTax: filingData.estimatedTax,
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const Gap(16),

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
                            "Once you confirm this return, you'll be asked to complete your filing payment before we submit.",
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
              label: _isProceeding
                  ? 'Initialising…'
                  : 'This looks right — proceed to payment',
              onTap: _isProceeding ? null : () => _onProceed(filingData),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section enum ──────────────────────────────────────────────────────────────

enum _Section { personalInfo, incomeSummary, deductionsReliefs, taxComputation }

// ── Widgets (unchanged from previous version) ─────────────────────────────────

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
  Widget build(BuildContext context) => Container(
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
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5C842).withValues(alpha: 0.15),
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
  Widget build(BuildContext context) => Container(
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

class _AutoFilledTag extends StatelessWidget {
  const _AutoFilledTag();
  @override
  Widget build(BuildContext context) => Container(
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
  Widget build(BuildContext context) => Padding(
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

class _EditableDeductionRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _EditableDeductionRow({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) => Padding(
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
                horizontal: 10,
                vertical: 8,
              ),
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
                  color: Color(0xFFF5C842),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(color: AppColors.borderLight, height: 1),
  );
}

class _PersonalInfoContent extends StatelessWidget {
  final String fullName, email, countryOfResidence, filingStatus;
  final int taxYear;
  const _PersonalInfoContent({
    required this.fullName,
    required this.email,
    required this.countryOfResidence,
    required this.filingStatus,
    required this.taxYear,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _InfoRow(label: 'Full Name', value: fullName, showTag: true),
      _InfoRow(label: 'Email', value: email, showTag: true),
      _InfoRow(
        label: 'Country of Residence',
        value: countryOfResidence,
        showTag: true,
      ),
      _InfoRow(label: 'Filing Status', value: filingStatus, showTag: true),
      _InfoRow(label: 'Tax Year', value: 'January – December $taxYear'),
    ],
  );
}

class _IncomeSummaryContent extends StatelessWidget {
  final List<FilingIncomeSource> incomes;
  const _IncomeSummaryContent({required this.incomes});
  @override
  Widget build(BuildContext context) {
    final total = incomes.fold(0.0, (s, i) => s + i.amount);
    return Column(
      children: [
        ...incomes.map(
          (i) => _InfoRow(
            label: i.source,
            value: i.amount.formatCurrency(decimalDigits: 0),
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
  final TextEditingController rentCtrl,
      nhfCtrl,
      nhisCtrl,
      pensionCtrl,
      loanCtrl,
      lifeCtrl;
  final bool isLoading;
  final VoidCallback? onRecalculate;
  final double totalDeductions;
  static const _yellow = Color(0xFFF5C842);
  const _DeductionsContent({
    required this.rentCtrl,
    required this.nhfCtrl,
    required this.nhisCtrl,
    required this.pensionCtrl,
    required this.loanCtrl,
    required this.lifeCtrl,
    required this.isLoading,
    required this.onRecalculate,
    required this.totalDeductions,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _EditableDeductionRow(label: 'Annual Rent Paid', controller: rentCtrl),
      _EditableDeductionRow(
        label: 'NHF Contribution (Annual)',
        controller: nhfCtrl,
      ),
      _EditableDeductionRow(label: 'NHIS Contribution', controller: nhisCtrl),
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
              : const Icon(
                  Icons.calculate_outlined,
                  size: 16,
                  color: Colors.black87,
                ),
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
              color: totalDeductions > 0 ? Colors.red.shade700 : Colors.black87,
              letterSpacing: 13 * 0.02,
            ),
          ),
        ],
      ),
    ],
  );
}

class _TaxComputationContent extends StatelessWidget {
  final double grossIncome;
  final TaxCalculatorResult? calcResult;
  final double fallbackTaxableIncome, fallbackEstimatedTax;
  final FilingStages fallbackStages;
  const _TaxComputationContent({
    required this.grossIncome,
    required this.calcResult,
    required this.fallbackTaxableIncome,
    required this.fallbackStages,
    required this.fallbackEstimatedTax,
  });

  @override
  Widget build(BuildContext context) {
    final taxableIncome = calcResult?.taxableIncome ?? fallbackTaxableIncome;
    final totalDeductions =
        calcResult?.exemption ?? (grossIncome - fallbackTaxableIncome);
    final finalTaxDue = calcResult?.finalTaxDue ?? fallbackEstimatedTax;
    final stageLabels = [
      'First ₦800,000 @ 0%',
      'Next ₦2,200,000 @ 15%',
      'Next ₦9,000,000 @ 18%',
      'Next ₦13,000,000 @ 21%',
      'Next ₦25,000,000 @ 23%',
      'Next ₦50,000,000 @ 25%',
    ];
    List<MapEntry<String, double>> stageEntries;
    if (calcResult != null) {
      stageEntries = calcResult!.stages.nonZeroEntries;
    } else {
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
          if (vals[i] != 0) MapEntry(stageLabels[i], vals[i]),
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

class _StepBadge extends StatelessWidget {
  final String label;
  const _StepBadge({required this.label});
  @override
  Widget build(BuildContext context) => Row(
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

// // lib/features/tools/presentation/screens/taxation/filing/filing_step3_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
// import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/tax_calculator_result.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_tax_due_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/selected_filing_plan_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/tax_calculator_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

// // ── Screen ────────────────────────────────────────────────────────────────────

// class FilingStep3Screen extends ConsumerStatefulWidget {
//   static const String path = FilingRoutes.step3;

//   const FilingStep3Screen({super.key});

//   @override
//   ConsumerState<FilingStep3Screen> createState() => _FilingStep3ScreenState();
// }

// class _FilingStep3ScreenState extends ConsumerState<FilingStep3Screen> {
//   final Set<_Section> _expanded = {
//     _Section.personalInfo,
//     _Section.incomeSummary,
//     _Section.deductionsReliefs,
//     _Section.taxComputation,
//   };

//   // ── Deduction + rent controllers ──────────────────────────────────────────
//   final _rentCtrl = TextEditingController();
//   final _nhfCtrl = TextEditingController();
//   final _nhisCtrl = TextEditingController();
//   final _pensionCtrl = TextEditingController();
//   final _loanCtrl = TextEditingController();
//   final _lifeCtrl = TextEditingController();

//   bool _deductionsInitialized = false;

//   @override
//   void dispose() {
//     _rentCtrl.dispose();
//     _nhfCtrl.dispose();
//     _nhisCtrl.dispose();
//     _pensionCtrl.dispose();
//     _loanCtrl.dispose();
//     _lifeCtrl.dispose();
//     super.dispose();
//   }

//   void _initDeductions(FilingHomeData data) {
//     if (_deductionsInitialized) return;
//     _deductionsInitialized = true;
//     _rentCtrl.text = '0';
//     _nhfCtrl.text = '0';
//     _nhisCtrl.text = '0';
//     _pensionCtrl.text = '0';
//     _loanCtrl.text = '0';
//     _lifeCtrl.text = '0';
//   }

//   double _parseField(TextEditingController ctrl) =>
//       double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;

//   void _toggle(_Section section) {
//     setState(() {
//       _expanded.contains(section)
//           ? _expanded.remove(section)
//           : _expanded.add(section);
//     });
//   }

//   Future<void> _recalculate(FilingHomeData filingData) async {
//     // rent → separate param; all other deductions → otherExemptions
//     await ref
//         .read(taxCalculatorProvider.notifier)
//         .calculate(
//           earnings: filingData.totalEarnings,
//           rent: _parseField(_rentCtrl),
//           nhf: _parseField(_nhfCtrl),
//           nhis: _parseField(_nhisCtrl),
//           pension: _parseField(_pensionCtrl),
//           loanInterest: _parseField(_loanCtrl),
//           lifeInsurance: _parseField(_lifeCtrl),
//         );

//     final calcState = ref.read(taxCalculatorProvider);
//     if (calcState.error != null && mounted) {
//       AppNotification.show(
//         context,
//         message: 'Recalculation failed. Please try again.',
//         icon: Icons.error_outline,
//         iconColor: Colors.redAccent,
//       );
//     }
//   }

//   void _onProceed(FilingHomeData? filingData) {
//     final calcState = ref.read(taxCalculatorProvider);

//     // Resolve the final tax due: calculator result > fallback from filing API
//     final taxDue =
//         calcState.result?.finalTaxDue ?? filingData?.estimatedTax ?? 0.0;

//     // Persist so Steps 4 / 5 / 6 can read it
//     ref.read(filingTaxDueProvider.notifier).state = taxDue;

//     context.pushNamed(FilingRoutes.step4);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filingAsync = ref.watch(filingHomeProvider);
//     final profileAsync = ref.watch(homeDataProvider);
//     final selectedPlan = ref.watch(selectedFilingPlanProvider);
//     final calcState = ref.watch(taxCalculatorProvider);

//     final filingData = filingAsync.value;
//     if (filingData != null) _initDeductions(filingData);

//     final taxYear = DateTime.now().year - 1;

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
//                 const _StepBadge(label: 'STEP 3 OF 6 · REVIEW RETURN'),
//                 const Gap(16),
//                 Text(
//                   'Your pre-filled $taxYear return',
//                   style: const TextStyle(
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
//                 profileAsync.when(
//                   data: (home) {
//                     final user = home.data;
//                     final initials = '${user.firstName[0]}${user.lastName[0]}'
//                         .toUpperCase();
//                     return _IdentityCard(
//                       initials: initials,
//                       fullName: '${user.firstName} ${user.lastName}',
//                       taxYear: taxYear,
//                     );
//                   },
//                   loading: () => const _IdentityCard(
//                     initials: '..',
//                     fullName: 'Loading...',
//                     taxYear: 0,
//                   ),
//                   error: (_, __) => const _IdentityCard(
//                     initials: '?',
//                     fullName: 'Unknown',
//                     taxYear: 0,
//                   ),
//                 ),
//                 const Gap(16),

//                 // ── Personal Information ──────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Personal Information',
//                   isExpanded: _expanded.contains(_Section.personalInfo),
//                   onToggle: () => _toggle(_Section.personalInfo),
//                   child: profileAsync.when(
//                     data: (home) {
//                       final user = home.data;
//                       return _PersonalInfoContent(
//                         fullName: '${user.firstName} ${user.lastName}',
//                         email: user.email,
//                         countryOfResidence: user.country,
//                         filingStatus: selectedPlan,
//                         taxYear: taxYear,
//                       );
//                     },
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (e, _) => Text(
//                       'Could not load profile: $e',
//                       style: const TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const Gap(12),

//                 // ── Income Summary ────────────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Income Summary',
//                   isExpanded: _expanded.contains(_Section.incomeSummary),
//                   onToggle: () => _toggle(_Section.incomeSummary),
//                   child: filingData != null
//                       ? _IncomeSummaryContent(incomes: filingData.incomes)
//                       : const Center(child: CircularProgressIndicator()),
//                 ),
//                 const Gap(12),

//                 // ── Deductions & Reliefs ──────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Deductions & Reliefs',
//                   isExpanded: _expanded.contains(_Section.deductionsReliefs),
//                   onToggle: () => _toggle(_Section.deductionsReliefs),
//                   child: _DeductionsContent(
//                     rentCtrl: _rentCtrl,
//                     nhfCtrl: _nhfCtrl,
//                     nhisCtrl: _nhisCtrl,
//                     pensionCtrl: _pensionCtrl,
//                     loanCtrl: _loanCtrl,
//                     lifeCtrl: _lifeCtrl,
//                     isLoading: calcState.isLoading,
//                     onRecalculate: filingData != null
//                         ? () => _recalculate(filingData)
//                         : null,
//                     totalDeductions: calcState.result?.exemption ?? 0,
//                   ),
//                 ),
//                 const Gap(12),

//                 // ── Tax Computation ───────────────────────────────────
//                 _CollapsibleSection(
//                   title: 'Tax Computation',
//                   isExpanded: _expanded.contains(_Section.taxComputation),
//                   onToggle: () => _toggle(_Section.taxComputation),
//                   child: filingData != null
//                       ? _TaxComputationContent(
//                           grossIncome: filingData.totalEarnings,
//                           calcResult: calcState.result,
//                           fallbackTaxableIncome: filingData.taxableIncome,
//                           fallbackStages: filingData.stages,
//                           fallbackEstimatedTax: filingData.estimatedTax,
//                         )
//                       : const Center(child: CircularProgressIndicator()),
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
//             onTap: () => _onProceed(filingData),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Section enum ──────────────────────────────────────────────────────────────

// enum _Section { personalInfo, incomeSummary, deductionsReliefs, taxComputation }

// // ── Identity card ─────────────────────────────────────────────────────────────

// class _IdentityCard extends StatelessWidget {
//   final String initials;
//   final String fullName;
//   final int taxYear;

//   const _IdentityCard({
//     required this.initials,
//     required this.fullName,
//     required this.taxYear,
//   });

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
//             child: Center(
//               child: Text(
//                 initials,
//                 style: const TextStyle(
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
//             child: Text(
//               fullName,
//               style: const TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 14 * 0.02,
//               ),
//             ),
//           ),
//           if (taxYear > 0)
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5C842).withValues(alpha: 0.15),
//                 borderRadius: BorderRadius.circular(50),
//                 border: Border.all(
//                   color: const Color(0xFFF5C842).withValues(alpha: 0.4),
//                 ),
//               ),
//               child: Text(
//                 '$taxYear Return',
//                 style: const TextStyle(
//                   fontFamily: 'GeneralSans',
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 11 * 0.02,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ── Collapsible section ───────────────────────────────────────────────────────

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

// // ── Helpers ───────────────────────────────────────────────────────────────────

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

// class _EditableDeductionRow extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;

//   const _EditableDeductionRow({required this.label, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 color: AppColors.greyDark,
//                 letterSpacing: 13 * 0.02,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 130,
//             height: 38,
//             child: TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               textAlign: TextAlign.right,
//               style: const TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: InputDecoration(
//                 prefixText: '₦ ',
//                 prefixStyle: TextStyle(
//                   fontFamily: 'GeneralSans',
//                   fontSize: 13,
//                   color: AppColors.greyDark,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 8,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.borderLight),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.borderLight),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(
//                     color: Color(0xFFF5C842),
//                     width: 1.5,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SectionDivider extends StatelessWidget {
//   const _SectionDivider();

//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Divider(color: AppColors.borderLight, height: 1),
//   );
// }

// // ── Section content widgets ───────────────────────────────────────────────────

// class _PersonalInfoContent extends StatelessWidget {
//   final String fullName;
//   final String email;
//   final String countryOfResidence;
//   final String filingStatus;
//   final int taxYear;

//   const _PersonalInfoContent({
//     required this.fullName,
//     required this.email,
//     required this.countryOfResidence,
//     required this.filingStatus,
//     required this.taxYear,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _InfoRow(label: 'Full Name', value: fullName, showTag: true),
//         _InfoRow(label: 'Email', value: email, showTag: true),
//         _InfoRow(
//           label: 'Country of Residence',
//           value: countryOfResidence,
//           showTag: true,
//         ),
//         _InfoRow(label: 'Filing Status', value: filingStatus, showTag: true),
//         _InfoRow(label: 'Tax Year', value: 'January – December $taxYear'),
//       ],
//     );
//   }
// }

// class _IncomeSummaryContent extends StatelessWidget {
//   final List<FilingIncomeSource> incomes;

//   const _IncomeSummaryContent({required this.incomes});

//   @override
//   Widget build(BuildContext context) {
//     final total = incomes.fold(0.0, (sum, i) => sum + i.amount);
//     return Column(
//       children: [
//         ...incomes.map(
//           (income) => _InfoRow(
//             label: income.source,
//             value: income.amount.formatCurrency(decimalDigits: 0),
//             showTag: true,
//           ),
//         ),
//         const _SectionDivider(),
//         _InfoRow(
//           label: 'Gross Income',
//           value: total.formatCurrency(decimalDigits: 0),
//         ),
//       ],
//     );
//   }
// }

// class _DeductionsContent extends StatelessWidget {
//   // ── Controllers ───────────────────────────────────────────────────────────
//   final TextEditingController rentCtrl; // → passed as `rent`
//   final TextEditingController nhfCtrl; // ─┐
//   final TextEditingController nhisCtrl; //  │ summed → otherExemptions
//   final TextEditingController pensionCtrl; //  │
//   final TextEditingController loanCtrl; //  │
//   final TextEditingController lifeCtrl; // ─┘

//   final bool isLoading;
//   final VoidCallback? onRecalculate;
//   final double totalDeductions;

//   const _DeductionsContent({
//     required this.rentCtrl,
//     required this.nhfCtrl,
//     required this.nhisCtrl,
//     required this.pensionCtrl,
//     required this.loanCtrl,
//     required this.lifeCtrl,
//     required this.isLoading,
//     required this.onRecalculate,
//     required this.totalDeductions,
//   });

//   static const _yellow = Color(0xFFF5C842);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Rent (separate endpoint param) ───────────────────────
//         _EditableDeductionRow(label: 'Annual Rent Paid', controller: rentCtrl),

//         // ── Other exemptions (summed → otherExemptions) ──────────
//         _EditableDeductionRow(
//           label: 'NHF Contribution (Annual)',
//           controller: nhfCtrl,
//         ),
//         _EditableDeductionRow(label: 'NHIS Contribution', controller: nhisCtrl),
//         _EditableDeductionRow(
//           label: 'Pension Contribution',
//           controller: pensionCtrl,
//         ),
//         _EditableDeductionRow(
//           label: 'Interest on Loan (Owner Occupied)',
//           controller: loanCtrl,
//         ),
//         _EditableDeductionRow(
//           label: 'Life Insurance Premium (You & Spouse)',
//           controller: lifeCtrl,
//         ),
//         const Gap(4),

//         // ── Recalculate button ────────────────────────────────────
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             onPressed: isLoading ? null : onRecalculate,
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: _yellow, width: 1.5),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               backgroundColor: _yellow.withValues(alpha: 0.05),
//             ),
//             icon: isLoading
//                 ? const SizedBox(
//                     width: 14,
//                     height: 14,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.black54,
//                     ),
//                   )
//                 : const Icon(
//                     Icons.calculate_outlined,
//                     size: 16,
//                     color: Colors.black87,
//                   ),
//             label: Text(
//               isLoading ? 'Recalculating…' : 'Recalculate Tax',
//               style: const TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//                 letterSpacing: 13 * 0.02,
//               ),
//             ),
//           ),
//         ),
//         const Gap(12),
//         const _SectionDivider(),

//         // ── Total deductions ──────────────────────────────────────
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Total Deductions',
//               style: TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 color: AppColors.greyDark,
//                 letterSpacing: 13 * 0.02,
//               ),
//             ),
//             Text(
//               totalDeductions > 0
//                   ? '-${totalDeductions.formatCurrency(decimalDigits: 0)}'
//                   : '₦0',
//               style: TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: totalDeductions > 0
//                     ? Colors.red.shade700
//                     : Colors.black87,
//                 letterSpacing: 13 * 0.02,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _TaxComputationContent extends StatelessWidget {
//   final double grossIncome;
//   final TaxCalculatorResult? calcResult;
//   final double fallbackTaxableIncome;
//   final FilingStages fallbackStages;
//   final double fallbackEstimatedTax;

//   const _TaxComputationContent({
//     required this.grossIncome,
//     required this.calcResult,
//     required this.fallbackTaxableIncome,
//     required this.fallbackStages,
//     required this.fallbackEstimatedTax,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final taxableIncome = calcResult?.taxableIncome ?? fallbackTaxableIncome;
//     final totalDeductions =
//         calcResult?.exemption ?? (grossIncome - fallbackTaxableIncome);
//     final finalTaxDue = calcResult?.finalTaxDue ?? fallbackEstimatedTax;

//     List<MapEntry<String, double>> stageEntries;
//     if (calcResult != null) {
//       stageEntries = calcResult!.stages.nonZeroEntries;
//     } else {
//       final labels = [
//         'First ₦800,000 @ 0%',
//         'Next ₦2,200,000 @ 15%',
//         'Next ₦9,000,000 @ 18%',
//         'Next ₦13,000,000 @ 21%',
//         'Next ₦25,000,000 @ 23%',
//         'Next ₦50,000,000 @ 25%',
//       ];
//       final vals = [
//         fallbackStages.stage1,
//         fallbackStages.stage2,
//         fallbackStages.stage3,
//         fallbackStages.stage4,
//         fallbackStages.stage5,
//         fallbackStages.stage6,
//       ];
//       stageEntries = [
//         for (int i = 0; i < 6; i++)
//           if (vals[i] != 0) MapEntry(labels[i], vals[i]),
//       ];
//     }

//     return Column(
//       children: [
//         _InfoRow(
//           label: 'Gross Income',
//           value: grossIncome.formatCurrency(decimalDigits: 0),
//         ),
//         _InfoRow(
//           label: 'Total Deductions',
//           value: totalDeductions > 0
//               ? '-${totalDeductions.formatCurrency(decimalDigits: 0)}'
//               : '₦0',
//           isNegative: totalDeductions > 0,
//         ),
//         _InfoRow(
//           label: 'Taxable Income',
//           value: taxableIncome.formatCurrency(decimalDigits: 0),
//         ),
//         const _SectionDivider(),
//         ...stageEntries.map(
//           (e) => _InfoRow(
//             label: e.key,
//             value: e.value.formatCurrency(decimalDigits: 0),
//           ),
//         ),
//         const _SectionDivider(),
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
//             Text(
//               finalTaxDue.formatCurrency(decimalDigits: 0),
//               style: const TextStyle(
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

// // ── Step badge ────────────────────────────────────────────────────────────────

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
