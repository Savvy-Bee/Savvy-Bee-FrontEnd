import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';

class LeagueScreen extends ConsumerStatefulWidget {
  static String path = '/league';

  const LeagueScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Column(
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
                      'Orchid League',
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
                Text(
                  'Top 10 advance to the next league',
                  style: TextStyle(fontSize: 16, height: 1.0),
                ),
              ],
            ),
          ),
          const Gap(32),
          Expanded(
            child: ListView(
              children: [
                _buildListTile(isLeader: true),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                _buildListTile(),
                const Divider(height: 20),
                _buildPromotionZoneIndicator(),
                _buildListTile(),
                _buildListTile(),
              ],
            ),
          ),
        ],
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

  Widget _buildListTile({bool isLeader = false}) {
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
              Icon(Icons.onetwothree_sharp),
              CircleAvatar(),
              Text(
                'Joshua',
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
              Text('1000', style: TextStyle(fontSize: 16)),
              Image.asset(Illustrations.hiveFlower),
            ],
          ),
        ],
      ),
    );
  }
}
