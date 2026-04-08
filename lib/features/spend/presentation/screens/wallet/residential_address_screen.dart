// // ─────────────────────────────────────────────────────────────────────────────
// // residential_address_screen.dart
// // ─────────────────────────────────────────────────────────────────────────────
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/widgets/custom_button.dart';
// import '../../../../../core/widgets/custom_dropdown_button.dart';
// import '../../../../../core/widgets/custom_input_field.dart';
// import 'next_of_kin_screen.dart';

// class ResidentialAddressScreen extends ConsumerStatefulWidget {
//   static const String path = '/residential-address';

//   const ResidentialAddressScreen({super.key});

//   @override
//   ConsumerState<ResidentialAddressScreen> createState() =>
//       _ResidentialAddressScreenState();
// }

// class _ResidentialAddressScreenState
//     extends ConsumerState<ResidentialAddressScreen> {
//   final _addressLine1Controller = TextEditingController();
//   final _addressLine2Controller = TextEditingController();
//   final _postalCodeController = TextEditingController();

//   String? _selectedCountry;
//   String? _selectedState;
//   String? _selectedCity;

//   // ── Mock data — replace with real providers / API calls ──────────────────
//   static const _countries = ['Nigeria', 'Ghana', 'Kenya', 'South Africa'];

//   static const _statesByCountry = <String, List<String>>{
//     'Nigeria': ['Lagos', 'Abuja', 'Rivers', 'Kano', 'Oyo'],
//     'Ghana': ['Greater Accra', 'Ashanti', 'Western', 'Eastern'],
//     'Kenya': ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru'],
//     'South Africa': ['Gauteng', 'Western Cape', 'KwaZulu-Natal', 'Limpopo'],
//   };

//   static const _citiesByState = <String, List<String>>{
//     'Lagos': ['Ikeja', 'Lekki', 'Surulere', 'Victoria Island', 'Yaba'],
//     'Abuja': ['Garki', 'Wuse', 'Maitama', 'Asokoro', 'Gwarinpa'],
//     'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Eleme'],
//     'Kano': ['Kano Municipal', 'Fagge', 'Nassarawa'],
//     'Oyo': ['Ibadan North', 'Ibadan South', 'Ogbomosho'],
//     'Greater Accra': ['Accra', 'Tema', 'Ga East'],
//     'Ashanti': ['Kumasi', 'Obuasi', 'Ejisu'],
//     'Western': ['Takoradi', 'Sekondi', 'Tarkwa'],
//     'Eastern': ['Koforidua', 'Nkawkaw'],
//     'Nairobi': ['Westlands', 'Karen', 'Eastleigh', 'Langata'],
//     'Mombasa': ['Mombasa Island', 'Likoni', 'Kisauni'],
//     'Kisumu': ['Kisumu Central', 'Nyando'],
//     'Nakuru': ['Nakuru Town', 'Naivasha'],
//     'Gauteng': ['Johannesburg', 'Pretoria', 'Soweto', 'Sandton'],
//     'Western Cape': ['Cape Town', 'Stellenbosch', 'George'],
//     'KwaZulu-Natal': ['Durban', 'Pietermaritzburg', 'Richards Bay'],
//     'Limpopo': ['Polokwane', 'Tzaneen', 'Thohoyandou'],
//   };

//   List<String> get _availableStates =>
//       _selectedCountry != null
//           ? (_statesByCountry[_selectedCountry] ?? [])
//           : [];

//   List<String> get _availableCities =>
//       _selectedState != null
//           ? (_citiesByState[_selectedState] ?? [])
//           : [];

//   // ── Validation ────────────────────────────────────────────────────────────
//   bool get _isFormValid =>
//       _selectedCountry != null &&
//       _selectedState != null &&
//       _selectedCity != null &&
//       _addressLine1Controller.text.trim().isNotEmpty &&
//       _postalCodeController.text.trim().isNotEmpty;

//   void _onFieldChanged() => setState(() {});

//   // ── Submit ────────────────────────────────────────────────────────────────
//   void _onContinue() {
//     if (!_isFormValid) return;
//     context.pushNamed(NextOfKinScreen.path);
//   }

//   @override
//   void dispose() {
//     _addressLine1Controller.dispose();
//     _addressLine2Controller.dispose();
//     _postalCodeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text('Confirm your identity'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => context.pop(),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _BottomContinueButton(
//         enabled: _isFormValid,
//         onPressed: _onContinue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
//         children: [
//           // ── Header ──────────────────────────────────────────────────────
//           const Text(
//             'Your residential address',
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),
//           const Gap(10),
//           const Text(
//             'We need your address as part of our identity verification process.',
//             style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
//           ),
//           const Gap(28),

//           // ── Country ─────────────────────────────────────────────────────
//           _FieldLabel('Country', required: true),
//           const Gap(6),
//           CustomDropdownButton(
//             items: _countries,
//             value: _selectedCountry,
//             hint: 'Select your country',
//             enableSearch: true,
//             onChanged: (val) => setState(() {
//               _selectedCountry = val;
//               _selectedState = null;
//               _selectedCity = null;
//             }),
//           ),
//           const Gap(20),

//           // ── State ────────────────────────────────────────────────────────
//           _FieldLabel('State', required: true),
//           const Gap(6),
//           CustomDropdownButton(
//             items: _availableStates,
//             value: _selectedState,
//             hint: 'Select your state',
//             enabled: _selectedCountry != null,
//             enableSearch: true,
//             onChanged: (val) => setState(() {
//               _selectedState = val;
//               _selectedCity = null;
//             }),
//           ),
//           const Gap(20),

//           // ── City ─────────────────────────────────────────────────────────
//           _FieldLabel('City', required: true),
//           const Gap(6),
//           CustomDropdownButton(
//             items: _availableCities,
//             value: _selectedCity,
//             hint: 'Select your city',
//             enabled: _selectedState != null,
//             enableSearch: true,
//             onChanged: (val) => setState(() => _selectedCity = val),
//           ),
//           const Gap(20),

//           // ── Address Line 1 ───────────────────────────────────────────────
//           _FieldLabel('Address Line 1', required: true),
//           const Gap(6),
//           CustomTextFormField(
//             controller: _addressLine1Controller,
//             hint: 'Street name and house number',
//             isRounded: true,
//             onChanged: (_) => _onFieldChanged(),
//             textCapitalization: TextCapitalization.words,
//           ),
//           const Gap(20),

//           // ── Address Line 2 ───────────────────────────────────────────────
//           _FieldLabel('Address Line 2', required: false),
//           const Gap(6),
//           CustomTextFormField(
//             controller: _addressLine2Controller,
//             hint: 'Apartment, suite, landmark',
//             isRounded: true,
//             onChanged: (_) => _onFieldChanged(),
//             textCapitalization: TextCapitalization.words,
//           ),
//           const Gap(20),

//           // ── Postal Code ──────────────────────────────────────────────────
//           _FieldLabel('Postal Code', required: true),
//           const Gap(6),
//           CustomTextFormField(
//             controller: _postalCodeController,
//             hint: 'Enter your postal code',
//             isRounded: true,
//             onChanged: (_) => _onFieldChanged(),
//             keyboardType: TextInputType.text,
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
//               LengthLimitingTextInputFormatter(10),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


// // ─────────────────────────────────────────────────────────────────────────────
// // Shared widgets (can live in core/widgets or at the bottom of either file)
// // ─────────────────────────────────────────────────────────────────────────────

// /// Required / optional field label matching the design
// class _FieldLabel extends StatelessWidget {
//   final String text;
//   final bool required;

//   const _FieldLabel(this.text, {this.required = true});

//   @override
//   Widget build(BuildContext context) {
//     return RichText(
//       text: TextSpan(
//         text: text,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w500,
//           color: Colors.black,
//         ),
//         children: [
//           if (required)
//             const TextSpan(
//               text: ' *',
//               style: TextStyle(color: AppColors.error),
//             )
//           else
//             TextSpan(
//               text: ' (optional)',
//               style: TextStyle(
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.textSecondary,
//                 fontSize: 12,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// /// Sticky bottom Continue button — shared between both screens
// class _BottomContinueButton extends StatelessWidget {
//   final bool enabled;
//   final VoidCallback onPressed;

//   const _BottomContinueButton({
//     required this.enabled,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//         child: FilledButton(
//           onPressed: enabled ? onPressed : null,
//           style: FilledButton.styleFrom(
//             backgroundColor: Colors.black,
//             disabledBackgroundColor: Colors.grey.shade200,
//             minimumSize: const Size.fromHeight(52),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(
//             'Continue',
//             style: TextStyle(
//               color: enabled ? Colors.white : Colors.grey.shade400,
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }