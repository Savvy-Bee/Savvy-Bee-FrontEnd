import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../features/dashboard/presentation/screens/dashboard_screen.dart';

class CustomDonutChart extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final double total;

  const CustomDonutChart({
    super.key,
    required this.categories,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: DonutChartPainter(categories, total),
            size: const Size(200, 200),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₦${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Spent this month',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<ExpenseCategory> categories;
  final double total;

  DonutChartPainter(this.categories, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 32.0;
    final gapAngle = 0.08; // Gap between segments in radians

    double startAngle = -math.pi / 2;

    for (var category in categories) {
      // Calculate sweep angle minus the gap
      final sweepAngle = (category.amount / total) * 2 * math.pi - gapAngle;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Move to next segment (including the gap)
      startAngle += sweepAngle + gapAngle;
    }

    // Draw inner white circle for the donut hole
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - strokeWidth - 5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
