// lib/features/tools/presentation/screens/taxation/filing/tin_reg_screen1.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';

class TinRegScreen1 extends StatefulWidget {
  static const String path = FilingRoutes.tinReg1;

  const TinRegScreen1({super.key});

  @override
  State<TinRegScreen1> createState() => _TinRegScreen1State();
}

class _TinRegScreen1State extends State<TinRegScreen1> {
  final _bvnCtrl = TextEditingController();
  final _ninCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

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

  bool get _canContinue =>
      _bvnCtrl.text.length == 11 &&
      _ninCtrl.text.length == 11 &&
      _nameCtrl.text.trim().isNotEmpty &&
      _dobCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _bvnCtrl,
      _ninCtrl,
      _nameCtrl,
      _dobCtrl,
      _phoneCtrl,
      _emailCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _bvnCtrl,
      _ninCtrl,
      _nameCtrl,
      _dobCtrl,
      _phoneCtrl,
      _emailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onContinue() {
    if (_canContinue) context.pushNamed(FilingRoutes.tinReg2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'TIN Registration',
          style: _gs(16, weight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('1 of 3', style: _gs(13, color: AppColors.greyDark)),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: const _ProgressBar(step: 1, total: 3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                children: [
                  // ── Step badge ────────────────────────────────────────
                  _StepBadge(label: 'STEP 1 OF 3 · IDENTITY INFORMATION'),
                  const Gap(18),

                  // ── Headline ──────────────────────────────────────────
                  Text(
                    "Let's confirm who\nyou are",
                    style: _gs(26, weight: FontWeight.w700),
                  ),
                  const Gap(6),
                  Text(
                    'Required by FIRS for TIN generation.',
                    style: _gs(13, color: AppColors.greyDark),
                  ),
                  const Gap(28),

                  // ── BVN + NIN row ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'BVN',
                          child: _InputField(
                            controller: _bvnCtrl,
                            hint: '11 digits',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LabeledField(
                          label: 'NIN',
                          child: _InputField(
                            controller: _ninCtrl,
                            hint: '11 digits',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),

                  // ── Full Legal Name ────────────────────────────────────
                  _LabeledField(
                    label: 'Full Legal Name',
                    child: _InputField(
                      controller: _nameCtrl,
                      hint: 'As on your ID',
                    ),
                  ),
                  const Gap(16),

                  // ── Date of Birth ──────────────────────────────────────
                  _LabeledField(
                    label: 'Date of Birth',
                    child: _InputField(
                      controller: _dobCtrl,
                      hint: 'dd/mm/yyyy',
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const Gap(16),

                  // ── Phone Number ───────────────────────────────────────
                  _LabeledField(
                    label: 'Phone Number',
                    child: _InputField(
                      controller: _phoneCtrl,
                      hint: '+234 800 000 0000',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const Gap(16),

                  // ── Email Address ──────────────────────────────────────
                  _LabeledField(
                    label: 'Email Address',
                    child: _InputField(
                      controller: _emailCtrl,
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),

            // ── Continue button ────────────────────────────────────────
            _BottomButton(
              label: 'Continue',
              enabled: _canContinue,
              onTap: _onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

// ── TIN Registration Step 2 ───────────────────────────────────────────────────

class TinRegScreen2 extends StatefulWidget {
  static const String path = FilingRoutes.tinReg2;

  const TinRegScreen2({super.key});

  @override
  State<TinRegScreen2> createState() => _TinRegScreen2State();
}

class _TinRegScreen2State extends State<TinRegScreen2> {
  final _addressCtrl = TextEditingController();
  String? _selectedState;
  final _lgaCtrl = TextEditingController();

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

  // State → tax authority mapping
  String _taxAuthority(String? state) {
    if (state == null) return '';
    if (state == 'FCT') return 'FIRS';
    if (state == 'Lagos') return 'LIRS';
    return '${state.toUpperCase().substring(0, 3)}IRS';
  }

  bool get _canContinue =>
      _addressCtrl.text.trim().isNotEmpty &&
      _selectedState != null &&
      _lgaCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _addressCtrl.addListener(() => setState(() {}));
    _lgaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _lgaCtrl.dispose();
    super.dispose();
  }

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
    final authority = _taxAuthority(_selectedState);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'TIN Registration',
          style: _gs(16, weight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('2 of 3', style: _gs(13, color: AppColors.greyDark)),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: const _ProgressBar(step: 2, total: 3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                children: [
                  _StepBadge(label: 'STEP 2 OF 3 · ADDRESS & LOCATION'),
                  const Gap(18),
                  Text(
                    'Where are you based?',
                    style: _gs(26, weight: FontWeight.w700),
                  ),
                  const Gap(6),
                  Text(
                    'Your state determines which tax authority handles your filing.',
                    style: _gs(13, color: AppColors.greyDark),
                  ),
                  const Gap(28),

                  // ── Residential Address ────────────────────────────────
                  _LabeledField(
                    label: 'Residential Address',
                    child: _InputField(
                      controller: _addressCtrl,
                      hint: 'House number, street, area',
                    ),
                  ),
                  const Gap(16),

                  // ── State dropdown ─────────────────────────────────────
                  _LabeledField(
                    label: 'State of Residence',
                    child: _DropdownField(
                      value: _selectedState,
                      hint: 'Select state',
                      items: _states,
                      onChanged: (v) => setState(() => _selectedState = v),
                    ),
                  ),
                  const Gap(16),

                  // ── LGA ───────────────────────────────────────────────
                  _LabeledField(
                    label: 'Local Government Area (LGA)',
                    child: _InputField(
                      controller: _lgaCtrl,
                      hint: 'e.g. Ikeja, Surulere',
                    ),
                  ),

                  // ── Tax authority indicator ────────────────────────────
                  if (_selectedState != null) ...[
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF5C842).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFFC0392B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tax Authority: $authority',
                                  style: _gs(
                                    13,
                                    weight: FontWeight.w600,
                                    color: const Color(0xFFC0392B),
                                  ),
                                ),
                                Text(
                                  'Your filing will be routed to the appropriate state board',
                                  style: _gs(
                                    11,
                                    color: const Color(0xFFC0392B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Gap(24),
                ],
              ),
            ),
            _BottomButton(
              label: 'Continue',
              enabled: _canContinue,
              onTap: () {
                if (_canContinue) context.pushNamed(FilingRoutes.tinReg3);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── TIN Registration Step 3 ───────────────────────────────────────────────────

class TinRegScreen3 extends StatefulWidget {
  static const String path = FilingRoutes.tinReg3;

  const TinRegScreen3({super.key});

  @override
  State<TinRegScreen3> createState() => _TinRegScreen3State();
}

class _TinRegScreen3State extends State<TinRegScreen3> {
  String _selectedId = 'National ID Card (NIN)';
  bool _photoUploaded = false;
  bool _addressUploaded = false;
  bool _isSubmitting = false;

  static const _yellow = Color(0xFFF5C842);

  static const _idTypes = [
    'National ID Card (NIN)',
    'International Passport',
    "Driver's Licence",
    'Voter\'s Card (PVC)',
  ];

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

  bool get _canSubmit => _photoUploaded;

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
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
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'TIN Registration',
          style: _gs(16, weight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('3 of 3', style: _gs(13, color: AppColors.greyDark)),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: const _ProgressBar(step: 3, total: 3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                children: [
                  _StepBadge(label: 'STEP 3 OF 3 · VERIFICATION DOCUMENTS'),
                  const Gap(18),

                  Text(
                    'Verify your identity',
                    style: _gs(26, weight: FontWeight.w700),
                  ),
                  const Gap(6),
                  Text(
                    'Upload documents to complete your registration.',
                    style: _gs(13, color: AppColors.greyDark),
                  ),
                  const Gap(24),

                  // ── Valid ID Type ──────────────────────────────────────
                  Text(
                    'Valid ID Type',
                    style: _gs(13, weight: FontWeight.w500),
                  ),
                  const Gap(10),
                  ..._idTypes.map(
                    (type) => _IdTypeOption(
                      label: type,
                      isSelected: _selectedId == type,
                      onTap: () => setState(() => _selectedId = type),
                    ),
                  ),
                  const Gap(20),

                  // ── Passport photograph ────────────────────────────────
                  Text(
                    'Passport Photograph',
                    style: _gs(13, weight: FontWeight.w500),
                  ),
                  const Gap(10),
                  _UploadBox(
                    label: _photoUploaded
                        ? 'Photo uploaded ✓'
                        : 'Tap to upload photo',
                    sublabel: 'JPG or PNG · White background – Facing forward',
                    isUploaded: _photoUploaded,
                    onTap: () => setState(() => _photoUploaded = true),
                  ),
                  const Gap(20),

                  // ── Proof of address (optional) ────────────────────────
                  Row(
                    children: [
                      Text(
                        'Proof of Address',
                        style: _gs(13, weight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(optional)',
                        style: _gs(12, color: AppColors.greyDark),
                      ),
                    ],
                  ),
                  const Gap(10),
                  _UploadBox(
                    label: _addressUploaded
                        ? 'Document uploaded ✓'
                        : 'Upload utility bill',
                    sublabel: 'NEPA/PHCN bill, LAWMA, or bank statement',
                    isUploaded: _addressUploaded,
                    onTap: () => setState(() => _addressUploaded = true),
                  ),
                  const Gap(24),
                ],
              ),
            ),

            // ── Submit button ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _onSubmit : null,
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
                          'Submit registration',
                          style: _gs(
                            15,
                            weight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'TIN issuance usually takes 24–72 hours after submission',
                  style: _gs(11, color: AppColors.greyDark),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            letterSpacing: 13 * 0.02,
          ),
        ),
        const Gap(6),
        child,
      ],
    );
  }
}

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
      // padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
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

class _IdTypeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IdTypeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _yellow : const Color(0xFFE5E5E5),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: Colors.black87,
                letterSpacing: 14 * 0.02,
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: _yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isUploaded;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.sublabel,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF43A047)
                : const Color(0xFFE5E5E5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUploaded ? Icons.check_circle_outline : Icons.upload_outlined,
              size: 22,
              color: isUploaded ? const Color(0xFF43A047) : Colors.black54,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isUploaded
                        ? const Color(0xFF2E7D32)
                        : Colors.black87,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 11,
                    color: Color(0xFF888888),
                    letterSpacing: 11 * 0.02,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _BottomButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  static const _yellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
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
          icon: const SizedBox.shrink(),
          label: Row(
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
            color: Color(0xFFF5C842),
            letterSpacing: 11 * 0.02,
          ),
        ),
      ],
    );
  }
}

// ── Progress bar (AppBar bottom) ──────────────────────────────────────────────

class _ProgressBar extends StatelessWidget implements PreferredSizeWidget {
  final int step;
  final int total;

  const _ProgressBar({required this.step, required this.total});

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: step / total,
      backgroundColor: const Color(0xFFEEEEEE),
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF5C842)),
      minHeight: 3,
    );
  }
}
