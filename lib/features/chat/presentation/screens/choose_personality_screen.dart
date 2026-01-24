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

  Personality? selectedPersonality;

  final List<String> _characters = [
    Illustrations.booAvatar,
    Illustrations.bloom,
    Illustrations.dash,
    Illustrations.loki,
    Illustrations.penny,
    Illustrations.luna,
    Illustrations.susu,
  ];

  final List<String> _avatars = [
    Illustrations.booAvatar,
    Illustrations.bloomAvatar,
    Illustrations.dashAvatar,
    Illustrations.lokiAvatar,
    Illustrations.pennyAvatar,
    Illustrations.lunaAvatar,
    Illustrations.susuAvatar,
  ];

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

  /// Update personality and navigate to chat
  Future<void> _selectPersonality(Personality selectedPersonality) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Update personality via repository
      final chatRepository = ref.read(chatRepositoryProvider);

      final success = await chatRepository.updatePersonality(
        selectedPersonality.id,
      );

      if (success) {
        // Show success message
        if (mounted) {
          if (widget.isFromSignup) {
            context.pushNamed(SignupConnectBankScreen.path);
          } else {
            CustomSnackbar.show(
              context,
              'Personality set to ${selectedPersonality.name}',
              type: SnackbarType.success,
            );
            // Navigate to chat screen
            context.pop();
          }
        }
      } else if (mounted) {
        // Show error message
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
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalities = ref.watch(aiPersonalityProvider);

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
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    context.pushNamed(SignupConnectBankScreen.path);
                  },
                ),
              ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: personalities.when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(child: Text('No personalities available'));
            }

            // Ensure selected index is within bounds
            if (_selectedPersonality >= data.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedPersonality = 0;
                  });
                }
              });
            }

            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: IntroText(
                      title: 'Choose your preferred AI Assistant',
                      subtitle:
                          'Our 7 bees are at your service. You can change personalities at anytime.',
                    ),
                  ),
                  const Gap(24),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) =>
                          _buildPersonaListTile(data[index]),
                      separatorBuilder: (context, index) => const Gap(16),
                      itemCount: data.length,
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) =>
              const Center(child: Text('Error loading AI Personalities')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 24),
          child: CustomElevatedButton(
            text: _isUpdating ? 'Setting up...' : 'Select',
            showArrow: true,
            buttonColor: CustomButtonColor.black,
            onPressed: _isUpdating
                ? null
                : () => _selectPersonality(selectedPersonality!),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaListTile(Personality persona) {
    return CustomCard(
      onTap: () {
        setState(() {
          selectedPersonality = persona;
        });
      },
      borderColor: selectedPersonality == persona
          ? AppColors.primaryDark
          : AppColors.greyMid,
      child: Row(
        children: [
          if (persona.image != null)
            Image.asset(persona.image!, width: 50, height: 50),
          const Gap(8),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona.id.split('_').join(' '),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  persona.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  persona.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
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
