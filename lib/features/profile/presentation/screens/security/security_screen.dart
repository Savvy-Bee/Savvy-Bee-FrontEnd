import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/security/change_password_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/security/change_pin_screen.dart';

import '../../../../../core/utils/assets/app_icons.dart';
import '../../../../../core/widgets/game_card.dart';
import '../../widgets/profile_list_tile.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  static const String path = '/security';

  const SecurityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GameCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileListTile(
                  title: 'Enable Fingerprint/Face ID',
                  iconPath: AppIcons.infoIcon,
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
                  title: 'Change PIN',
                  iconPath: AppIcons.infoIcon,
                  onTap: () => context.pushNamed(ChangePinScreen.path),
                ),
                const Divider(height: 0),
                ProfileListTile(
                  title: 'Change Password',
                  iconPath: AppIcons.infoIcon,
                  onTap: () => context.pushNamed(ChangePasswordScreen.path),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
