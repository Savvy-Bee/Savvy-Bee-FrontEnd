import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';

class CustomLineChart extends StatelessWidget {
  final List<ChartDataPoint> data;

  const CustomLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomPaint(
          painter: LineChartPainter(data),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Custom painter that renders a simple line chart with month labels.
class LineChartPainter extends CustomPainter {
  /// Data points to plot: each contains a numeric value and a month label.
  final List<ChartDataPoint> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // Nothing to draw if no data is provided.
    if (data.isEmpty) return;

    // Configure the line appearance: stroke with rounded ends and joins.
    final paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Build the path that traces the data points.
    final path = Path();

    // Compute vertical scale: map data values to canvas height.
    final maxValue = data.map((e) => e.value).reduce(math.max);
    final minValue = data.map((e) => e.value).reduce(math.min);
    final range = maxValue - minValue;

    // Iterate through each data point to calculate its canvas position.
    for (int i = 0; i < data.length; i++) {
      // Horizontal position evenly distributed across the width.
      final x = (size.width / (data.length - 1)) * i;

      // Normalize the value to a 0–1 range, then map to 80 % of canvas height
      // with 10 % top padding for aesthetic spacing.
      final normalizedValue = (data[i].value - minValue) / range;
      final y =
          size.height -
          (normalizedValue * size.height * 0.8) -
          size.height * 0.1;

      // Start or extend the path.
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Render the completed line.
    canvas.drawPath(path, paint);

    // Draw months
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Render each month label centered below its corresponding data point.
    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      textPainter.text = TextSpan(
        text: data[i].month,
        style: const TextStyle(color: AppColors.greyDark, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 8),
      );
    }
  }

  // Always repaint: chart is simple and data may change frequently.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
