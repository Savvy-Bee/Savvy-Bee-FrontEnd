import 'dart:ui';

import 'package:flutter/material.dart';

Widget imageShadowEffect(String imagePath, {double? scale}) {
  return Stack(
    children: [
      // Shadow layer
      Transform.translate(
        offset: const Offset(0, -5), // Shadow offset
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.3),
            BlendMode.srcATop,
          ),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Image.asset(imagePath, scale: scale),
          ),
        ),
      ),
      // Original image
      Image.asset(imagePath, scale: scale),
    ],
  );
}
