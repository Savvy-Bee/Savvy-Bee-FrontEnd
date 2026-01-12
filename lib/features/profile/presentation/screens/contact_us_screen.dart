import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/profile_list_tile.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  static const String path = '/contact-us';

  const ContactUsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Come say hi!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text("We'd love to hear from you.", style: TextStyle(fontSize: 12)),
          const Gap(24),
          Image.asset(Assets.happyBees),
          const Gap(24),
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileListTile(
                  title: 'Email',
                  iconPath: AppIcons.emailIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'WhatsApp',
                  iconPath: AppIcons.whatsAppIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Twitter',
                  iconPath: AppIcons.twitterIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Instagram',
                  iconPath: AppIcons.instagramIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Tiktok',
                  iconPath: AppIcons.tiktokIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'LinkedIn',
                  iconPath: AppIcons.linkedinIcon,
                  onTap: () {},
                ),
                const Divider(),
                ProfileListTile(
                  title: 'Telegram',
                  iconPath: AppIcons.telegramIcon,
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
