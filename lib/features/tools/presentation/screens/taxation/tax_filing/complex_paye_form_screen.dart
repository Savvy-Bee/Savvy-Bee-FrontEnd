// lib/features/tools/presentation/screens/taxation/tax_filing/complex_paye_form_screen.dart
//
// Pro/Complex PAYE filing form.
// Pre-fills TIN, Classification, Name, CACNumber, Contact from existing
// Riverpod providers so the user does not need to re-enter data they
// already submitted during TIN registration / validation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/complex_paye_models.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/complex_paye_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';

class ComplexPayeFormScreen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.complexPayeForm;

  const ComplexPayeFormScreen({super.key});

  @override
  ConsumerState<ComplexPayeFormScreen> createState() =>
      _ComplexPayeFormScreenState();
}

class _ComplexPayeFormScreenState extends ConsumerState<ComplexPayeFormScreen> {
  static const _yellow = Color(0xFFF5C842);

  final _formKey = GlobalKey<FormState>();

  // ── Controllers ─────────────────────────────────────────────────────────────
  final _businessNameCtrl = TextEditingController();
  final _tinCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _classificationCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _cacCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // ── Dynamic revenue rows ─────────────────────────────────────────────────
  final List<_IncomeRow> _revenues = [_IncomeRow()];

  // ── Fixed non-taxable fields (predefined by law) ─────────────────────────
  static const _nonTaxableLabels = [
    'Rent',
    'NHF Contribution',
    'Interest on Loan for Owner Occupied House',
    'Life Insurance Premium (You & Spouse)',
  ];
  late final List<TextEditingController> _nonTaxableAmounts;

  bool _isSubmitting = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _nonTaxableAmounts =
        List.generate(_nonTaxableLabels.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _tinCtrl.dispose();
    _descriptionCtrl.dispose();
    _classificationCtrl.dispose();
    _nameCtrl.dispose();
    _cacCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    for (final r in _revenues) {
      r.dispose();
    }
    for (final c in _nonTaxableAmounts) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefillFromProviders() {
    if (_prefilled) return;
    _prefilled = true;

    _tinCtrl.text = ref.read(filingTinProvider);
    _classificationCtrl.text = ref.read(filingClassificationProvider);
    _nameCtrl.text = ref.read(filingNameProvider);
    _cacCtrl.text = ref.read(filingCacNumberProvider);

    final contact = ref.read(filingContactProvider);
    _phoneCtrl.text = contact.phoneNo;
    _addressCtrl.text = contact.address;
    _emailCtrl.text = contact.email;
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    final revenues = _revenues
        .where((r) => r.source.text.trim().isNotEmpty)
        .map(
          (r) => ComplexPayeIncomeSource(
            source: r.source.text.trim(),
            amount: double.tryParse(r.amount.text.trim()) ?? 0,
          ),
        )
        .toList();

    // Collect only non-taxable rows that have an amount entered
    final noneTaxable = <ComplexPayeIncomeSource>[];
    for (int i = 0; i < _nonTaxableLabels.length; i++) {
      final amt = double.tryParse(_nonTaxableAmounts[i].text.trim()) ?? 0;
      if (amt > 0) {
        noneTaxable.add(
          ComplexPayeIncomeSource(source: _nonTaxableLabels[i], amount: amt),
        );
      }
    }

    if (revenues.isEmpty) {
      AppNotification.show(
        context,
        message: 'Add at least one revenue source.',
        backgroundColor: Colors.red,
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(complexPayeRepositoryProvider);
      final id = await repo.submitFiling(
        businessName: _businessNameCtrl.text.trim(),
        tin: _tinCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        classification: _classificationCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        cacNumber: _cacCtrl.text.trim(),
        phoneNo: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        revenues: revenues,
        noneTaxableRevenues: noneTaxable,
      );

      if (!mounted) return;
      AppNotification.show(
        context,
        message: 'Filing submitted! A consultant will review shortly.',
        icon: Icons.check_circle_outline,
      );

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      // Invalidate history so the new record appears
      ref.invalidate(complexPayeHistoryProvider);

      // Navigate to details (direct path avoids `:id` name-lookup issues)
      if (id.isNotEmpty) {
        context.push('/filing/complex-paye/$id');
      } else {
        context.pushNamed(FilingRoutes.complexPayeHistory);
      }
    } catch (e) {
      if (!mounted) return;
      AppNotification.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        icon: Icons.error_outline,
        iconColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _prefillFromProviders();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Pro / Complex Filing'),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  children: [
                    _SectionHeader(label: 'Business Details'),
                    const Gap(12),
                    _field(
                      ctrl: _businessNameCtrl,
                      label: 'Business Name',
                      hint: 'e.g. Savvy Holdings Ltd',
                      validator: _required,
                    ),
                    const Gap(12),
                    _field(
                      ctrl: _tinCtrl,
                      label: 'TIN',
                      hint: '12345678-0001',
                      readOnly: true,
                    ),
                    const Gap(12),
                    _field(
                      ctrl: _classificationCtrl,
                      label: 'Classification',
                      hint: 'Individual / Coperate',
                      readOnly: true,
                    ),
                    const Gap(12),
                    _field(
                      ctrl: _nameCtrl,
                      label: 'Name',
                      hint: 'Full legal / business name',
                    ),
                    const Gap(12),
                    _field(
                      ctrl: _cacCtrl,
                      label: 'CAC Number',
                      hint: 'RC-1234567 (leave blank for individuals)',
                    ),
                    const Gap(12),
                    _field(
                      ctrl: _descriptionCtrl,
                      label: 'Description',
                      hint: 'Brief description of your filing',
                      maxLines: 3,
                      validator: _required,
                    ),
                    const Gap(20),
                    _SectionHeader(label: 'Contact'),
                    const Gap(12),
                    _field(
                      ctrl: _phoneCtrl,
                      label: 'Phone',
                      hint: '+2348012345678',
                      keyboardType: TextInputType.phone,
                    ),
                    const Gap(12),
                    _field(
                      ctrl: _emailCtrl,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Gap(12),
                    _field(
                      ctrl: _addressCtrl,
                      label: 'Address',
                      hint: '12 Main St, Lagos',
                      maxLines: 2,
                    ),
                    const Gap(20),
                    _SectionHeader(label: 'Revenue Sources'),
                    const Gap(4),
                    Text(
                      'Add each income source and its annual amount (₦).',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const Gap(12),
                    ..._buildIncomeRows(_revenues, isRevenue: true),
                    _AddRowButton(
                      label: '+ Add Revenue',
                      onTap: () => setState(() => _revenues.add(_IncomeRow())),
                    ),
                    const Gap(20),
                    _SectionHeader(label: 'Non-Taxable Revenues'),
                    const Gap(4),
                    Text(
                      'Enter amounts that apply (leave blank to skip).',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const Gap(12),
                    ..._buildFixedNonTaxableRows(),
                    const Gap(24),
                  ],
                ),
              ),
            ),
            BottomActionButton(
              label: 'Submit Filing',
              isLoading: _isSubmitting,
              onTap: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Renders the 4 fixed non-taxable rows — label is read-only, only amount is editable.
  List<Widget> _buildFixedNonTaxableRows() {
    return List.generate(_nonTaxableLabels.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.greyLight.withValues(alpha: 0.5),
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _nonTaxableLabels[i],
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    color: AppColors.greyDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _smallField(
                ctrl: _nonTaxableAmounts[i],
                hint: 'Amount',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildIncomeRows(
    List<_IncomeRow> rows, {
    required bool isRevenue,
  }) {
    return List.generate(rows.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _smallField(
                ctrl: rows[i].source,
                hint: isRevenue ? 'Source (e.g. Salary)' : 'Item (e.g. Housing)',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _smallField(
                ctrl: rows[i].amount,
                hint: 'Amount',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              ),
            ),
            const SizedBox(width: 4),
            if (rows.length > 1)
              GestureDetector(
                onTap: () {
                  rows[i].dispose();
                  setState(() => rows.removeAt(i));
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(Icons.close, size: 18, color: Colors.red),
                ),
              )
            else
              const SizedBox(width: 22),
          ],
        ),
      );
    });
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    String? hint,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: readOnly,
        fillColor: readOnly ? AppColors.greyLight.withValues(alpha: 0.5) : null,
        labelStyle: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 13,
          color: AppColors.greyDark,
        ),
        hintStyle: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 13,
          color: AppColors.greyDark.withValues(alpha: 0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _yellow, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _smallField({
    required TextEditingController ctrl,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 12,
          color: AppColors.greyDark.withValues(alpha: 0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _yellow, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

// ── Income row model ──────────────────────────────────────────────────────────

class _IncomeRow {
  final source = TextEditingController();
  final amount = TextEditingController();
  void dispose() {
    source.dispose();
    amount.dispose();
  }
}

// ── Reusable small widgets ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 16 * 0.02,
      ),
    );
  }
}

class _AddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddRowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFF5C842).withValues(alpha: 0.7),
          ),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF5C842).withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: Color(0xFFF5C842)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF5C842),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
