import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  static const String path = '/achievements';

  const AchievementsScreen({super.key});

  /// Map achievement names from API to asset paths
  String _getAchievementAsset(String achievementName) {
    final normalized = achievementName.toLowerCase().trim();

    // Match based on keywords in the achievement name
    if (normalized.contains('7') ||
        normalized.contains('day') ||
        normalized.contains('streak')) {
      return 'assets/images/acheivements/7 DAY STREAK.png';
    } else if (normalized.contains('busy') ||
        normalized.contains('bee') ||
        normalized.contains('badge')) {
      return 'assets/images/acheivements/BUSY BEE BADGE.png';
    } else if (normalized.contains('buzzing') ||
        normalized.contains('beginner') ||
        normalized.contains('first')) {
      return 'assets/images/acheivements/BUZZING BEGINNER.png';
    } else if (normalized.contains('pollen') ||
        normalized.contains('pro') ||
        normalized.contains('master')) {
      return 'assets/images/acheivements/POLLEN PRO.png';
    } else if (normalized.contains('susu') ||
        normalized.contains('flight') ||
        normalized.contains('welcome')) {
      return 'assets/images/acheivements/SUSU FIRST FLIGHT.png';
    }

    // Fallback to first achievement image
    return 'assets/images/acheivements/BUZZING BEGINNER.png';
  }

  /// Get friendly description based on achievement name
  String _getAchievementDescription(String achievementName) {
    final normalized = achievementName.toLowerCase().trim();

    if (normalized.contains('7') || normalized.contains('day')) {
      return 'Keep going! Stay consistent';
    } else if (normalized.contains('busy') || normalized.contains('30')) {
      return 'Active for 30 days';
    } else if (normalized.contains('beginner') ||
        normalized.contains('first')) {
      return 'You\'ve started your journey';
    } else if (normalized.contains('pro') || normalized.contains('master')) {
      return 'Master level achieved';
    } else if (normalized.contains('welcome') || normalized.contains('susu')) {
      return 'Welcome to SavvyBee!';
    }

    return 'Achievement unlocked!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Achievements',
          style: TextStyle(fontFamily: 'GeneralSans'),
        ),
      ),
      body: homeDataAsync.when(
        loading: () => const Center(child: CustomLoadingWidget()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const Gap(16),
                const Text(
                  'Failed to load achievements',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const Gap(8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (homeResponse) {
          final achievements = homeResponse.data.hive.achievement;

          // Show empty state if no achievements
          if (achievements.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/other/BLUE FLOWER - Flight Boost.png',
                      width: 140,
                      height: 140,
                    ),
                    const Gap(24),
                    const Text(
                      'No achievements yet',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Gap(12),
                    const Text(
                      'Keep using the app, complete goals, and maintain your streak — achievements will appear here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14,
                        color: AppColors.textLight,
                        height: 1.4,
                        letterSpacing: 0.28,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Horizontal scroll view with achievements from API
          return Column(
            children: [
              const Gap(24),

              // Achievement count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${achievements.length}',
                      style: const TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.64,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Achievement${achievements.length == 1 ? '' : 's'}\nUnlocked',
                      style: const TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(32),

              // Horizontal scrollable achievement cards
              Expanded(
                child: PageView.builder(
                  itemCount: achievements.length,
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final assetPath = _getAchievementAsset(achievement.name);
                    final description = _getAchievementDescription(
                      achievement.name,
                    );

                    return _buildAchievementCard(
                      achievement.name,
                      description,
                      assetPath,
                      context,
                    );
                  },
                ),
              ),

              const Gap(24),

              // Page indicator dots
              if (achievements.length > 1)
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      achievements.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),

              // Helper text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  achievements.length > 1
                      ? 'Swipe to see all your achievements'
                      : 'Keep going to unlock more achievements!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    color: AppColors.grey,
                    letterSpacing: 0.24,
                  ),
                ),
              ),

              const Gap(32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(
    String name,
    String description,
    String assetPath,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Achievement image with glow effect
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(assetPath, fit: BoxFit.contain),
                ),
              ),

              const Gap(32),

              // Achievement name
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.48,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Gap(12),

              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 14,
                  color: AppColors.textLight,
                  letterSpacing: 0.28,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Gap(20),

              // Unlocked badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.success, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.success,
                    ),
                    Gap(8),
                    Text(
                      'Unlocked',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                        letterSpacing: 0.28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';

// class AchievementsScreen extends ConsumerWidget {
//   static const String path = '/achievements';

//   const AchievementsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final homeDataAsync = ref.watch(homeDataProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Achievements',
//           style: TextStyle(fontFamily: 'GeneralSans'),
//         ),
//       ),
//       body: homeDataAsync.when(
//         loading: () => const Center(child: CustomLoadingWidget()),
//         error: (err, stack) => Center(
//           child: Text(
//             'Failed to load achievements\n${err.toString()}',
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontFamily: 'GeneralSans',
//               color: AppColors.error,
//             ),
//           ),
//         ),
//         data: (homeResponse) {
//           final achievements = homeResponse.data.hive.achievement;

//           if (achievements.isEmpty) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 32),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset(
//                       'assets/images/other/BLUE FLOWER - Flight Boost.png', // ← add a nice empty illustration if you have one
//                       width: 140,
//                       height: 140,
//                     ),
//                     const Gap(24),
//                     const Text(
//                       'No achievements yet',
//                       style: TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 20 * 0.02,
//                       ),
//                     ),
//                     const Gap(12),
//                     const Text(
//                       'Keep using the app, complete goals, and maintain your streak — achievements will appear here!',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 14,
//                         color: AppColors.textLight,
//                         height: 1.4,
//                         letterSpacing: 14 * 0.02,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Wrap(
//               spacing: 16,
//               runSpacing: 24,
//               alignment: WrapAlignment.center,
//               children: achievements.map((ach) {
//                 // Find matching badge asset
//                 final index = Assets.leagueNames.indexWhere(
//                   (name) => name.toLowerCase().contains(
//                     ach.name.toLowerCase().replaceAll(' league', ''),
//                   ),
//                 );

//                 final asset = index != -1
//                     ? Assets.leagueBadges[index]
//                     : Assets.bumblebeeLeagueBadge; // fallback

//                 return SizedBox(
//                   width: (MediaQuery.sizeOf(context).width - 48) / 3,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       GameCard(child: Image.asset(asset, fit: BoxFit.contain)),
//                       const Gap(12),
//                       Text(
//                         ach.name,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           height: 1.2,
//                           letterSpacing: 14 * 0.02,
//                         ),
//                       ),
//                       Text(
//                         'Unlocked',
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 12,
//                           color: AppColors.textLight,
//                           height: 1.2,
//                           letterSpacing: 12 * 0.02,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
