import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../widgets/game/game_button.dart';
import '../../widgets/game/game_settings_list_tile.dart';
import '../../widgets/game/game_text.dart';

class GameSettingsScreen extends ConsumerStatefulWidget {
  static const String path = '/game-settings';

  const GameSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GameSettingsScreenState();
}

class _GameSettingsScreenState extends ConsumerState<GameSettingsScreen> {
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gameBgLight,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavigationButtons(),
            Column(
              spacing: 16,
              children: [
                GameSettingsListTile(
                  title: 'Sound',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                GameSettingsListTile(
                  title: 'Music',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(),
            const SizedBox(),
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
              text: 'SETTINGS',
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
