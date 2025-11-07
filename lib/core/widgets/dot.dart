import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Dot extends StatelessWidget {
  final double? size;
  final Color? color;
  const Dot({super.key, this.size = 8, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
