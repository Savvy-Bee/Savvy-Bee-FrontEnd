import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';

// Renamed from HoneyProgressIndicator and using your new asset logic
class ArcProgressIndicator extends StatelessWidget {
  /// The progress value, from 0.0 to 1.0.
  final double progress;

  /// The size (width and height) of the widget.
  final double size;

  /// The thickness of the progress arc.
  final double strokeWidth;

  /// Color
  final Color color;

  /// Optional Content
  final Widget? content;

  const ArcProgressIndicator({
    super.key,
    required this.progress,
    this.size = 300.0,
    this.strokeWidth = 30.0,
    required this.color,
    this.content,
  });

  /// Selects the correct honey jar image based on the progress.
  String _getHoneyJarImage(double progress) {
    if (progress <= 0.0) {
      return Assets.honeyJar;
    } else if (progress <= 0.25) {
      return Assets.honeyJar;
    } else if (progress <= 0.50) {
      return Assets.honeyJar;
    } else if (progress <= 0.75) {
      return Assets.honeyJar;
    } else {
      return Assets.honeyJar;
    }
  }

  @override
  Widget build(BuildContext context) {
    String jarImage = _getHoneyJarImage(progress);
    double jarSize = size * 0.35; // Make the jar smaller than the arc

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Custom Painter for the arcs
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _ArcProgressIndicatorPainter(
                // Renamed from _HoneyArcPainter
                progress: progress,
                strokeWidth: strokeWidth,
                color: color,
              ),
            ),
          ),
          // 2. The Honey Jar Image
          // Positioned so its top is at the center line (baseline of the arc)
          Positioned(
            top:
                size /
                4, // Position top of image at the canvas' vertical center
            child:
                content ??
                SizedBox(
                  // Use SizedBox to constrain the image size
                  width: jarSize,
                  height: jarSize,
                  child: Image.asset(
                    jarImage,
                    width: jarSize,
                    height: jarSize,
                    // Add a fallback in case the image fails to load
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: jarSize,
                        height: jarSize,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey.shade400,
                          size: jarSize * 0.5,
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

// Renamed from _HoneyArcPainter
class _ArcProgressIndicatorPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _ArcProgressIndicatorPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Center of the canvas
    final Offset center = Offset(size.width / 2, size.height / 2);
    // Radius of the arc
    final double radius = (size.width - strokeWidth) / 2;
    // The bounding rectangle for the arc
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Angles are in radians.
    // 0 rad = 3 o'clock
    // We want to start at 9 o'clock (180 deg) and end at 3 o'clock (0 or 360 deg)
    // Total arc sweep is 180 degrees (pi)

    // --- FIX: Start angle is 180 degrees (9 o'clock) ---
    const double startAngle = math.pi; // 180 degrees
    // --- FIX: Sweep angle is 180 degrees (a perfect semi-circle) ---
    const double sweepAngle = math.pi; // 180 degrees

    // --- 1. Draw the background arc (the "empty" part) ---
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Rounded ends

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // --- 2. Draw the progress arc (the "full" part) ---
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Rounded ends

    // Calculate the sweep for the progress
    final double progressSweep = sweepAngle * progress.clamp(0.0, 1.0);

    canvas.drawArc(rect, startAngle, progressSweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcProgressIndicatorPainter oldDelegate) {
    // Repaint only if the progress has changed
    return oldDelegate.progress != progress;
  }
}
