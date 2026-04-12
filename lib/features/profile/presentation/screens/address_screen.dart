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

class AddressScreen extends ConsumerStatefulWidget {
  static const String path = '/profile-address';

  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _postalCodeController = TextEditingController();

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  bool _isLoading = false;

  static const _countries = ['Nigeria', 'Ghana', 'Kenya', 'South Africa'];

  static const _statesByCountry = <String, List<String>>{
    'Nigeria': [
      'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa',
      'Benue', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti',
      'Enugu', 'FCT', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina',
      'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun',
      'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba',
      'Yobe', 'Zamfara',
    ],
    'Ghana': ['Greater Accra', 'Ashanti', 'Western', 'Eastern'],
    'Kenya': ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru'],
    'South Africa': ['Gauteng', 'Western Cape', 'KwaZulu-Natal', 'Limpopo'],
  };

  static const _citiesByState = <String, List<String>>{
    'Lagos': ['Ikeja', 'Lekki', 'Surulere', 'Victoria Island', 'Yaba', 'Alimosho'],
    'FCT': ['Garki', 'Wuse', 'Maitama', 'Asokoro', 'Gwarinpa'],
    'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Eleme'],
    'Kano': ['Kano Municipal', 'Fagge', 'Nassarawa'],
    'Oyo': ['Ibadan North', 'Ibadan South', 'Ogbomosho'],
    'Abuja': ['Garki', 'Wuse', 'Maitama'],
  };

  List<String> get _availableStates =>
      _selectedCountry != null ? (_statesByCountry[_selectedCountry] ?? []) : [];

  List<String> get _availableCities =>
      _selectedState != null ? (_citiesByState[_selectedState] ?? [_selectedState!]) : [];

  bool get _isFormValid =>
      _selectedCountry != null &&
      _selectedState != null &&
      _addressLine1Controller.text.trim().isNotEmpty &&
      _postalCodeController.text.trim().isNotEmpty;

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_isFormValid || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final address = UserAddress(
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _selectedCity ?? _selectedState!,
        state: _selectedState!,
        postalCode: _postalCodeController.text.trim(),
        country: _selectedCountry == 'Nigeria' ? 'NG' : _selectedCountry!,
      );
      await ref.read(nokRepositoryProvider).setAddress(address);
      ref.invalidate(homeDataProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved successfully'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Residential Address'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                const Text(
                  'Your residential address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 20 * 0.02,
                  ),
                ),
                const Gap(8),
                const Text(
                  'We need your address as part of your profile completion.',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'GeneralSans',
                    color: AppColors.textSecondary,
                    height: 1.5,
                    letterSpacing: 13 * 0.02,
                  ),
                ),
                const Gap(24),

                // Country
                _FieldLabel('Country', required: true),
                const Gap(6),
                CustomDropdownButton(
                  items: _countries,
                  value: _selectedCountry,
                  hint: 'Select your country',
                  enableSearch: true,
                  onChanged: (val) => setState(() {
                    _selectedCountry = val;
                    _selectedState = null;
                    _selectedCity = null;
                  }),
                ),
                const Gap(20),

                // State
                _FieldLabel('State', required: true),
                const Gap(6),
                CustomDropdownButton(
                  items: _availableStates,
                  value: _selectedState,
                  hint: 'Select your state',
                  enabled: _selectedCountry != null,
                  enableSearch: true,
                  onChanged: (val) => setState(() {
                    _selectedState = val;
                    _selectedCity = null;
                  }),
                ),
                const Gap(20),

                // City
                _FieldLabel('City', required: false),
                const Gap(6),
                CustomDropdownButton(
                  items: _availableCities,
                  value: _selectedCity,
                  hint: 'Select your city',
                  enabled: _selectedState != null,
                  enableSearch: true,
                  onChanged: (val) => setState(() => _selectedCity = val),
                ),
                const Gap(20),

                // Address Line 1
                _FieldLabel('Address Line 1', required: true),
                const Gap(6),
                CustomTextFormField(
                  controller: _addressLine1Controller,
                  hint: 'Street name and house number',
                  isRounded: true,
                  onChanged: (_) => _onFieldChanged(),
                  textCapitalization: TextCapitalization.words,
                ),
                const Gap(20),

                // Address Line 2
                _FieldLabel('Address Line 2', required: false),
                const Gap(6),
                CustomTextFormField(
                  controller: _addressLine2Controller,
                  hint: 'Apartment, suite, landmark',
                  isRounded: true,
                  onChanged: (_) => _onFieldChanged(),
                  textCapitalization: TextCapitalization.words,
                ),
                const Gap(20),

                // Postal Code
                _FieldLabel('Postal Code', required: true),
                const Gap(6),
                CustomTextFormField(
                  controller: _postalCodeController,
                  hint: 'Enter your postal code',
                  isRounded: true,
                  onChanged: (_) => _onFieldChanged(),
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                text: _isLoading ? 'Saving…' : 'Save Address',
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
