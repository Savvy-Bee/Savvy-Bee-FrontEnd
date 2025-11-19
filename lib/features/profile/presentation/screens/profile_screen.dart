import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/achievements_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/change_app_icon_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/choose_avatar_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/complete_profile_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/financial_health_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/library_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/next_of_kin_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/profile_list_tile.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/account_statement_screen.dart';

import '../../../../core/utils/assets/app_icons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static String path = '/profile';

  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined),
            style: Constants.collapsedButtonStyle,
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.settings_outlined)),
        ],
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            height: 130,
            decoration: BoxDecoration(color: AppColors.blue),
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.pushNamed(ChooseAvatarScreen.path),
                  child: Image.asset(Assets.profileBlank),
                ),
                Icon(Icons.add, color: AppColors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dany Targaryen',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const Gap(8),
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      '@dracarys.babe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                        color: AppColors.greyDark,
                      ),
                    ),
                    Icon(Icons.circle, color: AppColors.grey, size: 8),
                    Text(
                      'Joined November 2024',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyDark,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                CustomCard(
                  bgColor: AppColors.primaryFaded,
                  borderColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finish setting up!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '2 steps left',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyDark,
                        ),
                      ),
                      const Gap(28),
                      CustomElevatedButton(
                        text: 'Complete Profile',
                        isGamePlay: true,
                        onPressed: () =>
                            context.pushNamed(CompleteProfileScreen.path),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                SectionTitleWidget(title: 'Overview'),
                Row(
                  spacing: 8,
                  children: [
                    _buildStatItem(
                      'Day streak',
                      '4',
                      AppIcon(
                        AppIcons.checkIcon,
                        color: AppColors.primary,
                        useOriginal: true,
                      ),
                    ),
                    _buildStatItem(
                      'Day streak',
                      '120',
                      Image.asset(Illustrations.hiveFlower),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  spacing: 8,
                  children: [
                    _buildStatItem(
                      'League',
                      'Pollen',
                      Image.asset(
                        Assets.pollenLeagueBadge,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    _buildStatItem(
                      'Honey drops',
                      '100',
                      Image.asset(Assets.honeyJar4, width: 24, height: 24),
                    ),
                  ],
                ),
                const Gap(24),
                SectionTitleWidget(
                  title: 'Achievements',
                  actionWidget: IconTextRowWidget(
                    'VIEW ALL',
                    Icon(Icons.keyboard_arrow_right, color: AppColors.primary),
                    onTap: () => context.pushNamed(AchievementsScreen.path),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                      color: AppColors.primary,
                    ),
                    textDirection: TextDirection.rtl,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const Gap(24),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: GameCard(
                        child: Image.asset(Assets.bumblebeeLeagueBadge),
                      ),
                    ),
                    Expanded(
                      child: GameCard(
                        child: Image.asset(Assets.honeyLeagueBadge),
                      ),
                    ),
                    Expanded(
                      child: GameCard(
                        child: Image.asset(Assets.masonLeagueBadge),
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                GameCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileListTile(
                        title: 'Account info',
                        iconPath: AppIcons.documentIcon,
                        onTap: () {},
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Manage Subscription',
                        iconPath: AppIcons.bankNoteIcon,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                GameCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileListTile(
                        title: 'Verify NIN',
                        iconPath: AppIcons.verifiedUserIcon,
                        onTap: () {},
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Verify BVN',
                        iconPath: AppIcons.verifiedUserIcon,
                        onTap: () {},
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'My Financial Health Status',
                        iconPath: AppIcons.healthIcon,
                        onTap: () =>
                            context.pushNamed(FinancialHealthScreen.path),
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Generate Account Statement',
                        iconPath: AppIcons.documentIcon,
                        onTap: () =>
                            context.pushNamed(AccountStatementScreen.path),
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Enable Dark Mode',
                        iconPath: AppIcons.moonIcon,
                        onTap: () {},
                        useDefaultTrailing: false,
                        trailing: Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: false,
                            onChanged: (value) {},
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Security',
                        iconPath: AppIcons.homeSecureIcon,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                GameCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileListTile(
                        title: 'Next of Kin',
                        iconPath: AppIcons.personIcon,
                        onTap: () => context.pushNamed(NextOfKinScreen.path),
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'My Debit Cards & Linked Banks',
                        iconPath: AppIcons.creditCardIcon,
                        onTap: () {},
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Savvy Bee Library',
                        iconPath: AppIcons.libraryIcon,
                        onTap: () => context.pushNamed(LibraryScreen.path),
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Change App Icon',
                        iconPath: AppIcons.appIconIcon,
                        onTap: () =>
                            context.pushNamed(ChangeAppIconScreen.path),
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Contact Us',
                        iconPath: AppIcons.chatboxIcon,
                        onTap: () {},
                      ),
                      const Divider(),
                      ProfileListTile(
                        title: 'Log Out',
                        iconPath: AppIcons.logOutIcon,
                        onTap: () {},
                        textColor: AppColors.error,
                        useDefaultTrailing: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Widget icon) {
    return Expanded(
      child: GameCard(
        child: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                    height: 1.0,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
