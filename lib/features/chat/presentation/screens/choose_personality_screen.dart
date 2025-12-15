import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/breakpoints.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/signup_connect_bank_screen.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/utils/assets/logos.dart';
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
  Future<void> _selectPersonality(List<Personality> personalities) async {
    setState(() {
      _isUpdating = true;
    });

    final selectedPersonality = personalities[_selectedPersonality];

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

  void _onPersonalityChanged(int index) {
    setState(() {
      _selectedPersonality = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          title: Image.asset(Logos.logo, scale: 4),
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
                    fontFamily: Constants.neulisNeueFontFamily,
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

            final currentPersonality = data[_selectedPersonality];

            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Gap(24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          'Choose your AI\npersona',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            height: 0.9,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.neulisNeueFontFamily,
                          ),
                        ),
                        const Gap(16.0),
                        const Text(
                          'Select which finance persona best applies to you',
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 0.9),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  // Personality image - use image from personality data if available
                  Image.asset(
                    currentPersonality.image ??
                        (_selectedPersonality < _characters.length
                            ? _characters[_selectedPersonality]
                            : _characters[0]),
                    height: 200,
                    width: 200,
                  ),

                  // PageView with personality details
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: data.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedPersonality = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final personality = data[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Text(
                                personality.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.neulisNeueFontFamily,
                                ),
                              ),
                              const Gap(16.0),
                              CustomCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                bgColor: AppColors.primaryFaint.withValues(
                                  alpha: 0.6,
                                ),
                                borderColor: AppColors.primary,
                                child: Text(
                                  personality.id.replaceAll(r'_', ' '),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Gap(16.0),
                              SizedBox(
                                width: Breakpoints.screenWidth(context) / 1.2,
                                child: Text(
                                  personality.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.1,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  Column(
                    children: [
                      // Personality selector
                      _buildPersonalitySelector(data),

                      // Button above personality selector
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomElevatedButton(
                          text: _isUpdating ? 'Setting up...' : 'Select',
                          showArrow: true,
                          buttonColor: CustomButtonColor.black,
                          onPressed: _isUpdating
                              ? null
                              : () => _selectPersonality(data),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) =>
              const Center(child: Text('Error loading AI Personalities')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildPersonalitySelector(List<Personality> personalities) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(personalities.length, (index) {
          final personality = personalities[index];
          return GestureDetector(
            onTap: () => _onPersonalityChanged(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFaded,
                border: _selectedPersonality == index
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: personality.image != null
                  ? Image.asset(personality.image!, scale: 1.15)
                  : Image.asset(
                      index < _avatars.length ? _avatars[index] : _avatars[0],
                      height: 40,
                      width: 40,
                    ),
            ),
          );
        }),
      ),
    );
  }
}
