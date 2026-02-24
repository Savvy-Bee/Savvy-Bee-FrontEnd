import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  static const String path = '/achievements';

  const AchievementsScreen({super.key});

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
          child: Text(
            'Failed to load achievements\n${err.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              color: AppColors.error,
            ),
          ),
        ),
        data: (homeResponse) {
          final achievements = homeResponse.data.hive.achievement;

          if (achievements.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      Assets
                          .bumblebeeLeagueBadge, // ← add a nice empty illustration if you have one
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
                        letterSpacing: 20 * 0.02,
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
                        letterSpacing: 14 * 0.02,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: achievements.map((ach) {
                // Find matching badge asset
                final index = Assets.leagueNames.indexWhere(
                  (name) => name.toLowerCase().contains(
                    ach.name.toLowerCase().replaceAll(' league', ''),
                  ),
                );

                final asset = index != -1
                    ? Assets.leagueBadges[index]
                    : Assets.bumblebeeLeagueBadge; // fallback

                return SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 48) / 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GameCard(child: Image.asset(asset, fit: BoxFit.contain)),
                      const Gap(12),
                      Text(
                        ach.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 14 * 0.02,
                        ),
                      ),
                      Text(
                        'Unlocked',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12,
                          color: AppColors.textLight,
                          height: 1.2,
                          letterSpacing: 12 * 0.02,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
