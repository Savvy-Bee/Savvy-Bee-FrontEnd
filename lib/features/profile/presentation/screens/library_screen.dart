import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/profile_list_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  static String path = '/library';

  const LibraryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savvy Bee Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Learn a few things about Savvy Bee. more content will be published here soon.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Gap(16),
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileListTile(
                  title: 'About Savvy Bee',
                  iconPath: AppIcons.infoIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Visit FAQs',
                  iconPath: AppIcons.questionIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'How-to Videos',
                  iconPath: AppIcons.videoIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Savvy Bee Storybook',
                  iconPath: AppIcons.documentIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Terms of Use',
                  iconPath: AppIcons.documentIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Privacy Policy',
                  iconPath: AppIcons.documentIcon,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
