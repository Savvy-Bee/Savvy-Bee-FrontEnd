import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/leaderboard.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/providers/leaderboard_provider.dart';

class LeagueScreen extends ConsumerStatefulWidget {
  static String path = '/league';

  const LeagueScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboardAsync.when(
        skipLoadingOnRefresh: false,
        loading: () =>
            const CustomLoadingWidget(text: 'Fetching leaderboard...'),
        error: (error, stack) => CustomErrorWidget.error(
          subtitle: error.toString(),
          onRetry: () => ref.invalidate(leaderboardProvider),
        ),
        data: (data) {
          final validEntries = data.hive
              .where((e) => e.userID != null)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.league,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.neulisNeueFontFamily,
                          ),
                        ),
                        IconTextRowWidget(
                          '6Days',
                          textStyle: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          Icon(Icons.access_time, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Gap(8),
                    const Text(
                      'Top 10 advance to the next league',
                      style: TextStyle(fontSize: 16, height: 1.0),
                    ),
                  ],
                ),
              ),
              const Gap(32),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(leaderboardProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: validEntries.length + 1,
                    itemBuilder: (context, index) {
                      // Show promotion zone indicator after 10th position
                      if (index == 10 && validEntries.length > 10) {
                        return Column(
                          children: [
                            const Divider(height: 20),
                            _buildPromotionZoneIndicator(),
                          ],
                        );
                      }

                      // Adjust index if we're past the promotion zone indicator
                      final entryIndex = index > 10 ? index - 1 : index;

                      if (entryIndex >= validEntries.length) {
                        return const SizedBox.shrink();
                      }

                      final entry = validEntries[entryIndex];
                      return _buildListTile(
                        entry: entry,
                        rank: entryIndex + 1,
                        isLeader: entryIndex == 0,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPromotionZoneIndicator() {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_upward_sharp, color: AppColors.primary, size: 24),
        Text(
          'Promotion Zone',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: Constants.neulisNeueFontFamily,
            color: AppColors.primary,
          ),
        ),
        Icon(Icons.arrow_upward_sharp, color: AppColors.primary, size: 24),
      ],
    );
  }

  Widget _buildListTile({
    required LeaderboardEntry entry,
    required int rank,
    bool isLeader = false,
  }) {
    final user = entry.userID;
    if (user == null) return const SizedBox.shrink();

    final displayName = '${user.firstName} ${user.lastName}'.trim();

    // Determine rank display widget
    Widget rankWidget;
    if (rank == 1) {
      rankWidget = SvgPicture.asset(
        Assets.leaderboardFirstPlace,
        width: 24,
        height: 24,
      );
    } else if (rank == 2) {
      rankWidget = SvgPicture.asset(
        Assets.leaderboardSecondPlace,
        width: 24,
        height: 24,
      );
    } else if (rank == 3) {
      rankWidget = SvgPicture.asset(
        Assets.leaderboardThirdPlace,
        width: 24,
        height: 24,
      );
    } else {
      // Positions 4-10 are success color, 11+ are primary color
      rankWidget = Text(
        '$rank',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: rank <= 10 ? AppColors.success : AppColors.primary,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: isLeader ? AppColors.primaryFaint : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              rankWidget,
              CircleAvatar(
                backgroundImage:
                    user.profilePhoto.isNotEmpty &&
                        !user.profilePhoto.startsWith('Dash') &&
                        !user.profilePhoto.startsWith('Luna')
                    ? CachedNetworkImageProvider(user.profilePhoto)
                    : null,
                child:
                    user.profilePhoto.isEmpty ||
                        user.profilePhoto.startsWith('Dash') ||
                        user.profilePhoto.startsWith('Luna')
                    ? Text(user.firstName[0].toUpperCase())
                    : null,
              ),
              Text(
                displayName.isNotEmpty ? displayName : user.username,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.flowers.toString(), style: TextStyle(fontSize: 16)),
              const Gap(4),
              Image.asset(Illustrations.hiveFlower, width: 24, height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
