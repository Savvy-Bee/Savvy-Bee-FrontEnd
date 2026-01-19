import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/theme/app_colors.dart';

/// A responsive, reusable line chart widget with range filtering
class CustomLineChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final Color primaryColor, valueIndicatorColor;
  final bool showRangeSelector;
  final double? height;
  final Function(TimeRange)? onRangeChanged;
  final String? title;
  final bool enableValueIndicator;

  const CustomLineChart({
    super.key,
    required this.data,
    this.primaryColor = AppColors.success,
    this.valueIndicatorColor = Colors.white,
    this.showRangeSelector = true,
    this.height,
    this.onRangeChanged,
    this.title,
    this.enableValueIndicator = false,
  });

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  TimeRange _selectedRange = TimeRange.oneMonth;
  int? _selectedPointIndex;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    final filteredData = _filterDataByRange(widget.data, _selectedRange);

    return Container(
      height: widget.height ?? 250,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: widget.data.isEmpty
                ? Center(child: Text('No data available'))
                : GestureDetector(
                    onTapDown: widget.enableValueIndicator
                        ? (details) => _handleTap(details, filteredData)
                        : null,
                    onPanUpdate: widget.enableValueIndicator
                        ? (details) => _handlePan(details, filteredData)
                        : null,
                    onPanEnd: widget.enableValueIndicator
                        ? (_) => setState(() {
                            _selectedPointIndex = null;
                            _tapPosition = null;
                          })
                        : null,
                    child: _ChartPainter(
                      data: filteredData,
                      primaryColor: widget.primaryColor,
                      valueIndicatorColor: widget.valueIndicatorColor,
                      selectedPointIndex: _selectedPointIndex,
                      tapPosition: _tapPosition,
                      enableValueIndicator: widget.enableValueIndicator,
                    ),
                  ),
          ),
          if (widget.showRangeSelector) _buildRangeSelector(),
        ],
      ),
    );
  }

  void _handleTap(TapDownDetails details, List<ChartDataPoint> data) {
    if (data.isEmpty) return;

    setState(() {
      _tapPosition = details.localPosition;
      _selectedPointIndex = _findNearestPoint(details.localPosition, data);
    });
  }

  void _handlePan(DragUpdateDetails details, List<ChartDataPoint> data) {
    if (data.isEmpty) return;

    setState(() {
      _tapPosition = details.localPosition;
      _selectedPointIndex = _findNearestPoint(details.localPosition, data);
    });
  }

  int _findNearestPoint(Offset position, List<ChartDataPoint> data) {
    final chartWidth = context.size?.width ?? 0;
    final normalizedX = position.dx / chartWidth;
    final index = (normalizedX * (data.length - 1)).round().clamp(
      0,
      data.length - 1,
    );
    return index;
  }

  Widget _buildRangeSelector() {
    final borderRadius = BorderRadius.circular(16);

    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: TimeRange.values.map((range) {
          final isSelected = range == _selectedRange;
          return InkWell(
            onTap: () {
              setState(() => _selectedRange = range);
              widget.onRangeChanged?.call(range);
            },
            borderRadius: borderRadius,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFaint,
                borderRadius: borderRadius,
                border: isSelected
                    ? Border.all(color: AppColors.primary)
                    : null,
              ),
              child: Text(
                range.label,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<ChartDataPoint> _filterDataByRange(
    List<ChartDataPoint> data,
    TimeRange range,
  ) {
    final now = DateTime.now();
    final cutoff = now.subtract(range.duration);

    return data.where((point) => point.timestamp.isAfter(cutoff)).toList();
  }
}

class _ChartPainter extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color primaryColor, valueIndicatorColor;
  final int? selectedPointIndex;
  final Offset? tapPosition;
  final bool enableValueIndicator;

  const _ChartPainter({
    required this.data,
    required this.primaryColor,
    required this.valueIndicatorColor,
    this.selectedPointIndex,
    this.tapPosition,
    required this.enableValueIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        data: data,
        primaryColor: primaryColor,
        valueIndicatorColor: valueIndicatorColor,
        selectedPointIndex: selectedPointIndex,
        enableValueIndicator: enableValueIndicator,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color primaryColor, valueIndicatorColor;
  final int? selectedPointIndex;
  final bool enableValueIndicator;

  _LineChartPainter({
    required this.data,
    required this.primaryColor,
    this.valueIndicatorColor = Colors.white,
    this.selectedPointIndex,
    required this.enableValueIndicator,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (data.isEmpty) return;

    final minValue = data.map((e) => e.value).reduce(math.min);
    final maxValue = data.map((e) => e.value).reduce(math.max);
    final valueRange = maxValue - minValue;

    const padding = EdgeInsets.zero;
    final chartWidth = canvasSize.width;
    final chartHeight = canvasSize.height;

    _drawChart(
      canvas,
      canvasSize,
      padding,
      chartWidth,
      chartHeight,
      minValue,
      valueRange,
    );

    if (enableValueIndicator &&
        selectedPointIndex != null &&
        selectedPointIndex! < data.length) {
      _drawValueIndicator(
        canvas,
        canvasSize,
        padding,
        chartWidth,
        chartHeight,
        minValue,
        valueRange,
      );
    }
  }

  void _drawChart(
    Canvas canvas,
    Size canvasSize,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
    double minValue,
    double valueRange,
  ) {
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // primaryColor.withValues(alpha: 0.3), // Initial value for gradient
              primaryColor.withValues(alpha: 0.0),
              primaryColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ).createShader(
            Rect.fromLTWH(padding.left, padding.top, chartWidth, chartHeight),
          )
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = padding.left + (chartWidth * i / (data.length - 1));
      final normalizedValue = valueRange > 0
          ? (data[i].value - minValue) / valueRange
          : 0.5;
      final y = padding.top + chartHeight * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, canvasSize.height - padding.bottom);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(
      padding.left + chartWidth,
      canvasSize.height - padding.bottom,
    );
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawValueIndicator(
    Canvas canvas,
    Size canvasSize,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
    double minValue,
    double valueRange,
  ) {
    final index = selectedPointIndex!;
    final dataPoint = data[index];

    final x = padding.left + (chartWidth * index / (data.length - 1));
    final normalizedValue = valueRange > 0
        ? (dataPoint.value - minValue) / valueRange
        : 0.5;
    final y = padding.top + chartHeight * (1 - normalizedValue);

    // Draw circle at the point
    final circlePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final circleOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(x, y), 5, circlePaint);
    canvas.drawCircle(Offset(x, y), 5, circleOutlinePaint);

    // Draw value label
    final textSpan = TextSpan(
      text: dataPoint.value.toStringAsFixed(2),
      style: TextStyle(
        color: valueIndicatorColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Create background for the label
    final labelPadding = 8.0;
    final labelWidth = textPainter.width + labelPadding * 2;
    final labelHeight = textPainter.height + labelPadding;

    // Position label above the point
    double labelX = x - labelWidth / 2;
    double labelY = y - labelHeight - 10;

    // Adjust if label goes out of bounds
    if (labelX < padding.left) {
      labelX = padding.left;
    } else if (labelX + labelWidth > canvasSize.width - padding.right) {
      labelX = canvasSize.width - padding.right - labelWidth;
    }

    if (labelY < padding.top) {
      labelY = y + 10; // Position below the point instead
    }

    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight),
      const Radius.circular(6),
    );

    final labelPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(labelRect, labelPaint);

    // Draw the text
    textPainter.paint(
      canvas,
      Offset(labelX + labelPadding, labelY + labelPadding / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.selectedPointIndex != selectedPointIndex;
  }
}

/// Chart data point
class ChartDataPoint {
  final DateTime timestamp;
  final double value;

  ChartDataPoint({required this.timestamp, required this.value});
}

/// Time range options
enum TimeRange {
  threeDays(Duration(days: 3), '3D'),
  oneWeek(Duration(days: 7), '1W'),
  oneMonth(Duration(days: 30), '1M'),
  threeMonths(Duration(days: 90), '3M'),
  sixMonths(Duration(days: 180), '6M'),
  oneYear(Duration(days: 365), '1Y');

  final Duration duration;
  final String label;

  const TimeRange(this.duration, this.label);
}
