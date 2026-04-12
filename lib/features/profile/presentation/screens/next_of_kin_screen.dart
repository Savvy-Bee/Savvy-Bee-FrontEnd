import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/data/repositories/nok_repository.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/providers/nok_provider.dart';

class NextOfKinScreen extends ConsumerStatefulWidget {
  static const String path = '/next-of-kin';

  const NextOfKinScreen({super.key});

  @override
  ConsumerState<NextOfKinScreen> createState() => _NextOfKinScreenState();
}

class _NextOfKinScreenState extends ConsumerState<NextOfKinScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedRelationship;
  bool _isLoading = false;
  bool _prefilled = false;

  static const _relationships = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Uncle',
    'Aunt',
    'Cousin',
    'Nephew',
    'Niece',
    'Spouse',
    'Parent',
    'Sibling',
    'Child',
    'Friend',
    'Other',
  ];

  bool get _isFormValid =>
      _fullNameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().length >= 7 &&
      _selectedRelationship != null;

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _prefill(NokData nok) {
    if (_prefilled) return;
    _prefilled = true;
    _fullNameController.text = nok.fullName;
    _phoneController.text = nok.phoneNumber;
    _emailController.text = nok.email;
    _selectedRelationship = _relationships.contains(nok.relationship)
        ? nok.relationship
        : null;
    setState(() {});
  }

  Future<void> _onSave() async {
    if (!_isFormValid || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final nok = NokData(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        relationship: _selectedRelationship!,
        email: _emailController.text.trim(),
      );
      await ref.read(nokRepositoryProvider).updateNok(nok);
      ref.invalidate(fetchNokProvider);
      ref.invalidate(homeDataProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Next of kin updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill if existing NOK data is available
    ref.watch(fetchNokProvider).whenData((nok) {
      if (nok != null) _prefill(nok);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next of Kin'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                Text(
                  'Next of Kin (NOK)',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 20 * 0.02,
                  ),
                ),
                const Gap(8),
                const Text(
                  'Please provide details of someone we can contact in case of an emergency.',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'GeneralSans',
                    color: AppColors.textSecondary,
                    height: 1.5,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(24),

                // Full Name
                _FieldLabel('Full Name', required: true),
                const Gap(6),
                CustomTextFormField(
                  controller: _fullNameController,
                  hint: 'Enter full name',
                  isRounded: true,
                  onChanged: (_) => _onFieldChanged(),
                  textCapitalization: TextCapitalization.words,
                ),
                const Gap(20),

                // Relationship
                _FieldLabel('Relationship', required: true),
                const Gap(6),
                CustomDropdownButton(
                  items: _relationships,
                  value: _selectedRelationship,
                  hint: 'Select relationship',
                  onChanged: (val) =>
                      setState(() => _selectedRelationship = val),
                ),
                const Gap(20),

                // Phone Number
                _FieldLabel('Phone Number', required: true),
                const Gap(6),
                CustomTextFormField(
                  controller: _phoneController,
                  hint: 'Enter phone number',
                  isRounded: true,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => _onFieldChanged(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
                const Gap(20),

                // Email
                _FieldLabel('Email Address', required: false),
                const Gap(6),
                CustomTextFormField(
                  controller: _emailController,
                  hint: 'Enter email address',
                  isRounded: true,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                text: _isLoading ? 'Saving…' : 'Save Next of Kin',
                onPressed: _isFormValid && !_isLoading ? _onSave : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _FieldLabel(this.text, {this.required = true});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontFamily: 'GeneralSans',
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            )
          else
            const TextSpan(
              text: ' (optional)',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
