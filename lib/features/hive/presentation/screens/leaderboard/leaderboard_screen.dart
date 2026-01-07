import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/leaderboard/league_screen.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  static String path = '/leaderboard';

  const LeaderboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Illustrations.leaderboardBee),
                const Gap(8),
                Text(
                  'Welcome to\nLeaderboards!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                const Gap(8),
                Text(
                  'Join other bees in a weekly contest.\nEarn flowers from quizzes and tasks to climb the ranks!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.0),
                ),
              ],
            ),
            CustomElevatedButton(
              text: 'Continue',
              isGamePlay: true,
              onPressed: () => context.pushReplacementNamed(LeagueScreen.path),
            ),
          ],
        ),
      ),
    );
  }
}
