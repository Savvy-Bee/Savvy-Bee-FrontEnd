import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

import '../../widgets/game/game_button.dart';
import '../../widgets/game/game_text.dart';
import '../../widgets/game/tip_card.dart';

class GameTipsScreen extends ConsumerStatefulWidget {
  static const String path = '/game-tips';

  const GameTipsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameTipsScreenState();
}

class _GameTipsScreenState extends ConsumerState<GameTipsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gameBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavigationButtons(),
            const Gap(16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                TipCard(
                  text:
                      'Start small. Save a little from every harvest, just like collecting flowers',
                  tipNumber: 1,
                  isUnlocked: true,
                ),
                TipCard(
                  text:
                      'Start small. Save a little from every harvest, just like collecting flowers',
                  tipNumber: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GameButton(
            onPressed: () => context.pop(),
            buttonText: 'Back',
            isSmall: true,
          ),
          Expanded(
            flex: 3,
            child: GameText(
              text: 'TIPS (6)',
              fontSize: 40,
              height: 0.9,
              outlineWidth: 2,
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
