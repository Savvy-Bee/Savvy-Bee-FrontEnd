import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/widgets/main_wrapper.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/assets/illustrations.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/custom_loading_widget.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/icon_text_row_widget.dart';
import '../../../../core/widgets/section_title_widget.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/providers/home_data_provider.dart';
import 'account_info_screen.dart';
import 'achievements_screen.dart';
import 'change_app_icon_screen.dart';
import 'choose_avatar_screen.dart';
import 'complete_profile_screen.dart';
import 'contact_us_screen.dart';
import 'financial_health_screen.dart';
import 'library_screen.dart';
import 'manage_subscription_screen.dart';
import 'next_of_kin_screen.dart';
import 'security/security_screen.dart';
import 'settings_screen.dart';
import '../widgets/profile_list_tile.dart';
import '../../../spend/presentation/screens/transactions/account_statement_screen.dart';
import '../../../../core/utils/assets/app_icons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String path = '/profile';

  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _formatJoinedDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return 'Joined ${DateFormat('MMMM yyyy').format(date)}';
    } catch (e) {
      return 'Joined recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined),
            style: Constants.collapsedButtonStyle,
          ),
          IconButton(
            onPressed: () => context.pushNamed(SettingsScreen.path),
            icon: Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: homeDataAsync.when(
        loading: () => const CustomLoadingWidget(),
        error: (error, stack) => CustomErrorWidget.error(
          subtitle: error.toString(),
          onRetry: () => ref.refresh(homeDataProvider),
        ),
        data: (response) {
          final data = response.data;
          final hiveStats = data.hive.stats;

          return ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              _buildAvatarSection(context),
              // Container(
              //   alignment: Alignment.bottomCenter,
              //   height: 130,
              //   decoration: BoxDecoration(color: AppColors.blue),
              //   child: Stack(
              //     alignment: Alignment.center,
              //     children: [
              //       GestureDetector(
              //         onTap: () => context.pushNamed(ChooseAvatarScreen.path),
              //         child: CircleAvatar(
              //           radius: 50,
              //           backgroundColor: Colors.transparent,
              //           backgroundImage:
              //               data.profilePhoto.isNotEmpty &&
              //                   !data.profilePhoto.startsWith('Dash') &&
              //                   !data.profilePhoto.startsWith('Luna')
              //               ? CachedNetworkImageProvider(data.profilePhoto)
              //               : null,
              //           child:
              //               data.profilePhoto.isEmpty ||
              //                   data.profilePhoto.startsWith('Dash') ||
              //                   data.profilePhoto.startsWith('Luna')
              //               ? Image.asset(Assets.profileBlank)
              //               : null,
              //         ),
              //       ),
              //       Positioned(
              //         bottom: 0,
              //         right: 0,
              //         child: Icon(Icons.add, color: AppColors.white),
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.firstName} ${data.lastName}',
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
                          '@${data.username}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            color: AppColors.greyDark,
                          ),
                        ),
                        Icon(Icons.circle, color: AppColors.grey, size: 8),
                        Text(
                          _formatJoinedDate(hiveStats.createdAt),
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
                          hiveStats.streak.toString(),
                          AppIcon(
                            AppIcons.checkIcon,
                            color: AppColors.primary,
                            useOriginal: true,
                          ),
                        ),
                        _buildStatItem(
                          'Flowers',
                          hiveStats.flowers.toString(),
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
                          data.hive.league
                              .replaceAll(' League', '')
                              .replaceAll('💧', '')
                              .trim(),
                          Image.asset(
                            Assets
                                .pollenLeagueBadge, // Logic to swap badge based on league name could go here
                            width: 24,
                            height: 24,
                          ),
                        ),
                        _buildStatItem(
                          'Honey drops',
                          hiveStats.honeyDrop.toString(),
                          Image.asset(Assets.honeyJar4, width: 24, height: 24),
                        ),
                      ],
                    ),
                    const Gap(24),
                    SectionTitleWidget(
                      title: 'Achievements',
                      actionWidget: IconTextRowWidget(
                        'VIEW ALL',
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: AppColors.primary,
                        ),
                        onTap: () => context.pushNamed(AchievementsScreen.path),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,

                          color: AppColors.primary,
                        ),
                        reverse: true,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const Gap(24),
                    Row(
                      spacing: 8,
                      children: data.hive.achievement.map((achievement) {
                        // Choose the asset whose name contains (case-insensitive) the achievement name
                        final asset = Assets.leagueNames.firstWhere(
                          (a) => a
                              .toLowerCase()
                              .split(' ')
                              .contains(achievement.name.toLowerCase()),
                          orElse: () => Assets.bumblebeeLeagueBadge,
                        );

                        return GameCard(child: Image.asset(asset));
                      }).toList(),
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
                            onTap: () =>
                                context.pushNamed(AccountInfoScreen.path),
                          ),
                          const Divider(),
                          ProfileListTile(
                            title: 'Manage Subscription',
                            iconPath: AppIcons.bankNoteIcon,
                            onTap: () => context.pushNamed(
                              ManageSubscriptionScreen.path,
                            ),
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
                            trailing: data.kyc.nin
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  )
                                : null,
                            onTap: () {},
                          ),
                          const Divider(),
                          ProfileListTile(
                            title: 'Verify BVN',
                            iconPath: AppIcons.verifiedUserIcon,
                            trailing: data.kyc.bvn
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  )
                                : null,
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
                              scale: 0.5,
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
                            onTap: () => context.pushNamed(SecurityScreen.path),
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
                            onTap: () =>
                                context.pushNamed(NextOfKinScreen.path),
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
                            onTap: () =>
                                context.pushNamed(ContactUsScreen.path),
                          ),
                          const Divider(),
                          ProfileListTile(
                            title: 'Log Out',
                            iconPath: AppIcons.logOutIcon,
                            onTap: () {
                              ref.read(authProvider.notifier).logout();
                              ref.read(bottomNavIndexProvider.notifier).state =
                                  0;
                              ref.invalidate(homeDataProvider);
                              context.goNamed(LoginScreen.path);
                            },
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
          );
        },
      ),
    );
  }

  Container _buildAvatarSection(BuildContext context) {
    return Container(
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,

                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
