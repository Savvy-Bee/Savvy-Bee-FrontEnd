import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/profile_list_tile.dart';

import '../../../../core/widgets/game_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const String path = '/settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileListTile(
                  title: 'Sound effects',
                  iconPath: AppIcons.moonIcon,
                  useDefaultTrailing: false,
                  trailing: Transform.scale(
                    scale: 0.5,
                    child: Switch(
                      value: false,
                      onChanged: (value) {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Divider(height: 0),

                ProfileListTile(
                  title: 'Notifications',
                  iconPath: AppIcons.moonIcon,
                  useDefaultTrailing: false,
                  trailing: Transform.scale(
                    scale: 0.5,
                    child: Switch(
                      value: false,
                      onChanged: (value) {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Divider(height: 0),

                ProfileListTile(
                  title: 'Reminders',
                  iconPath: AppIcons.moonIcon,
                  useDefaultTrailing: false,
                  trailing: Transform.scale(
                    scale: 0.5,
                    child: Switch(
                      value: false,
                      onChanged: (value) {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
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
