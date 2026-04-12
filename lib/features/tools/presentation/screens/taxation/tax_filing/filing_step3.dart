// lib/features/tools/presentation/screens/taxation/filing/filing_step3_screen.dart
//
// CHANGES vs previous version:
//   • _onProceed() calls payment/init and writes filingIDProvider,
//     filingTaxDueProvider, and filingWalletBalanceProvider (from result.walletBalance)
//   • Gross income for Recalculate uses sum of incomes (matches Income Summary display)
//   • TIN read from filingTinProvider
//   • NoneTaxableRevenues built from the 5 deduction fields (fixed order)
//   • Keyboard dismiss via GestureDetector on root
//   • Errors shown via AppNotification

import 'dart:math';

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
import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_payment_repository.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/tin_validation_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/tax_calculator_result.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/complex_paye_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/tax_calculator_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/tin_validation_provider.dart';
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

  // Income source controllers — initialised once from filingData.incomes
  final List<TextEditingController> _incomeControllers = [];
  List<FilingIncomeSource> _incomeSourcesMeta = []; // holds source labels
  bool _incomesInitialized = false;

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
      ..._incomeControllers,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _initIncomes(List<FilingIncomeSource> incomes) {
    if (_incomesInitialized) return;
    _incomesInitialized = true;
    _incomeSourcesMeta = incomes;
    for (final income in incomes) {
      _incomeControllers.add(
        TextEditingController(text: income.amount.toStringAsFixed(0)),
      );
    }
  }

  void _initDeductions(FilingHomeData data) {
    if (_deductionsInitialized) return;
    _deductionsInitialized = true;

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

    // Gross income = sum of edited income controller values (or original if not yet edited)
    final grossIncome = _incomeControllers.isNotEmpty
        ? _incomeControllers.fold(
            0.0,
            (sum, c) => sum + (double.tryParse(c.text.replaceAll(',', '')) ?? 0.0),
          )
        : filingData.incomes.fold(0.0, (sum, i) => sum + i.amount);

    await ref
        .read(taxCalculatorProvider.notifier)
        .calculate(
          earnings: grossIncome,
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

  /// Shows a dialog to collect missing PhoneNo and/or Address.
  /// Returns a record (phone, address) on confirm, or null if dismissed.
  Future<(String, String, String)?> _showMissingContactDialog({
    required bool missingPhone,
    required bool missingAddress,
    required bool missingCac,
    required String classification,
    required String existingPhone,
    required String existingAddress,
  }) async {
    final phoneCtrl = TextEditingController(text: existingPhone);
    final addressCtrl = TextEditingController(text: existingAddress);
    final cacCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<(String, String, String)>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Contact details required',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide the following details to continue with your tax filing.',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Gap(16),
              if (missingPhone) ...[
                const Text(
                  'Phone Number *',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(6),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    hintText: 'e.g. 08012345678',
                    hintStyle: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().length < 7) ? 'Enter a valid phone number' : null,
                ),
                const Gap(16),
              ],
              if (missingAddress) ...[
                const Text(
                  'Residential Address *',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(6),
                TextFormField(
                  controller: addressCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'e.g. 12 Allen Avenue, Ikeja, Lagos',
                    hintStyle: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter your address' : null,
                ),
              ],
              if (missingCac && classification == 'Corporate') ...[
                const Gap(16),
                const Text(
                  'CAC Registration Number *',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(6),
                TextFormField(
                  controller: cacCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g. RC-1234567',
                    hintStyle: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter your CAC number' : null,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final formState = formKey.currentState;
              if (formState != null && formState.validate()) {
                Navigator.of(ctx).pop((
                  phoneCtrl.text.trim(),
                  addressCtrl.text.trim(),
                  cacCtrl.text.trim(),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontFamily: 'GeneralSans', fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  Future<void> _onProceed(
    FilingHomeData? filingData,
    TinValidationResult? tinResult,
  ) async {
    if (_isProceeding) return;
    FocusScope.of(context).unfocus();
    setState(() => _isProceeding = true);

    try {
      final tin = ref.read(filingTinProvider);
      final plan = ref.read(selectedFilingPlanProvider);
      final classification = ref.read(filingClassificationProvider);
      final contactRecord = ref.read(filingContactProvider);
      final calcState = ref.read(taxCalculatorProvider);
      final profileData = ref.read(homeDataProvider).value?.data;

      // ── Contact: profile data is the base, TIN result overrides when present ─
      String phoneNo = profileData?.phoneNumber?.isNotEmpty == true
          ? profileData!.phoneNumber!
          : contactRecord.phoneNo;
      String email = profileData?.email.isNotEmpty == true
          ? profileData!.email
          : contactRecord.email;
      String address = contactRecord.address;

      if (tinResult != null) {
        if (tinResult.phoneNumber?.isNotEmpty ?? false) {
          phoneNo = tinResult.phoneNumber!;
        }
        if (tinResult.email?.isNotEmpty ?? false) {
          email = tinResult.email!;
        }
        if (tinResult.address?.isNotEmpty ?? false) {
          address = tinResult.address!;
        }
      }

      // CAC number: prefer TIN result, then provider, then auto-generate for Individual
      final cacNumber = ref.read(filingCacNumberProvider);
      String cacNo = (tinResult?.cacRegNumber?.isNotEmpty ?? false)
          ? tinResult!.cacRegNumber!
          : cacNumber;
      if (cacNo.isEmpty && classification != 'Corporate') {
        // Individual filers don't have a CAC — generate a placeholder
        final rng = Random();
        cacNo = 'IND-${rng.nextInt(900000) + 100000}';
      }

      // ── If phone, address, or corporate CAC is missing, ask the user ─────────
      final missingCac = cacNo.isEmpty && classification == 'Corporate';
      if (phoneNo.isEmpty || address.isEmpty || missingCac) {
        final filled = await _showMissingContactDialog(
          missingPhone: phoneNo.isEmpty,
          missingAddress: address.isEmpty,
          missingCac: missingCac,
          classification: classification,
          existingPhone: phoneNo,
          existingAddress: address,
        );
        if (!mounted) return;
        if (filled == null) {
          // User dismissed — abort
          setState(() => _isProceeding = false);
          return;
        }
        if (phoneNo.isEmpty) phoneNo = filled.$1;
        if (address.isEmpty) address = filled.$2;
        if (missingCac && filled.$3.isNotEmpty) cacNo = filled.$3;
      }

      print(
        'Final contact for API → Phone: $phoneNo | Email: $email | Address: $address',
      );

      final contact = FilingContactInfo(
        phoneNo: phoneNo,
        address: address,
        email: email,
      );

      // Use edited income values if controllers are initialised, otherwise fall back to API values
      final revenues = _incomeControllers.isNotEmpty && _incomeSourcesMeta.isNotEmpty
          ? List.generate(
              _incomeSourcesMeta.length,
              (i) => FilingIncomeSource(
                source: _incomeSourcesMeta[i].source,
                amount: double.tryParse(
                      _incomeControllers[i].text.replaceAll(',', ''),
                    ) ??
                    _incomeSourcesMeta[i].amount,
              ),
            )
          : (filingData?.incomes ?? []);

      final noneTaxable = [
        FilingIncomeSource(source: 'Rent', amount: _parseField(_rentCtrl)),
        FilingIncomeSource(
          source: 'NHF Contribution',
          amount: _parseField(_nhfCtrl),
        ),
        FilingIncomeSource(
          source: 'NHIS Contribution',
          amount: _parseField(_nhisCtrl),
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

      // Name: prefer TIN result, then profile full name, then registration data
      final profileFullName =
          '${profileData?.firstName ?? ''} ${profileData?.lastName ?? ''}'.trim();
      final name = (tinResult?.taxpayerName.isNotEmpty ?? false)
          ? tinResult!.taxpayerName
          : profileFullName.isNotEmpty
              ? profileFullName
              : ref.read(filingNameProvider);

      final repo = ref.read(filingPaymentRepositoryProvider);
      final result = await repo.initPayment(
        plan: plan,
        tin: tin,
        classification: classification,
        name: name,
        cacNumber: cacNo,
        contact: contact,
        revenues: revenues,
        noneTaxableRevenues: noneTaxable,
      );

      // Tax due: authoritative API value, fall back to local calculation
      final taxDue = result.financeDetails.taxAmount > 0
          ? result.financeDetails.taxAmount
          : (calcState.result?.finalTaxDue ?? filingData?.estimatedTax ?? 0.0);

      print('TaxAmount: ${result.financeDetails.taxAmount}');
      print('Final Tax Due (calc): ${calcState.result?.finalTaxDue}');
      print('Wallet Balance: ${result.walletBalance}');

      final ID = result.id;

      print('This is the ID Sent: $result'); 

      ref.read(filingTaxDueProvider.notifier).state = taxDue;
      ref.read(filingIDProvider.notifier).state = ID;
      // ── Store wallet balance from init response for Steps 4 & 5 ────────────
      ref.read(filingWalletBalanceProvider.notifier).state =
          result.walletBalance;
      // Reset complex PAYE fee so Step 4 doesn't use a stale value from a
      // previous Complex PAYE filing when coming through the regular flow.
      ref.read(complexPayeFilingFeeProvider.notifier).state = 0.0;

      if (mounted) {
        setState(() => _isProceeding = false);
        context.pushNamed(FilingRoutes.step4);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProceeding = false);
        AppNotification.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
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
    final tinResult = ref.watch(tinValidationResultProvider);

    final filingData = filingAsync.value;
    if (filingData != null) {
      _initDeductions(filingData);
      _initIncomes(filingData.incomes);
    }

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

                  profileAsync.when(
                    data: (home) {
                      final user = home.data;
                      final fn = user.firstName;
                      final ln = user.lastName;
                      final initials =
                          '${fn.isNotEmpty ? fn[0] : '?'}${ln.isNotEmpty ? ln[0] : '?'}'
                              .toUpperCase();
                      return _IdentityCard(
                        initials: initials,
                        fullName: '${fn} ${ln}'.trim(),
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
                    child: filingData != null && _incomeControllers.isNotEmpty
                        ? _IncomeSummaryContent(
                            incomes: _incomeSourcesMeta,
                            controllers: _incomeControllers,
                            onChanged: () => setState(() {}),
                          )
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

                  // Recalculate gross income from edited controllers if available
                  _CollapsibleSection(
                    title: 'Tax Computation',
                    isExpanded: _expanded.contains(_Section.taxComputation),
                    onToggle: () => _toggle(_Section.taxComputation),
                    child: filingData != null
                        ? _TaxComputationContent(
                            grossIncome: _incomeControllers.isNotEmpty
                                ? _incomeControllers.fold(
                                    0.0,
                                    (s, c) => s + (double.tryParse(c.text.replaceAll(',', '')) ?? 0.0),
                                  )
                                : filingData.incomes.fold(0.0, (s, i) => s + i.amount),
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
              onTap: _isProceeding
                  ? null
                  : () => _onProceed(filingData, tinResult),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section enum ──────────────────────────────────────────────────────────────

enum _Section { personalInfo, incomeSummary, deductionsReliefs, taxComputation }

// ── Widgets ───────────────────────────────────────────────────────────────────

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
  final VoidCallback? onChanged;
  const _EditableDeductionRow({
    required this.label,
    required this.controller,
    this.onChanged,
  });

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
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.right,
            onChanged: (_) => onChanged?.call(),
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

class _IncomeSummaryContent extends StatefulWidget {
  final List<FilingIncomeSource> incomes;
  final List<TextEditingController> controllers;
  final VoidCallback onChanged;
  const _IncomeSummaryContent({
    required this.incomes,
    required this.controllers,
    required this.onChanged,
  });
  @override
  State<_IncomeSummaryContent> createState() => _IncomeSummaryContentState();
}

class _IncomeSummaryContentState extends State<_IncomeSummaryContent> {
  double get _total => widget.controllers.fold(
        0.0,
        (s, c) => s + (double.tryParse(c.text.replaceAll(',', '')) ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.incomes.length; i++)
          _EditableDeductionRow(
            label: widget.incomes[i].source,
            controller: widget.controllers[i],
            onChanged: () {
              setState(() {});
              widget.onChanged();
            },
          ),
        const _SectionDivider(),
        _InfoRow(
          label: 'Gross Income',
          value: _total.formatCurrency(decimalDigits: 0),
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
// //
// // CHANGES vs previous version:
// //   • _onProceed() now calls payment/init endpoint instead of just writing to provider
// //   • TIN read from filingTinProvider
// //   • NoneTaxableRevenues built from the 5 deduction fields (fixed order)
// //   • Keyboard dismiss via GestureDetector on root
// //   • Errors shown via AppNotification

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
// import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_payment_repository.dart';
// import 'package:savvy_bee_mobile/features/tools/data/repositories/tin_validation_repository.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/tax_calculator_result.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/tax_calculator_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/tin_validation_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

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

//   final _rentCtrl = TextEditingController();
//   final _nhfCtrl = TextEditingController();
//   final _nhisCtrl = TextEditingController();
//   final _pensionCtrl = TextEditingController();
//   final _loanCtrl = TextEditingController();
//   final _lifeCtrl = TextEditingController();

//   bool _deductionsInitialized = false;
//   bool _isProceeding = false;

//   @override
//   void dispose() {
//     for (final c in [
//       _rentCtrl,
//       _nhfCtrl,
//       _nhisCtrl,
//       _pensionCtrl,
//       _loanCtrl,
//       _lifeCtrl,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   void _initDeductions(FilingHomeData data) {
//     if (_deductionsInitialized) return;
//     _deductionsInitialized = true;

//     // If there's an existing process, pre-fill from its finance details
//     final process = data.fillingProcess;
//     if (process != null) {
//       final fd = process.financeDetails;
//       _rentCtrl.text = fd.deductionFor('Rent').toStringAsFixed(0);
//       _nhfCtrl.text = fd.deductionFor('NHF').toStringAsFixed(0);
//       _nhisCtrl.text = fd.deductionFor('NHIS').toStringAsFixed(0);
//       _pensionCtrl.text = fd.deductionFor('Pension').toStringAsFixed(0);
//       _loanCtrl.text = fd.deductionFor('Loan').toStringAsFixed(0);
//       _lifeCtrl.text = fd.deductionFor('Life Insurance').toStringAsFixed(0);
//     } else {
//       for (final c in [
//         _rentCtrl,
//         _nhfCtrl,
//         _nhisCtrl,
//         _pensionCtrl,
//         _loanCtrl,
//         _lifeCtrl,
//       ]) {
//         c.text = '0';
//       }
//     }
//   }

//   double _parseField(TextEditingController ctrl) =>
//       double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;

//   void _toggle(_Section section) => setState(() {
//     _expanded.contains(section)
//         ? _expanded.remove(section)
//         : _expanded.add(section);
//   });

//   Future<void> _recalculate(FilingHomeData filingData) async {
//     FocusScope.of(context).unfocus();
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

//   Future<void> _onProceed(
//     FilingHomeData? filingData,
//     TinValidationResult? tinResult,
//   ) async {
//     if (_isProceeding) return;
//     FocusScope.of(context).unfocus();
//     setState(() => _isProceeding = true);

//     try {
//       final tin = ref.read(filingTinProvider);
//       final plan = ref.read(selectedFilingPlanProvider);
//       final classification = ref.read(filingClassificationProvider);
//       final name = ref.read(filingNameProvider);
//       final cacNumber = ref.read(filingCacNumberProvider);
//       final contactRecord = ref.read(filingContactProvider);
//       final calcState = ref.read(taxCalculatorProvider);

//       // ── Use TIN-validated contact details when available ─────────────────────
//       String phoneNo = contactRecord.phoneNo;
//       String email = contactRecord.email;
//       String address = contactRecord.address;

//       if (tinResult != null) {
//         // Override with TIN result values if they exist and are non-empty
//         if (tinResult.phoneNumber?.isNotEmpty ?? false) {
//           phoneNo = tinResult.phoneNumber!;
//         } else if (tinResult.phoneNumber?.isNotEmpty ?? false) {
//           phoneNo = tinResult.phoneNumber!; // in case field name is phoneNo
//         }

//         if (tinResult.email?.isNotEmpty ?? false) {
//           email = tinResult.email!;
//         }

//         if (tinResult.address?.isNotEmpty ?? false) {
//           address = tinResult.address!;
//         } else if (tinResult.address?.isNotEmpty ?? false) {
//           address = tinResult.address!; // common alternative name
//         }
//         // Optional: combine fields if address is split
//         // address = '${tinResult.street ?? ''} ${tinResult.city ?? ''} ${tinResult.state ?? ''}'.trim();
//       }

//       // Debug print to confirm what will be sent
//       print(
//         'Final contact for API → Phone: $phoneNo | Email: $email | Address: $address',
//       );

//       final contact = FilingContactInfo(
//         phoneNo: phoneNo,
//         address: address,
//         email: email,
//       );

//       // ── Rest of your code remains unchanged ─────────────────────────────────
//       final revenues = filingData?.incomes ?? [];

//       final noneTaxable = [
//         FilingIncomeSource(source: 'Rent', amount: _parseField(_rentCtrl)),
//         FilingIncomeSource(
//           source: 'NHF Contribution',
//           amount: _parseField(_nhfCtrl),
//         ),
//         FilingIncomeSource(
//           source: 'NHIS Contribution',
//           amount: _parseField(_nhisCtrl),
//         ),
//         FilingIncomeSource(
//           source: 'Pension Contribution',
//           amount: _parseField(_pensionCtrl),
//         ),
//         FilingIncomeSource(
//           source: 'Interest on Loan for Owner Occupied House',
//           amount: _parseField(_loanCtrl),
//         ),
//         FilingIncomeSource(
//           source: 'Life Insurance Premium (You & Spouse)',
//           amount: _parseField(_lifeCtrl),
//         ),
//       ];

//       final cacNo;
//       if (tinResult!.cacRegNumber?.isNotEmpty ?? false) {
//         cacNo = tinResult!.cacRegNumber;
//       } else {
//         cacNo = tin;
//       }

//       final repo = ref.read(filingPaymentRepositoryProvider);
//       final result = await repo.initPayment(
//         plan: plan,
//         tin: tin,
//         classification: classification,
//         name: tinResult!.taxpayerName,
//         cacNumber: cacNo,
//         contact: contact,
//         revenues: revenues,
//         noneTaxableRevenues: noneTaxable,
//       );

//       final taxDue = result.financeDetails.taxAmount > 0
//           ? result.financeDetails.taxAmount
//           : (calcState.result?.finalTaxDue ?? filingData?.estimatedTax ?? 0.0);
//       // final taxDue = result.financeDetails.taxAmount;
//       // final double taxDue = calcState.result?.finalTaxDue ?? 0.0;
//       // final taxDue = filingData?.estimatedTax ?? 0.0;

//       print('Yayy hee');
//       print('TaxAmount: $result.financeDetails.taxAmount');
//       print('Final Tax Due: $calcState.result?.finalTaxDue');
//       print('Estimated Tax: $filingData?.estimatedTax');

//           final ID = result.id;

//       ref.read(filingTaxDueProvider.notifier).state = taxDue;
//       ref.read(filingIDProvider.notifier).state = ID;

//       if (mounted) {
//         setState(() => _isProceeding = false);
//         context.pushNamed(FilingRoutes.step4);
//       }
//     } catch (e) {
//       setState(() => _isProceeding = false);
//       if (mounted) {
//         AppNotification.show(
//           context,
//           message: e.toString().replaceFirst('Exception: ', ''),
//           icon: Icons.error_outline,
//           iconColor: Colors.redAccent,
//         );
//       }
//     }
//   }

//   // Future<void> _onProceed(
//   //   FilingHomeData? filingData,
//   //   TinValidationResult? tinResult,
//   // ) async {
//   //   if (_isProceeding) return;
//   //   FocusScope.of(context).unfocus();
//   //   setState(() => _isProceeding = true);
//   //   print(
//   //     'Email: $tinResult[email], Phone: $tinResult[phoneNumber], Address: $tinResult[address]',
//   //   );

//   //   try {
//   //     final tin = ref.read(filingTinProvider);
//   //     final plan = ref.read(selectedFilingPlanProvider);
//   //     final classification = ref.read(filingClassificationProvider);
//   //     final name = ref.read(filingNameProvider);
//   //     final cacNumber = ref.read(filingCacNumberProvider);
//   //     final contactRecord = ref.read(filingContactProvider);
//   //     final calcState = ref.read(taxCalculatorProvider);

//   //     // print('Contact Record: $contactRecord');

//   //     // Build income list from filing data
//   //     final revenues = filingData?.incomes ?? [];

//   //     // Build the 5 deduction items in exact API order
//   //     final noneTaxable = [
//   //       FilingIncomeSource(source: 'Rent', amount: _parseField(_rentCtrl)),
//   //       FilingIncomeSource(
//   //         source: 'NHF Contribution',
//   //         amount: _parseField(_nhfCtrl),
//   //       ),
//   //       FilingIncomeSource(
//   //         source: 'Pension Contribution',
//   //         amount: _parseField(_pensionCtrl),
//   //       ),
//   //       FilingIncomeSource(
//   //         source: 'Interest on Loan for Owner Occupied House',
//   //         amount: _parseField(_loanCtrl),
//   //       ),
//   //       FilingIncomeSource(
//   //         source: 'Life Insurance Premium (You & Spouse)',
//   //         amount: _parseField(_lifeCtrl),
//   //       ),
//   //     ];

//   //     final contact = FilingContactInfo(
//   //       phoneNo: contactRecord.phoneNo,
//   //       address: contactRecord.address,
//   //       email: contactRecord.email,
//   //     );

//   //     final repo = ref.read(filingPaymentRepositoryProvider);
//   //     final result = await repo.initPayment(
//   //       plan: plan,
//   //       tin: tin,
//   //       classification: classification,
//   //       name: name,
//   //       cacNumber: cacNumber,
//   //       contact: contact,
//   //       revenues: revenues,
//   //       noneTaxableRevenues: noneTaxable,
//   //     );

//   //     // Use the TaxAmount returned by the API as the authoritative figure
//   //     final taxDue = result.financeDetails.taxAmount > 0
//   //         ? result.financeDetails.taxAmount
//   //         : (calcState.result?.finalTaxDue ?? filingData?.estimatedTax ?? 0.0);

//   //     ref.read(filingTaxDueProvider.notifier).state = taxDue;

//   //     if (mounted) {
//   //       setState(() => _isProceeding = false);
//   //       context.pushNamed(FilingRoutes.step4);
//   //     }
//   //   } catch (e) {
//   //     setState(() => _isProceeding = false);
//   //     if (mounted) {
//   //       AppNotification.show(
//   //         context,
//   //         message: e.toString().replaceFirst('Exception: ', ''),
//   //         icon: Icons.error_outline,
//   //         iconColor: Colors.redAccent,
//   //       );
//   //     }
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final filingAsync = ref.watch(filingHomeProvider);
//     final profileAsync = ref.watch(homeDataProvider);
//     final selectedPlan = ref.watch(selectedFilingPlanProvider);
//     final calcState = ref.watch(taxCalculatorProvider);
//     final result = ref.watch(tinValidationResultProvider);

//     final filingData = filingAsync.value;
//     if (filingData != null) _initDeductions(filingData);

//     final taxYear = DateTime.now().year - 1;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           leading: const BackButton(),
//           title: const Text('Review Return'),
//           centerTitle: false,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//                 children: [
//                   const _StepBadge(label: 'STEP 3 OF 6 · REVIEW RETURN'),
//                   const Gap(16),
//                   Text(
//                     'Your pre-filled $taxYear return',
//                     style: const TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 24 * 0.02,
//                     ),
//                   ),
//                   const Gap(6),
//                   Text(
//                     'Everything is already filled in. Tap any section to expand and review.',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 13,
//                       color: AppColors.greyDark,
//                       letterSpacing: 13 * 0.02,
//                     ),
//                   ),
//                   const Gap(20),

//                   // ── Identity card ──────────────────────────────────
//                   profileAsync.when(
//                     data: (home) {
//                       final user = home.data;
//                       // print('user: $user');
//                       final initials = '${user.firstName[0]}${user.lastName[0]}'
//                           .toUpperCase();
//                       return _IdentityCard(
//                         initials: initials,
//                         fullName: '${user.firstName} ${user.lastName}',
//                         taxYear: taxYear,
//                       );
//                     },
//                     loading: () => const _IdentityCard(
//                       initials: '..',
//                       fullName: 'Loading...',
//                       taxYear: 0,
//                     ),
//                     error: (_, __) => const _IdentityCard(
//                       initials: '?',
//                       fullName: 'Unknown',
//                       taxYear: 0,
//                     ),
//                   ),
//                   const Gap(16),

//                   _CollapsibleSection(
//                     title: 'Personal Information',
//                     isExpanded: _expanded.contains(_Section.personalInfo),
//                     onToggle: () => _toggle(_Section.personalInfo),
//                     child: profileAsync.when(
//                       data: (home) {
//                         final user = home.data;
//                         return _PersonalInfoContent(
//                           fullName: '${user.firstName} ${user.lastName}',
//                           email: user.email,
//                           countryOfResidence: user.country,
//                           filingStatus: selectedPlan,
//                           taxYear: taxYear,
//                         );
//                       },
//                       loading: () =>
//                           const Center(child: CircularProgressIndicator()),
//                       error: (e, _) => Text('Could not load profile: $e'),
//                     ),
//                   ),
//                   const Gap(12),

//                   _CollapsibleSection(
//                     title: 'Income Summary',
//                     isExpanded: _expanded.contains(_Section.incomeSummary),
//                     onToggle: () => _toggle(_Section.incomeSummary),
//                     child: filingData != null
//                         ? _IncomeSummaryContent(incomes: filingData.incomes)
//                         : const Center(child: CircularProgressIndicator()),
//                   ),
//                   const Gap(12),

//                   _CollapsibleSection(
//                     title: 'Deductions & Reliefs',
//                     isExpanded: _expanded.contains(_Section.deductionsReliefs),
//                     onToggle: () => _toggle(_Section.deductionsReliefs),
//                     child: _DeductionsContent(
//                       rentCtrl: _rentCtrl,
//                       nhfCtrl: _nhfCtrl,
//                       nhisCtrl: _nhisCtrl,
//                       pensionCtrl: _pensionCtrl,
//                       loanCtrl: _loanCtrl,
//                       lifeCtrl: _lifeCtrl,
//                       isLoading: calcState.isLoading,
//                       onRecalculate: filingData != null
//                           ? () => _recalculate(filingData)
//                           : null,
//                       totalDeductions: calcState.result?.exemption ?? 0,
//                     ),
//                   ),
//                   const Gap(12),

//                   _CollapsibleSection(
//                     title: 'Tax Computation',
//                     isExpanded: _expanded.contains(_Section.taxComputation),
//                     onToggle: () => _toggle(_Section.taxComputation),
//                     child: filingData != null
//                         ? _TaxComputationContent(
//                             grossIncome: filingData.totalEarnings,
//                             calcResult: calcState.result,
//                             fallbackTaxableIncome: filingData.taxableIncome,
//                             fallbackStages: filingData.stages,
//                             fallbackEstimatedTax: filingData.estimatedTax,
//                           )
//                         : const Center(child: CircularProgressIndicator()),
//                   ),
//                   const Gap(16),

//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF0F4FF),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       spacing: 10,
//                       children: [
//                         const Icon(
//                           Icons.info_outline,
//                           size: 16,
//                           color: Colors.blueAccent,
//                         ),
//                         Expanded(
//                           child: Text(
//                             "Once you confirm this return, you'll be asked to complete your filing payment before we submit.",
//                             style: TextStyle(
//                               fontFamily: 'GeneralSans',
//                               fontSize: 12,
//                               color: Colors.blueAccent.shade700,
//                               letterSpacing: 12 * 0.02,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(24),
//                 ],
//               ),
//             ),
//             BottomActionButton(
//               label: _isProceeding
//                   ? 'Initialising…'
//                   : 'This looks right — proceed to payment',
//               onTap: _isProceeding
//                   ? null
//                   : () => _onProceed(filingData, result),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Section enum ──────────────────────────────────────────────────────────────

// enum _Section { personalInfo, incomeSummary, deductionsReliefs, taxComputation }

// // ── Widgets (unchanged from previous version) ─────────────────────────────────

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
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       border: Border.all(color: AppColors.borderLight),
//       borderRadius: BorderRadius.circular(14),
//     ),
//     child: Row(
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: const BoxDecoration(
//             color: Color(0xFF1A1A1A),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Text(
//               initials,
//               style: const TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             fullName,
//             style: const TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 14 * 0.02,
//             ),
//           ),
//         ),
//         if (taxYear > 0)
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5C842).withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(50),
//               border: Border.all(
//                 color: const Color(0xFFF5C842).withValues(alpha: 0.4),
//               ),
//             ),
//             child: Text(
//               '$taxYear Return',
//               style: const TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 11 * 0.02,
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
// }

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
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       border: Border.all(color: AppColors.borderLight),
//       borderRadius: BorderRadius.circular(14),
//     ),
//     child: Column(
//       children: [
//         InkWell(
//           borderRadius: BorderRadius.circular(14),
//           onTap: onToggle,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: const TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 14 * 0.02,
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   isExpanded
//                       ? Icons.keyboard_arrow_up
//                       : Icons.keyboard_arrow_down,
//                   color: AppColors.grey,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         AnimatedCrossFade(
//           duration: const Duration(milliseconds: 250),
//           crossFadeState: isExpanded
//               ? CrossFadeState.showSecond
//               : CrossFadeState.showFirst,
//           firstChild: const SizedBox.shrink(),
//           secondChild: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
//             child: child,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _AutoFilledTag extends StatelessWidget {
//   const _AutoFilledTag();
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//     decoration: BoxDecoration(
//       color: const Color(0xFFE0F2F1),
//       borderRadius: BorderRadius.circular(50),
//       border: Border.all(color: const Color(0xFF80CBC4)),
//     ),
//     child: const Text(
//       'C AUTO-FILLED',
//       style: TextStyle(
//         fontFamily: 'GeneralSans',
//         fontSize: 9,
//         fontWeight: FontWeight.w600,
//         color: Color(0xFF00796B),
//         letterSpacing: 9 * 0.02,
//       ),
//     ),
//   );
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
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (showTag) ...[const _AutoFilledTag(), const Gap(3)],
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontFamily: 'GeneralSans',
//                   fontSize: 13,
//                   color: AppColors.greyDark,
//                   letterSpacing: 13 * 0.02,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontFamily: 'GeneralSans',
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: isNegative ? Colors.red.shade700 : Colors.black87,
//             letterSpacing: 13 * 0.02,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _EditableDeductionRow extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   const _EditableDeductionRow({required this.label, required this.controller});

//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 12),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               color: AppColors.greyDark,
//               letterSpacing: 13 * 0.02,
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         SizedBox(
//           width: 130,
//           height: 38,
//           child: TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             textAlign: TextAlign.right,
//             style: const TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//             decoration: InputDecoration(
//               prefixText: '₦ ',
//               prefixStyle: TextStyle(
//                 fontFamily: 'GeneralSans',
//                 fontSize: 13,
//                 color: AppColors.greyDark,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 10,
//                 vertical: 8,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: AppColors.borderLight),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: AppColors.borderLight),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(
//                   color: Color(0xFFF5C842),
//                   width: 1.5,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _SectionDivider extends StatelessWidget {
//   const _SectionDivider();
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Divider(color: AppColors.borderLight, height: 1),
//   );
// }

// class _PersonalInfoContent extends StatelessWidget {
//   final String fullName, email, countryOfResidence, filingStatus;
//   final int taxYear;
//   const _PersonalInfoContent({
//     required this.fullName,
//     required this.email,
//     required this.countryOfResidence,
//     required this.filingStatus,
//     required this.taxYear,
//   });
//   @override
//   Widget build(BuildContext context) => Column(
//     children: [
//       _InfoRow(label: 'Full Name', value: fullName, showTag: true),
//       _InfoRow(label: 'Email', value: email, showTag: true),
//       _InfoRow(
//         label: 'Country of Residence',
//         value: countryOfResidence,
//         showTag: true,
//       ),
//       _InfoRow(label: 'Filing Status', value: filingStatus, showTag: true),
//       _InfoRow(label: 'Tax Year', value: 'January – December $taxYear'),
//     ],
//   );
// }

// class _IncomeSummaryContent extends StatelessWidget {
//   final List<FilingIncomeSource> incomes;
//   const _IncomeSummaryContent({required this.incomes});
//   @override
//   Widget build(BuildContext context) {
//     final total = incomes.fold(0.0, (s, i) => s + i.amount);
//     return Column(
//       children: [
//         ...incomes.map(
//           (i) => _InfoRow(
//             label: i.source,
//             value: i.amount.formatCurrency(decimalDigits: 0),
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
//   final TextEditingController rentCtrl,
//       nhfCtrl,
//       nhisCtrl,
//       pensionCtrl,
//       loanCtrl,
//       lifeCtrl;
//   final bool isLoading;
//   final VoidCallback? onRecalculate;
//   final double totalDeductions;
//   static const _yellow = Color(0xFFF5C842);
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

//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _EditableDeductionRow(label: 'Annual Rent Paid', controller: rentCtrl),
//       _EditableDeductionRow(
//         label: 'NHF Contribution (Annual)',
//         controller: nhfCtrl,
//       ),
//       _EditableDeductionRow(label: 'NHIS Contribution', controller: nhisCtrl),
//       _EditableDeductionRow(
//         label: 'Pension Contribution',
//         controller: pensionCtrl,
//       ),
//       _EditableDeductionRow(
//         label: 'Interest on Loan (Owner Occupied)',
//         controller: loanCtrl,
//       ),
//       _EditableDeductionRow(
//         label: 'Life Insurance Premium (You & Spouse)',
//         controller: lifeCtrl,
//       ),
//       const Gap(4),
//       SizedBox(
//         width: double.infinity,
//         child: OutlinedButton.icon(
//           onPressed: isLoading ? null : onRecalculate,
//           style: OutlinedButton.styleFrom(
//             side: const BorderSide(color: _yellow, width: 1.5),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             backgroundColor: _yellow.withValues(alpha: 0.05),
//           ),
//           icon: isLoading
//               ? const SizedBox(
//                   width: 14,
//                   height: 14,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.black54,
//                   ),
//                 )
//               : const Icon(
//                   Icons.calculate_outlined,
//                   size: 16,
//                   color: Colors.black87,
//                 ),
//           label: Text(
//             isLoading ? 'Recalculating…' : 'Recalculate Tax',
//             style: const TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//               letterSpacing: 13 * 0.02,
//             ),
//           ),
//         ),
//       ),
//       const Gap(12),
//       const _SectionDivider(),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Total Deductions',
//             style: TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               color: AppColors.greyDark,
//               letterSpacing: 13 * 0.02,
//             ),
//           ),
//           Text(
//             totalDeductions > 0
//                 ? '-${totalDeductions.formatCurrency(decimalDigits: 0)}'
//                 : '₦0',
//             style: TextStyle(
//               fontFamily: 'GeneralSans',
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: totalDeductions > 0 ? Colors.red.shade700 : Colors.black87,
//               letterSpacing: 13 * 0.02,
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }

// class _TaxComputationContent extends StatelessWidget {
//   final double grossIncome;
//   final TaxCalculatorResult? calcResult;
//   final double fallbackTaxableIncome, fallbackEstimatedTax;
//   final FilingStages fallbackStages;
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
//     final stageLabels = [
//       'First ₦800,000 @ 0%',
//       'Next ₦2,200,000 @ 15%',
//       'Next ₦9,000,000 @ 18%',
//       'Next ₦13,000,000 @ 21%',
//       'Next ₦25,000,000 @ 23%',
//       'Next ₦50,000,000 @ 25%',
//     ];
//     List<MapEntry<String, double>> stageEntries;
//     if (calcResult != null) {
//       stageEntries = calcResult!.stages.nonZeroEntries;
//     } else {
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
//           if (vals[i] != 0) MapEntry(stageLabels[i], vals[i]),
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

// class _StepBadge extends StatelessWidget {
//   final String label;
//   const _StepBadge({required this.label});
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       Container(
//         width: 8,
//         height: 8,
//         decoration: const BoxDecoration(
//           color: Color(0xFFF5C842),
//           shape: BoxShape.circle,
//         ),
//       ),
//       const SizedBox(width: 6),
//       Text(
//         label,
//         style: const TextStyle(
//           fontFamily: 'GeneralSans',
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//           letterSpacing: 11 * 0.02,
//         ),
//       ),
//     ],
//   );
// }
