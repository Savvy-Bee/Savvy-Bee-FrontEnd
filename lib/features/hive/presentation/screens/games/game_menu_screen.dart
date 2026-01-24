import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/assets/game_assets.dart';
import '../../../../../core/utils/constants.dart';
import '../../widgets/game/game_button.dart';
import 'game_terrain_screen.dart';

class GameMenuScreen extends ConsumerStatefulWidget {
  static const String path = '/game-menu';

  const GameMenuScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameMenuScreenState();
}

class _GameMenuScreenState extends ConsumerState<GameMenuScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GameAssets.startScreenBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(GameAssets.pointsButtonSvg, height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        '350',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.londrinaSolidFontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(GameAssets.gameLogo),
              GameButton(
                onPressed: () {
                  context.pushNamed(GameTerrainScreen.path);
                },
                buttonText: 'START',
              ),
              GameButton(onPressed: () {}, buttonText: 'TIPS'),
              GameButton(onPressed: () {}, buttonText: 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }
}
