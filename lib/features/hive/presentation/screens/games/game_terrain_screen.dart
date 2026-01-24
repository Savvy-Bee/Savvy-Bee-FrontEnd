import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/game_assets.dart';
import '../../widgets/game/game_button.dart';
import '../../widgets/game/game_text.dart';
import '../../widgets/game/terrain_card.dart';

class GameTerrainScreen extends ConsumerStatefulWidget {
  static const String path = '/game-terrain';

  const GameTerrainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GameTerrainScreenState();
}

class _GameTerrainScreenState extends ConsumerState<GameTerrainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gameBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavigationButtons(),
            const Gap(24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                TerrainCard(
                  starCount: 3,
                  onPressed: () {},
                  terrainName: 'HONEYPORT',
                  terrainImage: GameAssets.honeyPortBg,
                  isSelected: true,
                ),
                TerrainCard(
                  starCount: 3,
                  onPressed: () {},
                  terrainName: 'KHALIA SWAMPS',
                  terrainImage: GameAssets.khaliaSwampBg,
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
          GameText(
            text: 'CHOOSE\nTERRAIN',
            fontSize: 40,
            height: 0.9,
            outlineWidth: 2,
          ),
          GameButton(
            // onPressed: () {},
            buttonText: 'Next',
            isSmall: true,
          ),
        ],
      ),
    );
  }
}
