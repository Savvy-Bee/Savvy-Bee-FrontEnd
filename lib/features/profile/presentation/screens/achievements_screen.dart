import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  static String path = '/achievements';

  const AchievementsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Achievements')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8, // Horizontal spacing between items
          runSpacing: 16, // Vertical spacing between lines
          children: List.generate(
            Assets.leagueBadges.length,
            (index) => SizedBox(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width:
                        (MediaQuery.of(context).size.width - 32 - 16) /
                        3, // 32 for padding, 16 for spacing between 3 items
                    child: GameCard(
                      child: Image.asset(Assets.leagueBadges[index]),
                    ),
                  ),
                  const Gap(12),
                  Text(
                    Assets.leagueNames[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'League',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: Constants.neulisNeueFontFamily,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
