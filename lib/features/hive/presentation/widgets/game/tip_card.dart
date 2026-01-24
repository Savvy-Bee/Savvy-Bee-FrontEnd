import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/game_assets.dart';
import '../../../../../core/utils/constants.dart';

class TipCard extends StatelessWidget {
  final String text;
  final int tipNumber;
  final bool isUnlocked;

  const TipCard({
    super.key,
    required this.text,
    required this.tipNumber,
    this.isUnlocked = false,
  });

  void _showTipDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tip Dialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: _buildCardContent(isLarge: true),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent({bool isLarge = false}) {
    final scale = isLarge ? 1.8 : 1.0;

    return Transform.scale(
      scale: scale,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            GameAssets.terrainCardSvg,
            colorFilter: isUnlocked
                ? ColorFilter.mode(
                    AppColors.gameBgLight.withValues(alpha: 0.5),
                    BlendMode.srcATop,
                  )
                : null,
          ),
          if (!isUnlocked) SvgPicture.asset(GameAssets.starSingleSvg),
          if (isUnlocked)
            Positioned(
              top: 20,
              child: Column(
                children: [
                  SvgPicture.asset(GameAssets.starSingleSvg, height: 30),
                  const Gap(28),
                  Text(
                    'Tip #$tipNumber',
                    style: TextStyle(
                      fontSize: 16,
                      height: 0.9,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.londrinaSolidFontFamily,
                    ),
                  ),
                  const Gap(12),
                  SizedBox(
                    width: 130,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.londrinaSolidFontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? () => _showTipDialog(context) : null,
      child: _buildCardContent(),
    );
  }
}
