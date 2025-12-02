import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HexagonalButton extends StatelessWidget {
  final String number;
  final VoidCallback? onTap;
  final double size;
  final bool isCompleted;

  const HexagonalButton({
    super.key,
    required this.number,
    this.onTap,
    this.size = 120.0,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter: HexagonPainter(
          backgroundColor: _getBackgroundColor(isLocked),
          shadowColor: _getShadowColor(isLocked),
          borderColor: _getBorderColor(isLocked),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildContent(isLocked),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isLocked) {
    if (isLocked) {
      return Icon(Icons.lock, color: AppColors.grey, size: size * 0.35);
    } else if (isCompleted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(Icons.check_circle, color: AppColors.white, size: size * 0.25),
          // SizedBox(height: size * 0.05),
          Text(
            number,
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      );
    } else {
      return Text(
        number,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      );
    }
  }

  Color _getBackgroundColor(bool isLocked) {
    if (isLocked) {
      return AppColors.greyMid;
    } else if (isCompleted) {
      return AppColors.success; // Completed state color
    } else {
      return AppColors.primary;
    }
  }

  Color _getShadowColor(bool isLocked) {
    if (isLocked) {
      return AppColors.grey;
    } else if (isCompleted) {
      return AppColors.success.withValues(alpha: 0.7);
    } else {
      return AppColors.primaryDark;
    }
  }

  Color? _getBorderColor(bool isLocked) {
    if (isLocked) {
      return null;
    } else if (isCompleted) {
      return AppColors.white;
    } else {
      return AppColors.primaryDark;
    }
  }
}

class HexagonPainter extends CustomPainter {
  final Color backgroundColor;
  final Color shadowColor;
  final Color? borderColor;
  final double borderWidth;

  HexagonPainter({
    required this.backgroundColor,
    required this.shadowColor,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHexagonPath(size);
    final shadowPath = _createHexagonPath(size, shadowOffset: 6.0);

    // Draw shadow
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main hexagon
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Draw border if specified
    if (borderColor != null && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }
  }

  Path _createHexagonPath(Size size, {double shadowOffset = 0.0}) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;
    final angle = (3.14159 * 2) / 6;
    final cornerRadius = 8.0;
    final rotationOffset = 3.14159 / 2;

    final points = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final x =
          center.dx + radius * cos(angle * i - 3.14159 / 2 + rotationOffset);
      final y =
          center.dy +
          radius * sin(angle * i - 3.14159 / 2 + rotationOffset) +
          shadowOffset;
      points.add(Offset(x, y));
    }

    // Draw path with rounded corners
    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final prev = points[(i - 1 + points.length) % points.length];

      // Calculate direction vectors
      final toPrev = Offset(prev.dx - current.dx, prev.dy - current.dy);
      final toNext = Offset(next.dx - current.dx, next.dy - current.dy);

      final prevLength = sqrt(toPrev.dx * toPrev.dx + toPrev.dy * toPrev.dy);
      final nextLength = sqrt(toNext.dx * toNext.dx + toNext.dy * toNext.dy);

      final prevNorm = Offset(toPrev.dx / prevLength, toPrev.dy / prevLength);
      final nextNorm = Offset(toNext.dx / nextLength, toNext.dy / nextLength);

      final startPoint = Offset(
        current.dx + prevNorm.dx * cornerRadius,
        current.dy + prevNorm.dy * cornerRadius,
      );

      final endPoint = Offset(
        current.dx + nextNorm.dx * cornerRadius,
        current.dy + nextNorm.dy * cornerRadius,
      );

      if (i == 0) {
        path.moveTo(startPoint.dx, startPoint.dy);
      } else {
        path.lineTo(startPoint.dx, startPoint.dy);
      }

      path.quadraticBezierTo(current.dx, current.dy, endPoint.dx, endPoint.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) => false;
}
