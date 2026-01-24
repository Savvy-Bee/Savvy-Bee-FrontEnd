import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

class StreakSlider extends StatelessWidget {
  final int totalDays;
  final int currentDay;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;
  final double height;
  final double thumbSize;
  final List<int>? milestones; // Optional: specific days to show thumbs

  const StreakSlider({
    super.key,
    required this.totalDays,
    required this.currentDay,
    this.activeColor = AppColors.primary, // Yellow/Gold
    this.inactiveColor = AppColors.greyMid, // Light grey
    this.activeThumbColor = AppColors.primary,
    this.inactiveThumbColor = AppColors.greyMid,
    this.height = 12.0,
    this.thumbSize = 50.0,
    this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which days get thumbs
    final List<int> thumbDays =
        milestones ??
        List.generate(
          // Generate milestones at intervals (e.g., every 7 days)
          (totalDays / 7).ceil() + 1,
          (i) => i * 7,
        ).where((day) => day <= totalDays).toList();

    // Ensure the last day is always included
    if (!thumbDays.contains(totalDays)) {
      thumbDays.add(totalDays);
    }

    // Remove day 0 if it's present and not explicitly desired
    if (thumbDays.length > 1 && thumbDays.first == 0) {
      thumbDays.removeAt(0);
    }

    // Always include the currentDay if it's not already a milestone
    if (!thumbDays.contains(currentDay) &&
        currentDay > 0 &&
        currentDay <= totalDays) {
      thumbDays.add(currentDay);
      thumbDays.sort(); // Keep them in order
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - thumbSize;
        final dayWidth = totalWidth / totalDays;

        return SizedBox(
          height: thumbSize + 10,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Background track
              Positioned(
                left: thumbSize / 2,
                right: thumbSize / 2,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: inactiveColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),

              // Active track (progress)
              Positioned(
                left: thumbSize / 2,
                child: Container(
                  height: height,
                  width: (dayWidth * currentDay).clamp(0.0, totalWidth),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),

              // Thumbs for milestones
              ...thumbDays.map((day) {
                final isCompleted = day <= currentDay;
                final position = (thumbSize / 2) + (dayWidth * day);

                return Positioned(
                  left: position - (thumbSize / 2),
                  child: Container(
                    width: thumbSize / 2,
                    height: thumbSize / 2,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: _getBorder(isCompleted),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.black
                              : inactiveThumbColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Border _getBorder(bool isCompleted) {
    return Border(
      // The color logic remains the same, but must be applied to each side
      top: BorderSide(
        color: isCompleted ? activeThumbColor : inactiveThumbColor,
        width: 5.0,
      ),
      bottom: BorderSide(
        color: isCompleted ? activeThumbColor : inactiveThumbColor,
        width: 2,
      ),
      left: BorderSide(
        color: isCompleted ? activeThumbColor : inactiveThumbColor,
        width: 2,
      ),
      right: BorderSide(
        color: isCompleted ? activeThumbColor : inactiveThumbColor,
        width: 2,
      ),
    );
  }
}
