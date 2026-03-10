// lib/features/tools/presentation/screens/taxation/filing/tin_reg_screens.dart
//
// TIN Registration — Screens 2-5 for Personal and Business paths.
//
// Personal flow:
//   TinRegPersonalScreen2 → TinRegPersonalScreen3 → TinRegPersonalScreen4
//   → TinRegPersonalScreen5 → FilingRoutes.tinSubmitted
//
// Business flow:
//   TinRegBusinessScreen2 → TinRegBusinessScreen3 → TinRegBusinessScreen4
//   → TinRegBusinessScreen5 → FilingRoutes.tinSubmitted
//
// Screen 3 (TIN & Contact), Screen 4 (Filing Details) and Screen 5 (OTP)
// are shared implementations parametrised by path/nextRoute.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';

// ═════════════════════════════════════════════════════════════════════════════
// PERSONAL — SCREEN 2: Personal Identity
// ═════════════════════════════════════════════════════════════════════════════

class TinRegPersonalScreen2 extends StatefulWidget {
  static const String path = FilingRoutes.tinRegPersonal2;
  const TinRegPersonalScreen2({super.key});

  @override
  State<TinRegPersonalScreen2> createState() => _TinRegPersonalScreen2State();
}

class _TinRegPersonalScreen2State extends State<TinRegPersonalScreen2> {
  final _nameCtrl = TextEditingController();
  final _bvnCtrl = TextEditingController();
  final _ninCtrl = TextEditingController();

  bool get _canContinue =>
      _nameCtrl.text.trim().isNotEmpty &&
      _bvnCtrl.text.length == 11 &&
      _ninCtrl.text.length == 11;

  @override
  void initState() {
    super.initState();
    for (final c in [_nameCtrl, _bvnCtrl, _ninCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bvnCtrl.dispose();
    _ninCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _RegAppBar(step: 2, total: 5),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  children: [
                    const _StepBadge(
                      label: 'STEP 2 OF 5 · IDENTITY INFORMATION',
                    ),
                    const Gap(20),
                    Text(
                      'Personal identity',
                      style: _gs(26, weight: FontWeight.w700),
                    ),
                    const Gap(6),
                    Text(
                      'Required by NRS — must match your BVN record.',
                      style: _gs(13, color: AppColors.greyDark),
                    ),
                    const Gap(28),

                    // Full Legal Name
                    const _FieldLabel(label: 'FULL LEGAL NAME'),
                    const Gap(6),
                    _InputField(
                      controller: _nameCtrl,
                      hint: 'As it appears on your NIN',
                    ),
                    const Gap(16),

                    // BVN + NIN
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(label: 'BVN'),
                              const Gap(6),
                              _InputField(
                                controller: _bvnCtrl,
                                hint: '11 digits',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                '${_bvnCtrl.text.length}/11',
                                style: _gs(11, color: const Color(0xFFAAAAAA)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(label: 'NIN'),
                              const Gap(6),
                              _InputField(
                                controller: _ninCtrl,
                                hint: '11 digits',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                '${_ninCtrl.text.length}/11',
                                style: _gs(11, color: const Color(0xFFAAAAAA)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),

                    // Security note
                    _InfoNote(
                      icon: Icons.lock_outline,
                      color: const Color(0xFF856404),
                      bg: const Color(0xFFFFF8E1),
                      border: const Color(0xFFFFE082),
                      text:
                          'Your BVN and NIN are verified securely against NIBSS '
                          'and NIMC records. They are never stored in plain text.',
                    ),
                    const Gap(24),
                  ],
                ),
              ),
              _BottomButton(
                label: 'Continue',
                enabled: _canContinue,
                onTap: () => context.pushNamed(FilingRoutes.tinRegPersonal3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BUSINESS — SCREEN 2: Business Identity
// ═════════════════════════════════════════════════════════════════════════════

class TinRegBusinessScreen2 extends StatefulWidget {
  static const String path = FilingRoutes.tinRegBusiness2;
  const TinRegBusinessScreen2({super.key});

  @override
  State<TinRegBusinessScreen2> createState() => _TinRegBusinessScreen2State();
}

class _TinRegBusinessScreen2State extends State<TinRegBusinessScreen2> {
  final _bizNameCtrl = TextEditingController();
  final _rcNumberCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  bool get _canContinue =>
      _bizNameCtrl.text.trim().isNotEmpty &&
      _rcNumberCtrl.text.trim().isNotEmpty &&
      _dateCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    for (final c in [_bizNameCtrl, _rcNumberCtrl, _dateCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _bizNameCtrl.dispose();
    _rcNumberCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _RegAppBar(step: 2, total: 5),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  children: [
                    const _StepBadge(
                      label: 'STEP 2 OF 5 · IDENTITY INFORMATION',
                    ),
                    const Gap(20),
                    Text(
                      'Business identity',
                      style: _gs(26, weight: FontWeight.w700),
                    ),
                    const Gap(6),
                    Text(
                      'Enter your registered business details as on CAC records.',
                      style: _gs(13, color: AppColors.greyDark),
                    ),
                    const Gap(28),

                    const _FieldLabel(label: 'REGISTERED BUSINESS NAME'),
                    const Gap(6),
                    _InputField(
                      controller: _bizNameCtrl,
                      hint: 'As registered with CAC',
                    ),
                    const Gap(16),

                    const _FieldLabel(label: 'RC NUMBER (CAC)'),
                    const Gap(6),
                    _InputField(
                      controller: _rcNumberCtrl,
                      hint: 'e.g. RC-1234567',
                    ),
                    const Gap(16),

                    const _FieldLabel(label: 'BUSINESS COMMENCEMENT DATE'),
                    const Gap(6),
                    _InputField(
                      controller: _dateCtrl,
                      hint: 'dd/mm/yyyy',
                      keyboardType: TextInputType.datetime,
                    ),
                    const Gap(16),

                    _InfoNote(
                      icon: Icons.verified_outlined,
                      color: const Color(0xFF1565C0),
                      bg: const Color(0xFFF0F4FF),
                      border: const Color(0xFFBBCEFF),
                      text:
                          'RC Number is verified against the CAC portal. Ensure it '
                          'matches your Certificate of Incorporation exactly.',
                    ),
                    const Gap(24),
                  ],
                ),
              ),
              _BottomButton(
                label: 'Continue',
                enabled: _canContinue,
                onTap: () => context.pushNamed(FilingRoutes.tinRegBusiness3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 3: TIN & Contact Details  (Personal + Business variants)
// ═════════════════════════════════════════════════════════════════════════════

class TinRegPersonalScreen3 extends StatelessWidget {
  static const String path = FilingRoutes.tinRegPersonal3;
  const TinRegPersonalScreen3({super.key});

  @override
  Widget build(BuildContext context) => _ContactScreen(
    step: 3,
    nextRoute: FilingRoutes.tinRegPersonal4,
    addressLabel: 'RESIDENTIAL ADDRESS',
  );
}

class TinRegBusinessScreen3 extends StatelessWidget {
  static const String path = FilingRoutes.tinRegBusiness3;
  const TinRegBusinessScreen3({super.key});

  @override
  Widget build(BuildContext context) => _ContactScreen(
    step: 3,
    nextRoute: FilingRoutes.tinRegBusiness4,
    addressLabel: 'REGISTERED BUSINESS ADDRESS',
  );
}

class _ContactScreen extends StatefulWidget {
  final int step;
  final String nextRoute;
  final String addressLabel;
  const _ContactScreen({
    required this.step,
    required this.nextRoute,
    required this.addressLabel,
  });

  @override
  State<_ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<_ContactScreen> {
  final _tinCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _lgaCtrl = TextEditingController();
  String? _selectedState;

  static const _states = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'FCT',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  bool get _canContinue =>
      _phoneCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _addressCtrl.text.trim().isNotEmpty &&
      _selectedState != null &&
      _lgaCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _tinCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _lgaCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _tinCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _lgaCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _RegAppBar(step: widget.step, total: 5),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  children: [
                    const _StepBadge(
                      label: 'STEP 3 OF 5 · TIN & CONTACT DETAILS',
                    ),
                    const Gap(20),
                    Text(
                      'TIN & contact details',
                      style: _gs(26, weight: FontWeight.w700),
                    ),
                    const Gap(6),
                    Text(
                      'Your TIN (if known), contact info and address.',
                      style: _gs(13, color: AppColors.greyDark),
                    ),
                    const Gap(24),

                    // TIN (optional)
                    const _FieldLabel(label: 'TIN (if already issued)'),
                    const Gap(6),
                    _InputField(
                      controller: _tinCtrl,
                      hint: '10-digit TIN — leave blank if new',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                    ),
                    const Gap(16),

                    const _FieldLabel(label: 'PHONE NUMBER'),
                    const Gap(6),
                    _InputField(
                      controller: _phoneCtrl,
                      hint: '+234 800 000 0000',
                      keyboardType: TextInputType.phone,
                    ),
                    const Gap(16),

                    const _FieldLabel(label: 'EMAIL ADDRESS'),
                    const Gap(6),
                    _InputField(
                      controller: _emailCtrl,
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Gap(16),

                    _FieldLabel(label: widget.addressLabel),
                    const Gap(6),
                    _InputField(
                      controller: _addressCtrl,
                      hint: 'House/building number, street, area',
                    ),
                    const Gap(16),

                    // State + LGA row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(label: 'STATE'),
                              const Gap(6),
                              _DropdownField(
                                value: _selectedState,
                                hint: 'Select',
                                items: _states,
                                onChanged: (v) =>
                                    setState(() => _selectedState = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(label: 'LGA'),
                              const Gap(6),
                              _InputField(
                                controller: _lgaCtrl,
                                hint: 'e.g. Ikeja',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                  ],
                ),
              ),
              _BottomButton(
                label: 'Continue',
                enabled: _canContinue,
                onTap: () => context.pushNamed(widget.nextRoute),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 4: Filing Details  (Personal + Business variants)
// ═════════════════════════════════════════════════════════════════════════════

class TinRegPersonalScreen4 extends StatelessWidget {
  static const String path = FilingRoutes.tinRegPersonal4;
  const TinRegPersonalScreen4({super.key});

  @override
  Widget build(BuildContext context) =>
      _FilingDetailsScreen(nextRoute: FilingRoutes.tinRegPersonal5);
}

class TinRegBusinessScreen4 extends StatelessWidget {
  static const String path = FilingRoutes.tinRegBusiness4;
  const TinRegBusinessScreen4({super.key});

  @override
  Widget build(BuildContext context) =>
      _FilingDetailsScreen(nextRoute: FilingRoutes.tinRegBusiness5);
}

class _FilingDetailsScreen extends StatefulWidget {
  final String nextRoute;
  const _FilingDetailsScreen({required this.nextRoute});

  @override
  State<_FilingDetailsScreen> createState() => _FilingDetailsScreenState();
}

class _FilingDetailsScreenState extends State<_FilingDetailsScreen> {
  String? _selectedCategory;
  int _selectedYear = DateTime.now().year;
  // null = not picked | true = No (first time) | false = Yes (returning)
  bool? _filedBefore;
  String? _mostRecentYear;

  static const _yellow = Color(0xFFF5C842);

  static const _categories = [
    ('Basic Salary Earner', 'Fixed salary from one employer'),
    ('Freelancer', 'Multiple clients or contract jobs'),
    ('Self-Employed Professional', 'Lawyer, doctor, consultant'),
    ('Business Owner / Corporate', 'Registered SME or company'),
  ];

  static final _assessmentYears = List.generate(
    5,
    (i) => DateTime.now().year - i,
  );
  static const _recentYears = ['2025', '2024', '2023', '2022', '2021'];

  bool get _canSendOtp {
    if (_selectedCategory == null || _filedBefore == null) return false;
    if (_filedBefore == false && _mostRecentYear == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _RegAppBar(step: 4, total: 5),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  children: [
                    const _StepBadge(label: 'STEP 4 OF 5 · FILING DETAILS'),
                    const Gap(20),
                    Text(
                      'Filing details',
                      style: _gs(26, weight: FontWeight.w700),
                    ),
                    const Gap(6),
                    Text(
                      'Tell us about your filing history and the tax year you are filing for.',
                      style: _gs(13, color: AppColors.greyDark),
                    ),
                    const Gap(24),

                    // ── Filing Category ───────────────────────────────────
                    const _FieldLabel(label: 'FILING CATEGORY'),
                    const Gap(10),
                    ..._categories.map(
                      (cat) => _CategoryTile(
                        title: cat.$1,
                        subtitle: cat.$2,
                        isSelected: _selectedCategory == cat.$1,
                        onTap: () => setState(() => _selectedCategory = cat.$1),
                      ),
                    ),
                    const Gap(20),

                    // ── Assessment Year ───────────────────────────────────
                    const _FieldLabel(label: 'ASSESSMENT YEAR'),
                    const Gap(12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _assessmentYears.map((year) {
                        final selected = _selectedYear == year;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedYear = year),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              vertical: 9,
                              horizontal: 18,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? _yellow : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: selected
                                    ? _yellow
                                    : const Color(0xFFE5E5E5),
                              ),
                            ),
                            child: Text(
                              '$year',
                              style: _gs(
                                14,
                                weight: FontWeight.w600,
                                color: selected ? Colors.black : Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(24),

                    // ── Have You Filed Taxes Before? ──────────────────────
                    const _FieldLabel(label: 'HAVE YOU FILED TAXES BEFORE?'),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: _FiledBeforeTile(
                            iconWidget: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fiber_new_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            label: 'No — first time',
                            isSelected: _filedBefore == true,
                            onTap: () => setState(() {
                              _filedBefore = true;
                              _mostRecentYear = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FiledBeforeTile(
                            iconWidget: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.autorenew,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                            label: 'Yes — returning',
                            isSelected: _filedBefore == false,
                            onTap: () => setState(() => _filedBefore = false),
                          ),
                        ),
                      ],
                    ),

                    // ── Most Recent Year Filed (only for "Yes — returning") ─
                    if (_filedBefore == false) ...[
                      const Gap(20),
                      const _FieldLabel(label: 'MOST RECENT YEAR FILED'),
                      const Gap(10),
                      _DropdownField(
                        value: _mostRecentYear,
                        hint: '2021',
                        items: _recentYears,
                        onChanged: (v) => setState(() => _mostRecentYear = v),
                      ),
                    ],
                    const Gap(24),
                  ],
                ),
              ),

              // ── Send OTP & continue ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSendOtp
                        ? () => context.pushNamed(widget.nextRoute)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellow,
                      disabledBackgroundColor: _yellow.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Send OTP & continue',
                          style: _gs(
                            15,
                            weight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.black,
                        ),
                      ],
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

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 5: OTP Verification + Registration Summary
// ═════════════════════════════════════════════════════════════════════════════

class TinRegPersonalScreen5 extends StatelessWidget {
  static const String path = FilingRoutes.tinRegPersonal5;
  const TinRegPersonalScreen5({super.key});

  @override
  Widget build(BuildContext context) =>
      const _OtpScreen(registrationType: 'Individual');
}

class TinRegBusinessScreen5 extends StatelessWidget {
  static const String path = FilingRoutes.tinRegBusiness5;
  const TinRegBusinessScreen5({super.key});

  @override
  Widget build(BuildContext context) =>
      const _OtpScreen(registrationType: 'Corporate');
}

class _OtpScreen extends StatefulWidget {
  final String registrationType;
  const _OtpScreen({required this.registrationType});

  @override
  State<_OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<_OtpScreen> {
  final List<TextEditingController> _ctrlList = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusList = List.generate(6, (_) => FocusNode());

  bool _isSubmitting = false;

  static const _yellow = Color(0xFFF5C842);

  String get _otp => _ctrlList.map((c) => c.text).join();
  bool get _otpComplete => _otp.length == 6;

  @override
  void initState() {
    super.initState();
    for (final c in _ctrlList) c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in _ctrlList) c.dispose();
    for (final f in _focusList) f.dispose();
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 5) _focusList[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusList[index - 1].requestFocus();
    setState(() {});
  }

  Future<void> _onComplete() async {
    if (!_otpComplete) return;
    setState(() => _isSubmitting = true);
    // TODO: replace with real OTP verification API call
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isSubmitting = false);
      context.pushNamed(FilingRoutes.tinSubmitted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _RegAppBar(step: 5, total: 5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            const _StepBadge(label: 'STEP 5 OF 5 · OTP VERIFICATION'),
            const Gap(20),

            Text('Verify your number', style: _gs(26, weight: FontWeight.w700)),
            const Gap(6),
            RichText(
              text: TextSpan(
                style: _gs(13, color: AppColors.greyDark),
                children: const [
                  TextSpan(text: 'Enter the 6-digit code sent to '),
                  TextSpan(
                    text: '••••••••••••••••••',
                    style: TextStyle(letterSpacing: 2),
                  ),
                ],
              ),
            ),
            const Gap(28),

            // ── OTP boxes ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => _OtpBox(
                  controller: _ctrlList[i],
                  focusNode: _focusList[i],
                  onChanged: (v) => _onDigitEntered(i, v),
                ),
              ),
            ),
            const Gap(16),

            Row(
              children: [
                Text(
                  'Code sent to ••••••••••••',
                  style: _gs(12, color: AppColors.greyDark),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {}, // TODO: resend OTP
                  child: Row(
                    children: [
                      const Icon(
                        Icons.refresh,
                        size: 13,
                        color: Color(0xFFF5C842),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Resend OTP',
                        style: _gs(
                          12,
                          weight: FontWeight.w600,
                          color: const Color(0xFFF5C842),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),

            // ── Two-channel note ──────────────────────────────────────────
            _InfoNote(
              icon: Icons.lock_outline,
              color: const Color(0xFF1565C0),
              bg: const Color(0xFFF0F4FF),
              border: const Color(0xFFBBCEFF),
              text:
                  'An OTP was sent to both your phone and email. '
                  'Enter either code to complete registration.',
              title: 'Two-channel verification',
            ),
            const Gap(20),

            // ── Registration summary ──────────────────────────────────────
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
                  Text(
                    'REGISTRATION SUMMARY',
                    style: _gs(
                      11,
                      weight: FontWeight.w600,
                      color: Colors.white60,
                    ),
                  ),
                  const Gap(14),
                  _SummaryRow(label: 'Name', value: '—'),
                  _SummaryRow(label: 'Type', value: widget.registrationType),
                  _SummaryRow(label: 'Contact', value: '—'),
                  _SummaryRow(label: 'Category', value: '—'),
                  _SummaryRow(label: 'Assessment year', value: '—'),
                  _SummaryRow(label: 'State', value: '—'),
                ],
              ),
            ),
            const Gap(24),

            // ── Complete registration button ───────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _otpComplete && !_isSubmitting ? _onComplete : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  disabledBackgroundColor: _yellow.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'Complete registration',
                        style: _gs(
                          15,
                          weight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            const Gap(12),

            Center(
              child: Text(
                'TIN issuance typically takes 24–72 hours after verification',
                style: _gs(11, color: AppColors.greyDark),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SHARED COMPONENT WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

// ── Typography helper ─────────────────────────────────────────────────────────

TextStyle _gs(
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

// ── AppBar ────────────────────────────────────────────────────────────────────

class _RegAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int step, total;
  const _RegAppBar({required this.step, required this.total});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 3); // +3 for progress bar

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const BackButton(),
      title: Text('TIN Registration', style: _gs(16, weight: FontWeight.w600)),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '$step/$total',
              style: _gs(13, color: AppColors.greyDark),
            ),
          ),
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      bottom: _ProgressBar(step: step, total: total),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget implements PreferredSizeWidget {
  final int step, total;
  const _ProgressBar({required this.step, required this.total});

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
    value: step / total,
    backgroundColor: const Color(0xFFEEEEEE),
    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF5C842)),
    minHeight: 3,
  );
}

// ── Step badge ────────────────────────────────────────────────────────────────

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
          color: Color(0xFFF5C842),
          letterSpacing: 11 * 0.02,
        ),
      ),
    ],
  );
}

// ── Field label (ALL CAPS, grey) ──────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontFamily: 'GeneralSans',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Color(0xFF888888),
      letterSpacing: 11 * 0.08,
    ),
  );
}

// ── Text input ────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 14,
          color: Colors.black87,
          letterSpacing: 14 * 0.02,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 14,
            color: Color(0xFFBBBBBB),
            letterSpacing: 14 * 0.02,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}

// ── Dropdown ──────────────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 14,
              color: Color(0xFFBBBBBB),
              letterSpacing: 14 * 0.02,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
            size: 20,
          ),
          style: const TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 14 * 0.02,
          ),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Info/note banner ──────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final Color color, bg, border;
  final String text;
  final String? title;

  const _InfoNote({
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
    required this.text,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 13 * 0.02,
                    ),
                  ),
                  const Gap(4),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    color: color,
                    letterSpacing: 12 * 0.02,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom continue button ────────────────────────────────────────────────────

class _BottomButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  static const _yellow = Color(0xFFF5C842);
  const _BottomButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _yellow,
          disabledBackgroundColor: _yellow.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 15 * 0.02,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black),
          ],
        ),
      ),
    ),
  );
}

// ── Filing category tile ──────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final String title, subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  static const _yellow = Color(0xFFF5C842);

  const _CategoryTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _yellow : const Color(0xFFE5E5E5),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.black87,
                letterSpacing: 14 * 0.02,
              ),
            ),
            const Gap(3),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12,
                color: Color(0xFF888888),
                letterSpacing: 12 * 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filed-before tile ─────────────────────────────────────────────────────────

class _FiledBeforeTile extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  static const _yellow = Color(0xFFF5C842);

  const _FiledBeforeTile({
    required this.iconWidget,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _yellow : const Color(0xFFE5E5E5),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const Gap(8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: Colors.black87,
                letterSpacing: 13 * 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── OTP digit box ─────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = controller.text.isNotEmpty;
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isFilled
              ? const Color(0xFFFFF8D6)
              : const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isFilled
                  ? const Color(0xFFF5C842)
                  : const Color(0xFFE5E5E5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isFilled
                  ? const Color(0xFFF5C842)
                  : const Color(0xFFE5E5E5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF5C842), width: 2),
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}

// ── Summary row (dark card) ───────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: Colors.white60,
              letterSpacing: 13 * 0.02,
            ),
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
