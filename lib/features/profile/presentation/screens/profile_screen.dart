import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/utils/assets/avatars.dart';
import 'package:savvy_bee_mobile/core/widgets/main_wrapper.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/biometric_provider.dart';
import 'package:savvy_bee_mobile/features/home/domain/models/home_data.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/providers/nok_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/address_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/bvn_verification_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/nin_verification_screen.dart';
import 'package:savvy_bee_mobile/features/referral/presentation/screens/referral_screen.dart';
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

  // Optional parameter to trigger refresh
  final String? verificationStatus;

  const ProfileScreen({super.key, this.verificationStatus});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _showVerificationBanner = false;
  String _verificationMessage = '';

  @override
  void initState() {
    super.initState();

    if (widget.verificationStatus != null && widget.verificationStatus != '') {
      _onRefresh();
    }
  }

  String _getVerificationMessage(String status) {
    switch (status.toLowerCase()) {
      case 'nin_verified':
        return 'NIN verified successfully! 🎉';
      case 'bvn_verified':
        return 'BVN verified successfully! 🎉';
      case 'avatar_updated':
        return 'Avatar updated successfully! ✨';
      default:
        return 'Profile updated successfully!';
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(homeDataProvider);
    try {
      await ref.read(homeDataProvider.future);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }

  String _formatJoinedDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return 'Joined ${DateFormat('MMMM yyyy').format(date)}';
    } catch (e) {
      return 'Joined recently';
    }
  }

  // ── League icon resolver ─────────────────────────────────────────────────

  /// Returns the correct league badge asset path for [leagueName].
  /// Matching is case-insensitive and strips emoji / " League" suffixes.
  String _getLeagueIcon(String leagueName) {
    final normalised = leagueName
        .toLowerCase()
        .replaceAll(' league', '')
        .replaceAll(RegExp(r'[^\w\s]'), '') // strip emoji / punctuation
        .trim();

    switch (normalised) {
      case 'bumble':
        return 'assets/images/icons/LEAGUE ICONS/BUMBLE LEAGUE.png';
      case 'honey':
        return 'assets/images/icons/LEAGUE ICONS/HONEY LEAGUE.png';
      case 'mason':
        return 'assets/images/icons/LEAGUE ICONS/MASON LEAGUE.png';
      case 'orchid':
        return 'assets/images/icons/LEAGUE ICONS/ORCHID LEAGUE.png';
      case 'queen bee':
      case 'queenbee':
        return 'assets/images/icons/LEAGUE ICONS/QUEEN BEE.png';
      case 'queensguard':
      case 'queens guard':
        return 'assets/images/icons/LEAGUE ICONS/QUEENSGUARD.png';
      case 'royal':
        return 'assets/images/icons/LEAGUE ICONS/ROYAL LEAGUE.png';
      default:
        return 'assets/images/icons/LEAGUE ICONS/BUMBLE LEAGUE.png';
    }
  }

  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    final nokAsync = ref.watch(fetchNokProvider);

    return Scaffold(
      appBar: AppBar(actions: []),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: homeDataAsync.when(
              loading: () => const CustomLoadingWidget(),
              error: (error, stack) => CustomErrorWidget.error(
                subtitle: error.toString(),
                onRetry: () => ref.refresh(homeDataProvider),
              ),
              data: (response) {
                final data = response.data;
                final hiveStats = data.hive.stats;
                final hasNok = nokAsync.value != null;

                bool hasUnfinishedProfile =
                    _hasUnfinishedProfile(data, hasNok: hasNok);
                bool hasVerifiedNin = data.kyc.nin;
                bool hasVerifiedBvn = data.kyc.bvn;

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildAvatarSection(context, avatar: data.profilePhoto),
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
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                              letterSpacing: 24 * 0.02,
                            ),
                          ),
                          const Gap(8),
                          Row(
                            spacing: 8,
                            children: [
                              Text(
                                '@${data.username}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'GeneralSans',
                                  fontSize: 14,
                                  color: AppColors.greyDark,
                                  letterSpacing: 14 * 0.02,
                                ),
                              ),
                              Icon(Icons.circle, color: Colors.black, size: 4),
                              Text(
                                _formatJoinedDate(hiveStats.createdAt),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.greyDark,
                                  fontSize: 14,
                                  fontFamily: 'GeneralSans',
                                  letterSpacing: 14 * 0.02,
                                ),
                              ),
                            ],
                          ),
                          const Gap(24),
                          if (hasUnfinishedProfile) ...[
                            _buildCompleteProfileCard(
                              context,
                              data,
                              hasNok: hasNok,
                            ),
                            const Gap(24),
                          ],

                          SectionTitleWidget(title: 'Overview'),
                          const Gap(12),
                          Row(
                            spacing: 8,
                            children: [
                              _buildStatItem(
                                'Day streak',
                                hiveStats.streak.toString(),
                                Image.asset(
                                  'assets/images/other/SUN.png',
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                              _buildStatItem(
                                'Flowers',
                                hiveStats.flowers.toString(),
                                Image.asset(
                                  'assets/images/other/PINK FLOWER - CURRENCY.png',
                                  width: 28,
                                  height: 28,
                                ),
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
                                // ── Dynamic badge matched to league name ──
                                Image.asset(
                                  _getLeagueIcon(data.hive.league),
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              _buildStatItem(
                                'Honey drops',
                                hiveStats.honeyDrop.toString(),
                                Image.asset(
                                  Assets.honeyJar4,
                                  width: 24,
                                  height: 24,
                                ),
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
                              onTap: () =>
                                  context.pushNamed(AchievementsScreen.path),
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'GeneralSans',
                              ),
                              reverse: true,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const Gap(24),
                          Row(
                            spacing: 8,
                            children: data.hive.achievement.map((achievement) {
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
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Subscriptions coming soon',
                                        ),
                                      ),
                                    );
                                  },
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
                                  onTap: !data.kyc.nin
                                      ? () => context.pushNamed(
                                          NinVerificationScreen.path,
                                        )
                                      : () {},
                                  useDefaultTrailing: !data.kyc.nin,
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
                                  onTap: !data.kyc.bvn
                                      ? () => context.pushNamed(
                                          BvnVerificationScreen.path,
                                        )
                                      : () {},
                                  useDefaultTrailing: !data.kyc.bvn,
                                ),
                                const Divider(),
                                ProfileListTile(
                                  title: 'My Financial Health Status',
                                  iconPath: AppIcons.healthIcon,
                                  onTap: () => context.pushNamed(
                                    FinancialHealthScreen.path,
                                  ),
                                ),
                                const Divider(),
                                _BiometricTile(
                                  email: data.email,
                                ),
                                const Divider(),
                                ProfileListTile(
                                  title: 'Security',
                                  iconPath: AppIcons.homeSecureIcon,
                                  onTap: () =>
                                      context.pushNamed(SecurityScreen.path),
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
                                  title: 'Savvy Bee Library',
                                  iconPath: AppIcons.libraryIcon,
                                  onTap: () =>
                                      context.pushNamed(LibraryScreen.path),
                                ),
                                const Divider(),
                                ProfileListTile(
                                  title: 'Change App Icon',
                                  iconPath: AppIcons.appIconIcon,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Coming soon'),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(),
                                ProfileListTile(
                                  title: 'Referrals',
                                  iconPath: AppIcons
                                      .chatboxIcon, // swap for a referral/gift icon if available
                                  onTap: () =>
                                      context.pushNamed(ReferralScreen.path),
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
                                    ref
                                            .read(
                                              bottomNavIndexProvider.notifier,
                                            )
                                            .state =
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
          ),

          // Verification success banner
          if (_showVerificationBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 24),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          _verificationMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                            letterSpacing: 14 * 0.02,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _showVerificationBanner = false;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileCard(
    BuildContext context,
    HomeData data, {
    required bool hasNok,
  }) {
    final hasAvatar = data.profilePhoto.isNotEmpty;
    final hasAddress = data.kyc.address;
    const hasBiometric = false;
    const hasPIN = false;

    int completedCount = 0;
    if (hasAvatar) completedCount++;
    if (hasAddress) completedCount++;
    // if (hasNok) completedCount++;
    // if (hasBiometric) completedCount++;
    if (hasPIN) completedCount++;
    const totalCount = 3;

    final List<Map<String, dynamic>> incompleteItems = [];

    if (!hasAvatar) {
      incompleteItems.add({
        'icon': Icons.account_circle_outlined,
        'title': 'Choose your avatar',
        'subtitle': 'Personalise your profile',
        'onTap': () => context.pushNamed(ChooseAvatarScreen.path),
      });
    }

    if (!hasAddress) {
      incompleteItems.add({
        'icon': Icons.home_outlined,
        'title': 'Add your address',
        'subtitle': 'Required for full verification',
        'onTap': () => context.pushNamed(AddressScreen.path),
      });
    }

    // if (!hasNok) {
    //   incompleteItems.add({
    //     'icon': Icons.people_outline,
    //     'title': 'Add next of kin',
    //     'subtitle': 'Emergency contact information',
    //     'onTap': () => context.pushNamed(NextOfKinScreen.path),
    //   });
    // }

    // if (!hasBiometric) {
    //   incompleteItems.add({
    //     'icon': Icons.fingerprint,
    //     'title': 'Enable Biometric Login',
    //     'subtitle': '',
    //     'onTap': () {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Biometric setup coming soon')),
    //       );
    //     },
    //   });
    // }

    if (!hasPIN) {
      incompleteItems.add({
        'icon': Icons.book_outlined,
        'title': 'Setup your 6-digit PIN',
        'subtitle': '',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN setup coming soon')),
          );
        },
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPLETE PROFILE SETUP ($completedCount/$totalCount)',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w500,
            color: Color(0xFF828383),
            letterSpacing: 12 * 0.02,
          ),
        ),
          const Gap(16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFCFCFCF), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...incompleteItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == incompleteItems.length - 1;

                  return Column(
                    children: [
                      InkWell(
                        onTap: item['onTap'] as VoidCallback,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'GeneralSans',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        letterSpacing: 16 * 0.02,
                                      ),
                                    ),
                                    const Gap(2),
                                    Text(
                                      item['subtitle'] as String,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'GeneralSans',
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        letterSpacing: 10 * 0.02,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: const Color(0xFFE0E0E0),
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
    );
  }

  bool _hasUnfinishedProfile(HomeData data, {bool hasNok = false}) {
    final hasAvatar = data.profilePhoto.isNotEmpty;
    final hasAddress = data.kyc.address;
    const hasBiometric = false;
    const hasPIN = false;

    return !hasAvatar || !hasAddress || !hasNok || !hasBiometric || !hasPIN;
  }

  Widget _buildAvatarSection(BuildContext context, {required String avatar}) {
    return GestureDetector(
      onTap: () => context.pushNamed(ChooseAvatarScreen.path),
      child: Container(
        alignment: Alignment.bottomCenter,
        height: 130,
        child: avatar.isNotEmpty
            ? Image.asset(Avatars.getAvatar(avatar))
            : Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(Assets.profileBlank),
                  Icon(Icons.add, color: AppColors.white),
                ],
              ),
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
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 20 * 0.02,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF828383),
                      letterSpacing: 14 * 0.02,
                    ),
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

// ─── Biometric toggle tile ────────────────────────────────────────────────────

class _BiometricTile extends ConsumerWidget {
  final String email;
  const _BiometricTile({required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = ref.watch(biometricProvider);

    return ProfileListTile(
      title: 'Face ID / Fingerprint',
      iconPath: AppIcons.homeSecureIcon,
      useDefaultTrailing: false,
      trailing: biometric.isAuthenticating
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Transform.scale(
              scale: 0.5,
              child: Switch(
                value: biometric.isEnabled,
                onChanged: biometric.isAvailable
                    ? (value) => _toggle(context, ref, value)
                    : null,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryFaint,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ),
      onTap: biometric.isAvailable
          ? () => _toggle(context, ref, !biometric.isEnabled)
          : null,
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool enable) async {
    if (enable) {
      final success =
          await ref.read(biometricProvider.notifier).enableBiometrics(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Biometric login enabled'
                : ref.read(biometricProvider).errorMessage ??
                    'Could not enable biometrics'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } else {
      await ref.read(biometricProvider.notifier).disableBiometrics();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric login disabled'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
