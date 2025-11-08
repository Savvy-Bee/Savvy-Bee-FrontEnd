import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  /// A value between 0.0 and 1.0 representing the progress.
  final double progress;
  final String currentAmount;
  final String totalBudget;
  final double size;

  const CustomCircularProgressIndicator({
    super.key,
    required this.progress,
    required this.currentAmount,
    required this.totalBudget,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    const double strokeWidth = 40.0;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The custom painter for the arcs
          CustomPaint(
            painter: CircularProgressPainter(
              progress: progress,
              trackColor: AppColors.primaryFaint.withValues(alpha: 0.8),
              progressColor: AppColors.primary,
              strokeWidth: strokeWidth,
            ),
          ),
          // The central white circle with text content
          Container(
            margin: const EdgeInsets.all(strokeWidth),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              boxShadow: [
                // Soft shadow to lift the center off the page
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(8),
                Text(
                  currentAmount,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                const Gap(4),
                Text(
                  totalBudget,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter to draw the background track and the progress arc.
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius is half the size, adjusted for the stroke width
    final radius = (size.width - strokeWidth) / 2;

    // Paint for the background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Paint for the progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // This creates the rounded ends

    // Draw the full background track (a full circle)
    canvas.drawCircle(center, radius, trackPaint);

    // Define the bounding box for the arc
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Define the angles
    const startAngle = -pi / 2; // Start at the top (12 o'clock)
    final sweepAngle = progress * 2 * -pi; // Sweep angle based on progress

    // Draw the progress arc
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false, // Do not close the path
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    // Repaint if any of the properties change
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
