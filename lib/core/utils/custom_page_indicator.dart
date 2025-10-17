import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// --- Custom Indicator Painter ---
class PreviousColoredDotPainter extends BasicIndicatorPainter {
  final BasicIndicatorEffect effect;

  PreviousColoredDotPainter({
    required this.effect,
    required int count,
    required double offset,
  }) : super(offset, count, effect);

  @override
  void paint(Canvas canvas, Size size) {
    final SlideEffect slideEffect = effect as SlideEffect;

    final int activeIndex = offset.floor();
    final double dotWidth = slideEffect.dotWidth;
    final double dotHeight = slideEffect.dotHeight;
    final double spacing = slideEffect.spacing;
    final double initialX = dotWidth / 2;
    final double centerY = size.height / 2;
    final double totalDotWidth = dotWidth + spacing;
    final double halfHeight = dotHeight / 2;

    final Radius cornerRadius = Radius.circular(dotHeight / 2);

    final Paint paint = Paint();

    // Draw all the dots
    for (int i = 0; i < count; i++) {
      // The critical coloring logic:
      if (i <= activeIndex) {
        // Dot is the active one OR has already been passed -> PRIMARY COLOR
        paint.color = slideEffect.activeDotColor;
      } else {
        // Dot is in the future -> DEFAULT COLOR
        paint.color = slideEffect.dotColor;
      }

      // Calculate the center x position for the current dot
      final double xPos = initialX + (i * totalDotWidth);

      // Draw the dot (a rounded rectangle)
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          xPos - dotWidth / 2,
          centerY - halfHeight,
          xPos + dotWidth / 2,
          centerY + halfHeight,
          topLeft: cornerRadius,
          topRight: cornerRadius,
          bottomLeft: cornerRadius,
          bottomRight: cornerRadius,
        ),
        paint,
      );
    }
  }
}

// --- Custom Indicator Effect (Remains the same) ---
// This is critical as it passes an object that IS a SlideEffect (and thus BasicIndicatorEffect)
class PreviousColoredSlideEffect extends SlideEffect {
  const PreviousColoredSlideEffect({
    super.dotHeight = 5.0,
    super.dotWidth = 5.0,
    super.spacing,
    super.activeDotColor = Colors.blue,
    super.dotColor,
  });

  @override
  IndicatorPainter buildPainter(int count, double offset) {
    // Use the custom painter
    return PreviousColoredDotPainter(
      count: count,
      offset: offset,
      effect: this,
    );
  }
}
