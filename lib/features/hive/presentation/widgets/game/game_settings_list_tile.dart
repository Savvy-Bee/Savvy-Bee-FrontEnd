import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'game_switch.dart';
import 'game_text.dart';

class GameSettingsListTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const GameSettingsListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GameText(text: title, fontSize: 40, outlineWidth: 2),
          GameSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
