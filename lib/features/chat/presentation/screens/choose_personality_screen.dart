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
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

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

  final List<Personality> _personalities = Personalities.all;

  final List<String> _characters = [
    Illustrations.loanBee,
    Illustrations.savingsBeePose2,
    Illustrations.interestBee,
    Illustrations.savingsBeePose1,
    Illustrations.savingsBeePose2,
    Illustrations.familyBee,
    Illustrations.familyBee,
  ];

  /// Update personality and navigate to chat
  Future<void> _selectPersonality() async {
    setState(() {
      _isUpdating = true;
    });

    final selectedPersonality = _personalities[_selectedPersonality];

    try {
      // Update personality via repository
      final chatRepository = ref.read(chatRepositoryProvider);

      final success = await chatRepository.updatePersonality(
        selectedPersonality.id,
      );

      if (success && mounted) {
        // Show success message
        CustomSnackbar.show(
          context,
          'Personality set to ${selectedPersonality.name}',
          type: SnackbarType.success,
        );

        // Navigate to chat screen
        context.pop();
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
    final currentPersonality = _personalities[_selectedPersonality];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: _getBackgroundColour(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    Text(
                      'Select which finance persona best applies to you',
                      textAlign: TextAlign.center,
                      style: const TextStyle(height: 0.9),
                    ),
                  ],
                ),
              ),

              // Personality image
              Image.asset(_characters[_selectedPersonality], scale: 2),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      currentPersonality.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    const Gap(16.0),
                    OutlinedCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      bgColor: AppColors.primaryFaint.withValues(alpha: 0.6),
                      borderColor: AppColors.primary,
                      child: Text(
                        'Motivational coach',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Gap(16.0),
                    SizedBox(
                      width: Breakpoints.screenWidth(context) / 1.2,
                      child: Text(
                        currentPersonality.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, height: 1.1),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  // Personality selector
                  _buildPersonalitySelector(),

                  // Button above personality selector
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomElevatedButton(
                      text: _isUpdating ? 'Setting up...' : 'Select',
                      showArrow: true,
                      buttonColor: CustomButtonColor.black,
                      onPressed: _isUpdating ? null : _selectPersonality,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColour() {
    return _selectedPersonality == 0
        ? AppColors.white
        : _selectedPersonality == 1
        ? AppColors.purple
        : _selectedPersonality == 2
        ? AppColors.primary
        : _selectedPersonality == 3
        ? AppColors.warning
        : _selectedPersonality == 4
        ? AppColors.success
        : _selectedPersonality == 5
        ? AppColors.warning
        : AppColors.error;
  }

  Widget _buildPersonalitySelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _personalities.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedPersonality = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              // padding: const EdgeInsets.all(8.0),
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
              child: Image.asset(_personalities[index].image!, scale: 1.15),
            ),
          ),
        ),
      ),
    );
  }
}
