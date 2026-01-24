import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/game_assets.dart';

class GameSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GameSwitch({super.key, required this.value, required this.onChanged});

  @override
  State<GameSwitch> createState() => _GameSwitchState();
}

class _GameSwitchState extends State<GameSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GameSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                  left: widget.value ? 12 : 30,
                  right: widget.value ? 30 : 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.value ? "ON" : "OFF",
                  key: ValueKey(widget.value),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                right: widget.value ? null : 55,
                left: widget.value ? 45 : null,
                child: SvgPicture.asset(GameAssets.pointsButtonSvg),
              ),
            ],
          );
        },
      ),
    );
  }
}
