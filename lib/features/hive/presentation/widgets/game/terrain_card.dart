import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

import '../../../../../core/utils/assets/game_assets.dart';
import 'game_text.dart';

class TerrainCard extends StatelessWidget {
  final int starCount;
  final VoidCallback? onPressed;
  final String terrainName;
  final String terrainImage;
  final bool isSelected;

  const TerrainCard({
    super.key,
    required this.starCount,
    this.onPressed,
    required this.terrainName,
    required this.terrainImage,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(GameAssets.terrainCardSvg),
        if (isSelected) SvgPicture.asset(GameAssets.terrainCardOutlineSvg),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryDark, width: 4),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage(terrainImage),
          ),
        ),
        Positioned(
          top: 25,
          child: GameText(
            text: terrainName,
            fontSize: 24,
            height: 1,
            outlineWidth: 2,
          ),
        ),
        Positioned(bottom: 30, child: SvgPicture.asset(GameAssets.starFullSvg)),
      ],
    );
  }
}
