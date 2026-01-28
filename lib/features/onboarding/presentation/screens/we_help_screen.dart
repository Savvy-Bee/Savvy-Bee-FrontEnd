import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/answer_button.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/continue_button.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/onboarding_header.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/onboarding_scaffold.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/selection_card.dart';
import 'package:savvy_bee_mobile/features/onboarding/presentation/screens/priority_screen.dart';

class WeHelpScreen extends StatefulWidget {
  static const String path = '/wehelp';
  const WeHelpScreen({super.key});

  @override
  State<WeHelpScreen> createState() => _WeHelpScreenState();
}

class _WeHelpScreenState extends State<WeHelpScreen> {
  final List<HelpOption> _options = [
    HelpOption(
      id: 'spending',
      label: 'Manage my spending',
      icon: Icons.credit_card_outlined,
    ),
    HelpOption(
      id: 'savings',
      label: 'Grow my savings',
      icon: Icons.shield_outlined,
    ),
    HelpOption(
      id: 'guidance',
      label: 'Get AI-powered guidance',
      icon: Icons.auto_awesome_outlined,
    ),
    HelpOption(
      id: 'budget',
      label: 'Stick to my budget',
      icon: Icons.schedule_outlined,
    ),
    HelpOption(
      id: 'networth',
      label: 'Track my net worth',
      icon: Icons.trending_up_outlined,
    ),
    HelpOption(
      id: 'unsure',
      label: "I'm not sure",
      icon: Icons.help_outline,
    ),
  ];

  final Set<String> _selectedOptions = {};

  bool get _hasSelection => _selectedOptions.isNotEmpty;

  void _toggleOption(String id) {
    setState(() {
      if (_selectedOptions.contains(id)) {
        _selectedOptions.remove(id);
      } else {
        _selectedOptions.add(id);
      }
    });
  }

  void _handleContinue() {
    if (_hasSelection) {
      // TODO: Navigate to next screen
      context.pushNamed(PriorityScreen.path);
      // print('Selected options: $_selectedOptions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottomButton: ContinueButton(
        isEnabled: _hasSelection,
        onPressed: _handleContinue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          const OnboardingHeader(
            title: 'Where can we help?',
            subtitle: 'Choose as many options as you like.',
          ),
          // Options list
          ..._options.map(
            (option) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SelectionCard(
                icon: option.icon,
                label: option.label,
                isSelected: _selectedOptions.contains(option.id),
                onTap: () => _toggleOption(option.id),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class HelpOption {
  final String id;
  final String label;
  final IconData icon;

  HelpOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}


// import 'package:flutter/material.dart';
// import 'package:savvy_bee_mobile/core/widgets/onboarding/help_back_app_bar.dart';
// import 'package:savvy_bee_mobile/core/widgets/onboarding/help_header.dart';

// class WeHelpScreen extends StatefulWidget {
//   static const String path = '/wehelp';
//   const WeHelpScreen({super.key});

//   @override
//   State<WeHelpScreen> createState() => _WeHelpScreenState();
// }

// class _WeHelpScreenState extends State<WeHelpScreen> {
//   final List<HelpOption> _options = [HelpOption(
//       id: 'spending',
//       label: 'Manage my spending',
//       icon: Icons.credit_card_outlined,
//     ),
//     HelpOption(
//       id: 'savings',
//       label: 'Grow my savings',
//       icon: Icons.shield_outlined,
//     ),
//     HelpOption(
//       id: 'guidance',
//       label: 'Get AI-powered guidance',
//       icon: Icons.auto_awesome_outlined,
//     ),
//     HelpOption(
//       id: 'budget',
//       label: 'Stick to my budget',
//       icon: Icons.schedule_outlined,
//     ),
//     HelpOption(
//       id: 'networth',
//       label: 'Track my net worth',
//       icon: Icons.trending_up_outlined,
//     ),
//     HelpOption(
//       id: 'unsure',
//       label: "I'm not sure",
//       icon: Icons.help_outline,
//     ), ]; // your existing list

//   final Set<String> _selectedOptions = {};

//   bool get _hasSelection => _selectedOptions.isNotEmpty;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: const HelpBackAppBar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 8),
//                   const HelpHeader(),           // ← reusable
//                   // Options list
//                   ..._options.map(
//                     (option) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: _HelpOptionCard(
//                         option: option,
//                         isSelected: _selectedOptions.contains(option.id),
//                         onTap: () {
//                           setState(() {
//                             _selectedOptions.contains(option.id)
//                                 ? _selectedOptions.remove(option.id)
//                                 : _selectedOptions.add(option.id);
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: _hasSelection
//                       ? () {
//                           // Navigate to next screen
//                         }
//                       : null,
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     decoration: BoxDecoration(
//                       color: _hasSelection
//                           ? Colors.black
//                           : const Color(0xFFE0E0E0),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       'Continue',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                         color: _hasSelection
//                             ? Colors.white
//                             : const Color(0xFF999999),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class HelpOption {
//   final String id;
//   final String label;
//   final IconData icon;

//   HelpOption({required this.id, required this.label, required this.icon});
// }

// class _HelpOptionCard extends StatelessWidget {
//   final HelpOption option;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _HelpOptionCard({
//     required this.option,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(
//             color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
//             width: isSelected ? 2 : 1.5,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(option.icon, size: 24, color: Colors.black),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 option.label,
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
