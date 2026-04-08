// // ─────────────────────────────────────────────────────────────────────────────
// // next_of_kin_screen.dart
// // ─────────────────────────────────────────────────────────────────────────────
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/widgets/custom_button.dart';
// import '../../../../../core/widgets/custom_dropdown_button.dart';
// import '../../../../../core/widgets/custom_input_field.dart';

// class NextOfKinScreen extends ConsumerStatefulWidget {
//   static const String path = '/next-of-kin';

//   const NextOfKinScreen({super.key});

//   @override
//   ConsumerState<NextOfKinScreen> createState() => _NextOfKinScreenState();
// }

// class _NextOfKinScreenState extends ConsumerState<NextOfKinScreen> {
//   final _fullNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _addressController = TextEditingController();

//   String? _selectedRelationship;
//   String? _selectedGender;

//   static const _relationships = [
//     'Spouse',
//     'Parent',
//     'Sibling',
//     'Child',
//     'Friend',
//     'Other',
//   ];

//   static const _genders = ['Male', 'Female', 'Prefer not to say'];

//   // ── Validation ────────────────────────────────────────────────────────────
//   bool get _isFormValid =>
//       _fullNameController.text.trim().isNotEmpty &&
//       _phoneController.text.trim().length >= 7 &&
//       _selectedRelationship != null;

//   void _onFieldChanged() => setState(() {});

//   // ── Submit ────────────────────────────────────────────────────────────────
//   void _onContinue() {
//     if (!_isFormValid) return;
//     // TODO: dispatch NOK details to provider / API
//     // context.pushNamed(NextScreen.path);
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
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
//             'Next of kin details',
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),
//           const Gap(10),
//           const Text(
//             'Please provide details of someone we can contact in case of an emergency.',
//             style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
//           ),
//           const Gap(28),

//           // ── Full Name ────────────────────────────────────────────────────
//           _FieldLabel('Full Name', required: true),
//           const Gap(6),
//           CustomTextFormField(
//             controller: _fullNameController,
//             hint: 'Enter full name',
//             isRounded: true,
//             onChanged: (_) => _onFieldChanged(),
//             textCapitalization: TextCapitalization.words,
//           ),
//           const Gap(20),

//           // ── Relationship ─────────────────────────────────────────────────
//           _FieldLabel('Relationship', required: true),
//           const Gap(6),
//           CustomDropdownButton(
//             items: _relationships,
//             value: _selectedRelationship,
//             hint: 'Select relationship',
//             onChanged: (val) => setState(() => _selectedRelationship = val),
//           ),
//           const Gap(20),

//           // ── Gender ───────────────────────────────────────────────────────
//           _FieldLabel('Gender', required: false),
//           const Gap(6),
//           CustomDropdownButton(
//             items: _genders,
//             value: _selectedGender,
//             hint: 'Select gender',
//             onChanged: (val) => setState(() => _selectedGender = val),
//           ),
//           const Gap(20),

//           // ── Phone Number ─────────────────────────────────────────────────
//           _FieldLabel('Phone Number', required: true),
//           const Gap(6),
//           CustomTextFormField(
//             controller: _phoneController,
//             hint: 'Enter phone number',
//             isRounded: true,
//             keyboardType: TextInputType.phone,
//             onChanged: (_) => _onFieldChanged(),
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(15),
//             ],
//           ),
//           const Gap(20),

//           // ── Email Address ────────────────────────────────────────────────
//           _FieldLabel('Email Address', required: false),
//           const Gap(6),
//           CustomTextFormField(
//             controller: _emailController,
//             hint: 'Enter email address',
//             isRounded: true,
//             keyboardType: TextInputType.emailAddress,
//             onChanged: (_) => _onFieldChanged(),
//           ),
//           const Gap(20),

//           // ── Residential Address ──────────────────────────────────────────
//           _FieldLabel('Residential Address', required: false),
//           const Gap(6),
//           CustomTextFormField(
//             controller: _addressController,
//             hint: 'Enter residential address',
//             isRounded: true,
//             onChanged: (_) => _onFieldChanged(),
//             textCapitalization: TextCapitalization.sentences,
//             maxLines: 2,
//           ),
//         ],
//       ),
//     );
//   }
// }