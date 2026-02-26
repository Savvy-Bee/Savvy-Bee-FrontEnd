import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assets/illustrations.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/intro_text.dart';
import '../../../../features/auth/presentation/screens/post_signup/signup_connect_bank_screen.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/widgets/icon_text_row_widget.dart';
import '../../domain/models/personality.dart';
import '../providers/chat_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hardcoded personality data — matches the UI image exactly.
// The `id` values must match what the API expects so _selectPersonality works.
// ─────────────────────────────────────────────────────────────────────────────

class _LocalPersonality {
  const _LocalPersonality({
    required this.id,
    required this.role,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  final String id;
  final String role;
  final String name;
  final String description;
  final String imagePath;
}

const List<_LocalPersonality> _kPersonalities = [
  _LocalPersonality(
    id: 'loan_pro',
    role: 'The Loan Pro',
    name: 'Dash',
    description:
        'A big bold buzz with cool swag and fierce energy. '
        'Strong-willed yet deeply loyal, Dash brings grit and '
        'determination to the hive, standing firm for those '
        'he cares about.',
    imagePath: 'assets/images/icons/dash.png',
  ),
  _LocalPersonality(
    id: 'budgeting_bee',
    role: 'The Budgeting Bee',
    name: 'Penny',
    description:
        'A thoughtful little worrier with a big heart, always '
        'buzzing around with neat plans and tidy ideas. '
        'Frugal and dependable, Penny loves keeping '
        'everything in order, making sure no honey drop to '
        'waste while helping the hive stay smart and secure.',
    imagePath: 'assets/images/icons/penny.png',
  ),
  _LocalPersonality(
    id: 'saving_star',
    role: 'The Saving Star',
    name: 'Bloom',
    description:
        'A super achiever who cheers others on, always '
        'daring and inquisitive. Proud of every hobby and '
        'achievement, Bloom finds joy in learning, growing, '
        'and inspiring the hive to reach new heights.',
    imagePath: 'assets/images/icons/bloom.png',
  ),
  _LocalPersonality(
    id: 'big_dreamer',
    role: 'The Big Dreamer',
    name: 'Susu',
    description:
        'An adorable keeper of treasures, curious yet '
        'steady, with a memory as golden as honey. '
        'Dependable and thoughtful, Susu prefers calm and '
        'focus, often drifting into sweet little naps while '
        'quietly protecting the hive\'s future.',
    imagePath: 'assets/images/icons/susu.png',
  ),
  _LocalPersonality(
    id: 'matching_bee',
    role: 'The Matching Bee',
    name: 'Luna',
    description:
        'A curious little spirit who dances with the breeze '
        'and delights in every color of the meadow. Playful '
        'and full of wonder, Luna flows with nature\'s rythm, '
        'always ready to explore, laugh, and brighten the '
        'hive with cheerful joy.',
    imagePath: 'assets/images/icons/luna.png',
  ),
  _LocalPersonality(
    id: 'quiz_bee',
    role: 'The Quiz Bee',
    name: 'Boo',
    description:
        'A big wise buzz full of questions, always eager yet '
        'caring. With a warm heart and a sharp mind, Boo '
        'helps others see things clearly, guiding the hive '
        'with knowledge while gently reminding everyone to '
        'think twice',
    imagePath: 'assets/images/icons/boo.png',
  ),
  _LocalPersonality(
    id: 'scam_spotter',
    role: 'The Scam Spotter',
    name: 'Loki',
    description:
        'A clever little buzz with quick wit and sharp ideas, '
        'always finding creative ways to grow and move '
        'forward. Loki\'s charm lies in turning tricky '
        'moments into fresh chances for progress, keeping '
        'the hive on its toes.',
    imagePath: 'assets/images/icons/loki.png',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class ChoosePersonalityScreen extends ConsumerStatefulWidget {
  static const String path = '/choose-personality';

  final bool isFromSignup;

  const ChoosePersonalityScreen({super.key, required this.isFromSignup});

  @override
  ConsumerState<ChoosePersonalityScreen> createState() =>
      _ChoosePersonalityScreenState();
}

class _ChoosePersonalityScreenState
    extends ConsumerState<ChoosePersonalityScreen> {
  int _selectedPersonality = 0;
  bool _isUpdating = false;
  late PageController _pageController;

  // Now tracks the locally-defined personality instead of the API model.
  _LocalPersonality? _selectedLocal;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPersonality);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Converts the local selection into a minimal [Personality]-compatible call
  /// so the existing repository / API contract is unchanged.
  Future<void> _selectPersonality(_LocalPersonality local) async {
    setState(() => _isUpdating = true);

    try {
      final chatRepository = ref.read(chatRepositoryProvider);
      final success = await chatRepository.updatePersonality(local.id);

      if (success) {
        if (mounted) {
          if (widget.isFromSignup) {
            context.pushNamed(SignupConnectBankScreen.path);
          } else {
            CustomSnackbar.show(
              context,
              'Personality set to ${local.name}',
              type: SnackbarType.success,
            );
            context.pop();
          }
        }
      } else if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to update personality. Please try again.',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Error: ${e.toString()}',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(chatProvider.notifier).refresh();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (widget.isFromSignup)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: IconTextRowWidget(
                  'Skip',
                  AppIcon(AppIcons.arrowRightIcon),
                  reverse: true,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 12 * 0.02,
                  ),
                  onTap: () => context.pushNamed(SignupConnectBankScreen.path),
                ),
              ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: IntroText(
                  title: 'Choose your preferred AI Assistant',
                  subtitle:
                      'Our 7 bees are at your service. You can change personalities at anytime.',
                ),
              ),
              const Gap(24),

              // ── Hardcoded personality list ───────────────────────────────
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _kPersonalities.length,
                separatorBuilder: (_, __) => const Gap(16),
                itemBuilder: (context, index) =>
                    _buildPersonaListTile(_kPersonalities[index]),
              ),

              const Gap(16),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 24),
          child: CustomElevatedButton(
            text: _isUpdating ? 'Setting up...' : 'Select',
            showArrow: true,
            buttonColor: CustomButtonColor.black,
            onPressed: (_isUpdating || _selectedLocal == null)
                ? null
                : () => _selectPersonality(_selectedLocal!),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaListTile(_LocalPersonality persona) {
    final isSelected = _selectedLocal == persona;

    return CustomCard(
      onTap: () => setState(() => _selectedLocal = persona),
      borderColor: isSelected ? AppColors.black : AppColors.greyMid,
      borderWidth: isSelected ? 2 : 0.5,
      child: Row(
        children: [
          // ── Personality image ──────────────────────────────────────────
          Image.asset(persona.imagePath, width: 50, height: 50),
          const Gap(8),

          // ── Text column ────────────────────────────────────────────────
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role label (e.g. "The Budgeting Bee")
                Text(
                  persona.role,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 12 * 0.02,
                  ),
                ),
                // Name (e.g. "Penny")
                Text(
                  persona.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 16 * 0.02,
                  ),
                ),
                // Description
                Text(
                  persona.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 14 * 0.02,
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/utils/assets/illustrations.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../core/widgets/custom_snackbar.dart';
// import '../../../../core/widgets/custom_card.dart';
// import '../../../../core/widgets/intro_text.dart';
// import '../../../../features/auth/presentation/screens/post_signup/signup_connect_bank_screen.dart';

// import '../../../../core/utils/assets/app_icons.dart';
// import '../../../../core/widgets/icon_text_row_widget.dart';
// import '../../domain/models/personality.dart';
// import '../providers/chat_providers.dart';

// class ChoosePersonalityScreen extends ConsumerStatefulWidget {
//   static const String path = '/choose-personality';

//   final bool isFromSignup;

//   const ChoosePersonalityScreen({super.key, required this.isFromSignup});

//   @override
//   ConsumerState<ChoosePersonalityScreen> createState() =>
//       _ChoosePersonalityScreenState();
// }

// class _ChoosePersonalityScreenState
//     extends ConsumerState<ChoosePersonalityScreen> {
//   int _selectedPersonality = 0;
//   bool _isUpdating = false;
//   late PageController _pageController;

//   Personality? selectedPersonality;

//   final List<String> _characters = [
//     Illustrations.booAvatar,
//     Illustrations.bloom,
//     Illustrations.dash,
//     Illustrations.loki,
//     Illustrations.penny,
//     Illustrations.luna,
//     Illustrations.susu,
//   ];

//   final List<String> _avatars = [
//     Illustrations.booAvatar,
//     Illustrations.bloomAvatar,
//     Illustrations.dashAvatar,
//     Illustrations.lokiAvatar,
//     Illustrations.pennyAvatar,
//     Illustrations.lunaAvatar,
//     Illustrations.susuAvatar,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _selectedPersonality);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   /// Update personality and navigate to chat
//   Future<void> _selectPersonality(Personality selectedPersonality) async {
//     setState(() {
//       _isUpdating = true;
//     });

//     try {
//       // Update personality via repository
//       final chatRepository = ref.read(chatRepositoryProvider);

//       final success = await chatRepository.updatePersonality(
//         selectedPersonality.id,
//       );

//       if (success) {
//         // Show success message
//         if (mounted) {
//           if (widget.isFromSignup) {
//             context.pushNamed(SignupConnectBankScreen.path);
//           } else {
//             CustomSnackbar.show(
//               context,
//               'Personality set to ${selectedPersonality.name}',
//               type: SnackbarType.success,
//             );
//             // Navigate to chat screen
//             context.pop();
//           }
//         }
//       } else if (mounted) {
//         // Show error message
//         CustomSnackbar.show(
//           context,
//           'Failed to update personality. Please try again.',
//           type: SnackbarType.error,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         CustomSnackbar.show(
//           context,
//           'Error: ${e.toString()}',
//           type: SnackbarType.error,
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUpdating = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final personalities = ref.watch(aiPersonalityProvider);

//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) {
//         ref.read(chatProvider.notifier).refresh();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           actions: [
//             if (widget.isFromSignup)
//               Padding(
//                 padding: const EdgeInsets.only(left: 5),
//                 child: IconTextRowWidget(
//                   'Skip',
//                   AppIcon(AppIcons.arrowRightIcon),
//                   reverse: true,
//                   textStyle: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'GeneralSans',
//                     letterSpacing: 12 * 0.02,
//                   ),
//                   onTap: () {
//                     context.pushNamed(SignupConnectBankScreen.path);
//                   },
//                 ),
//               ),
//           ],
//         ),
//         extendBodyBehindAppBar: true,
//         body: personalities.when(
//           data: (data) {
//             if (data.isEmpty) {
//               return const Center(child: Text('No personalities available'));
//             }

//             // Ensure selected index is within bounds
//             if (_selectedPersonality >= data.length) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) {
//                   setState(() {
//                     _selectedPersonality = 0;
//                   });
//                 }
//               });
//             }

//             return SafeArea(
//               child: ListView(
//                 shrinkWrap: true,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: IntroText(
//                       title: 'Choose your preferred AI Assistant',
//                       subtitle:
//                           'Our 7 bees are at your service. You can change personalities at anytime.',
//                     ),
//                   ),
//                   const Gap(24),
//                   Expanded(
//                     child: ListView.separated(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemBuilder: (context, index) =>
//                           _buildPersonaListTile(data[index]),
//                       separatorBuilder: (context, index) => const Gap(16),
//                       itemCount: data.length,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//           error: (error, stackTrace) =>
//               const Center(child: Text('Error loading AI Personalities')),
//           loading: () => const Center(child: CircularProgressIndicator()),
//         ),
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.all(16).copyWith(bottom: 24),
//           child: CustomElevatedButton(
//             text: _isUpdating ? 'Setting up...' : 'Select',
//             showArrow: true,
//             buttonColor: CustomButtonColor.black,
//             onPressed: _isUpdating
//                 ? null
//                 : () => _selectPersonality(selectedPersonality!),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPersonaListTile(Personality persona) {
//     return CustomCard(
//       onTap: () {
//         setState(() {
//           selectedPersonality = persona;
//         });
//       },
//       borderColor: selectedPersonality == persona
//           ? AppColors.black
//           : AppColors.greyMid,
//       borderWidth: selectedPersonality == persona ? 2 : 0.5,
//       child: Row(
//         children: [
//           if (persona.image != null)
//             Image.asset(persona.image!, width: 50, height: 50),
//           const Gap(8),
//           Expanded(
//             child: Column(
//               spacing: 4,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   persona.id.split('_').join(' '),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.grey,
//                     fontFamily: 'GeneralSans',
//                     letterSpacing: 12 * 0.02,
//                   ),
//                 ),
//                 Text(
//                   persona.name,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     fontFamily: 'GeneralSans',
//                     letterSpacing: 16 * 0.02,
//                   ),
//                 ),
//                 Text(
//                   persona.description,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.grey,
//                     fontFamily: 'GeneralSans',
//                     letterSpacing: 14 * 0.02,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
