import 'dart:math';

import 'package:flutter/material.dart';

/// Data model for each segment in the multi-segment progress indicator.
class SegmentData {
  final Color color;
  final double value; // A value representing its proportion of the total.

  SegmentData({required this.color, required this.value});
}

/// A widget that displays a multi-segment circular progress indicator.
///
/// It shows multiple colored arcs representing different proportions,
/// and displays custom text in the center.
class MultiSegmentCircularProgressIndicator extends StatelessWidget {
  final List<SegmentData> segments;
  final String centerAmount;
  final String centerLabel;
  final double size;

  const MultiSegmentCircularProgressIndicator({
    super.key,
    required this.segments,
    required this.centerAmount,
    required this.centerLabel,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    // Proportional values based on the overall size
    final double strokeWidth = size / 7.0; // ~40.0 for size 280
    final double amountFontSize = size / 8.75; // ~32.0 for size 280
    final double labelFontSize = size / 23.33; // ~12.0 for size 280
    final double gap = size / 70.0; // ~4.0 for size 280
    final double shadowBlurRadius = size / 14.0; // ~20.0 for size 280
    final double shadowOffsetY = size / 56.0; // ~5.0 for size 280

    // A fixed angular gap between segments (in radians)
    const double gapAngle = 0.05; // ~2.86 degrees per gap

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: MultiSegmentCircularProgressPainter(
              segments: segments,
              strokeWidth: strokeWidth,
              gapAngle: gapAngle,
            ),
          ),
          Container(
            margin: EdgeInsets.all(strokeWidth),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: shadowBlurRadius,
                  offset: Offset(0, shadowOffsetY),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  centerAmount,
                  style: TextStyle(
                    fontSize: amountFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: gap),
                Text(
                  centerLabel,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
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

/// CustomPainter to draw multiple colored arcs with gaps and subtle rounded corners.
class MultiSegmentCircularProgressPainter extends CustomPainter {
  final List<SegmentData> segments;
  final double strokeWidth;
  final double gapAngle;

  MultiSegmentCircularProgressPainter({
    required this.segments,
    required this.strokeWidth,
    this.gapAngle = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - strokeWidth;

    // Subtle corner radius - not fully rounded, just slightly rounded
    final cornerRadius =
        strokeWidth * 0.15; // Adjust this value: 0.1-0.3 for subtle rounding

    final totalValue = segments.fold(
      0.0,
      (sum, segment) => sum + segment.value,
    );
    final totalAngleForSegments = (2 * pi) - (segments.length * gapAngle);

    double currentStartAngle = -pi / 2;

    for (var segment in segments) {
      final sweepAngle = (segment.value / totalValue) * totalAngleForSegments;

      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      final path = _createRoundedSegmentPath(
        center,
        innerRadius,
        outerRadius,
        cornerRadius,
        currentStartAngle,
        sweepAngle,
      );

      canvas.drawPath(path, segmentPaint);

      currentStartAngle += sweepAngle + gapAngle;
    }
  }

  /// Creates a path for a segment with subtly rounded corners
  Path _createRoundedSegmentPath(
    Offset center,
    double innerRadius,
    double outerRadius,
    double cornerRadius,
    double startAngle,
    double sweepAngle,
  ) {
    final path = Path();
    final endAngle = startAngle + sweepAngle;

    // Calculate the four corner points
    final innerStart = Offset(
      center.dx + innerRadius * cos(startAngle),
      center.dy + innerRadius * sin(startAngle),
    );
    final outerStart = Offset(
      center.dx + outerRadius * cos(startAngle),
      center.dy + outerRadius * sin(startAngle),
    );
    final outerEnd = Offset(
      center.dx + outerRadius * cos(endAngle),
      center.dy + outerRadius * sin(endAngle),
    );
    final innerEnd = Offset(
      center.dx + innerRadius * cos(endAngle),
      center.dy + innerRadius * sin(endAngle),
    );

    // Start at the inner start point, offset for the corner
    path.moveTo(
      innerStart.dx + cornerRadius * cos(startAngle - pi / 2),
      innerStart.dy + cornerRadius * sin(startAngle - pi / 2),
    );

    // Top-left corner (inner start to outer start)
    path.quadraticBezierTo(
      innerStart.dx,
      innerStart.dy,
      innerStart.dx + cornerRadius * cos(startAngle),
      innerStart.dy + cornerRadius * sin(startAngle),
    );

    // Line to outer start (with corner offset)
    path.lineTo(
      outerStart.dx - cornerRadius * cos(startAngle),
      outerStart.dy - cornerRadius * sin(startAngle),
    );

    // Top-right corner (to outer arc)
    path.quadraticBezierTo(
      outerStart.dx,
      outerStart.dy,
      outerStart.dx + cornerRadius * cos(startAngle + pi / 2),
      outerStart.dy + cornerRadius * sin(startAngle + pi / 2),
    );

    // Outer arc
    path.arcTo(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle + asin(cornerRadius / outerRadius),
      sweepAngle - 2 * asin(cornerRadius / outerRadius),
      false,
    );

    // Bottom-right corner (outer end to inner end)
    final outerEndOffset = Offset(
      outerEnd.dx - cornerRadius * cos(endAngle + pi / 2),
      outerEnd.dy - cornerRadius * sin(endAngle + pi / 2),
    );
    path.lineTo(outerEndOffset.dx, outerEndOffset.dy);

    path.quadraticBezierTo(
      outerEnd.dx,
      outerEnd.dy,
      outerEnd.dx - cornerRadius * cos(endAngle),
      outerEnd.dy - cornerRadius * sin(endAngle),
    );

    // Line to inner end
    path.lineTo(
      innerEnd.dx + cornerRadius * cos(endAngle),
      innerEnd.dy + cornerRadius * sin(endAngle),
    );

    // Bottom-left corner (back to start)
    path.quadraticBezierTo(
      innerEnd.dx,
      innerEnd.dy,
      innerEnd.dx - cornerRadius * cos(endAngle + pi / 2),
      innerEnd.dy - cornerRadius * sin(endAngle + pi / 2),
    );

    // Inner arc (reverse direction)
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      endAngle - asin(cornerRadius / innerRadius),
      -sweepAngle + 2 * asin(cornerRadius / innerRadius),
      false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(
    covariant MultiSegmentCircularProgressPainter oldDelegate,
  ) {
    if (oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gapAngle != gapAngle ||
        oldDelegate.segments.length != segments.length) {
      return true;
    }
    for (int i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].color != segments[i].color ||
          oldDelegate.segments[i].value != segments[i].value) {
        return true;
      }
    }
    return false;
  }
}
