import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class LeaguePromotionScreen extends ConsumerStatefulWidget {
  static const String path = '/league-promotion';

  const LeaguePromotionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LeaguePromotionScreenState();
}

class _LeaguePromotionScreenState extends ConsumerState<LeaguePromotionScreen> {
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
                // TODO: Add images
                Text(
                  "Congratulations! You were promoted to this week's Orchid League.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,

                    height: 1.0,
                  ),
                ),
              ],
            ),
            CustomElevatedButton(
              text: 'Continue',
              isGamePlay: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
