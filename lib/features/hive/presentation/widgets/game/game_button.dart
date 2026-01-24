import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import '../../../../../core/utils/assets/game_assets.dart';
import '../../../../../core/utils/constants.dart';

class GameButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String buttonText;

  const GameButton({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.isSmall = false,
  });

  final bool isSmall;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = widget.isSmall ? 20 : 40;

    List<double> colorMatrix = [
      0.3,
      0.3,
      0.3,
      0,
      0,
      0.3,
      0.3,
      0.3,
      0,
      0,
      0.3,
      0.3,
      0.3,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: widget.onPressed == null ? 0.8 : 1.0,
              child: SvgPicture.asset(
                GameAssets.gameButtonSvg,
                height: widget.isSmall ? 40 : null,
                colorFilter: widget.onPressed == null
                    ? ColorFilter.matrix(colorMatrix)
                    : null,
              ),
            ),
            Positioned(
              top: widget.isSmall ? 3 : 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outline
                  Text(
                    widget.buttonText,
                    style: TextStyle(
                      fontSize: fontSize + 1,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w900,
                      fontFamily: Constants.londrinaSolidFontFamily,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = AppColors.primaryDark,
                    ),
                  ),
                  // Foreground text
                  Text(
                    widget.buttonText,
                    style: TextStyle(
                      fontSize: fontSize,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w900,
                      fontFamily: Constants.londrinaSolidFontFamily,
                      color: AppColors.white,
                    ),
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
