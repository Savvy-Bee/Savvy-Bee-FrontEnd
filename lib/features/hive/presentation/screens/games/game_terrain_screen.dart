import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../widgets/game/game_button.dart';

class GameTerrainScreen extends ConsumerStatefulWidget {
  static const String path = '/game-terrain';

  const GameTerrainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GameTerrainScreenState();
}

class _GameTerrainScreenState extends ConsumerState<GameTerrainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gameBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameButton(
                    onPressed: () {},
                    buttonText: 'Back',
                    isSmall: true,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outline
                      Text(
                        "CHOOSE\nTERRAIN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          letterSpacing: 1,
                          height: 0.9,
                          fontWeight: FontWeight.w900,
                          fontFamily: Constants.londrinaSolidFontFamily,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = AppColors.primaryDark,
                        ),
                      ),
                      // Foreground text
                      Text(
                        "CHOOSE\nTERRAIN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          letterSpacing: 1,
                          height: 0.9,
                          fontWeight: FontWeight.w900,
                          fontFamily: Constants.londrinaSolidFontFamily,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  GameButton(
                    // onPressed: () {},
                    buttonText: 'Next',
                    isSmall: true,
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
