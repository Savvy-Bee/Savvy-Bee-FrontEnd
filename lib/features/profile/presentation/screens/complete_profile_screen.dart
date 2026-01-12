import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/choose_avatar_screen.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  static const String path = '/complete-profile';

  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListTile(
                  'Choose your avatar',
                  AppIcons.personIcon,
                  onTap: () => context.pushNamed(ChooseAvatarScreen.path),
                ),
                const Divider(),
                _buildListTile(
                  'Verify your identity',
                  AppIcons.verifiedUserIcon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, String iconPath, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(iconPath, color: onTap == null ? AppColors.grey : null),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: Constants.neulisNeueFontFamily,
                    color: onTap == null ? AppColors.grey : null,
                    decoration: onTap == null
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}
