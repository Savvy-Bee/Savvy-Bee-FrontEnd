import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/streak/new_streak_screen.dart';

import '../../widgets/streak_slider.dart';

class StreakDashboardScreen extends ConsumerStatefulWidget {
  static String path = '/streak';

  const StreakDashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StreakDashboardScreenState();
}

class _StreakDashboardScreenState extends ConsumerState<StreakDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak'),
        backgroundColor: AppColors.primary,
        surfaceTintColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(NewStreakScreen.path),
            icon: AppIcon(AppIcons.shareIcon, size: 20),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            color: AppColors.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStreakNumber('23'),
                        Text(
                          'day streak!',
                          style: TextStyle(
                            color: AppColors.primaryExtraDark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.neulisNeueFontFamily,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(Illustrations.matchingBeeSmile),
                  ],
                ),
                const Gap(24),
                _buildMessageCard(
                  'Congrats on reaching your latest streak milestone!',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                SectionTitleWidget(title: 'Streak challenge'),
                const Gap(16),
                _buildStreakCard(),
                const Gap(24),
                SectionTitleWidget(title: 'November 2025'),
                const Gap(16),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Days practiced',
                        '4',
                        AppIcons.checkIcon,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Freezes used',
                        '0',
                        AppIcons.freezeIcon,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                CustomCalendar(
                  year: 2025,
                  month: 11, // 1-12 (12 = December)
                  highlightedDates: [
                    [1, 7], // Highlight dates 1-7
                    [15, 21], // Highlight dates 15-21
                    25, // Single date
                  ],
                  specialDate: 24, // Gray circle indicator
                  onDateTap: (date) {
                    print('Tapped: $date');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String iconPath) {
    return GameCard(
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(iconPath, color: AppColors.primary, useOriginal: true),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                  height: 1.0,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return GameCard(
      padding: const EdgeInsets.all(16).copyWith(bottom: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7 Day Challenge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              Text(
                'Day 4 of 7',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const Gap(8),
          StreakSlider(totalDays: 7, currentDay: 4),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return GameCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(Assets.trophySvg),
          const Gap(16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: Constants.neulisNeueFontFamily,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakNumber(String number) {
    return Stack(
      children: [
        // Outline
        Text(
          number,
          style: TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w500,
            fontFamily: Constants.neulisNeueFontFamily,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12
              ..color = AppColors.primaryDark,
            height: 1.0,
          ),
        ),
        // Fill
        Text(
          number,
          style: TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w500,
            fontFamily: Constants.neulisNeueFontFamily,
            color: Colors.white, // Fill color
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class CustomCalendar extends StatelessWidget {
  final int year;
  final int month;
  final List<dynamic> highlightedDates;
  final int? specialDate;
  final Function(int)? onDateTap;

  const CustomCalendar({
    super.key,
    required this.year,
    required this.month,
    this.highlightedDates = const [],
    this.specialDate,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.grey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDaysOfWeekHeader(),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    const daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Row(
      children: daysOfWeek.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: AppColors.greyDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = DateTime(year, month + 1, 0).day;

    List<Widget> dayWidgets = [];

    // Empty cells before first day
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(height: 48));
    }

    // Actual days
    for (int date = 1; date <= daysInMonth; date++) {
      dayWidgets.add(_buildDayCell(date));
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int date) {
    final highlighted = _isHighlighted(date);
    final position = _getRangePosition(date);
    final isSpecial = date == specialDate;

    return Stack(
      children: [
        // Background highlight
        if (highlighted)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFaded,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(
                    position == 'start' || position == 'single' ? 24 : 0,
                  ),
                  right: Radius.circular(
                    position == 'end' || position == 'single' ? 24 : 0,
                  ),
                ),
              ),
            ),
          ),
        // Date number
        Center(
          child: GestureDetector(
            onTap: () => onDateTap?.call(date),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSpecial ? Colors.grey.shade300 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSpecial
                        ? Colors.grey.shade700
                        : highlighted
                        ? const Color(0xFFD97706) // Yellow-600
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isHighlighted(int date) {
    for (var range in highlightedDates) {
      if (range is List && range.length == 2) {
        if (date >= range[0] && date <= range[1]) {
          return true;
        }
      } else if (range is int && date == range) {
        return true;
      }
    }
    return false;
  }

  String? _getRangePosition(int date) {
    for (var range in highlightedDates) {
      if (range is List && range.length == 2) {
        if (date == range[0]) return 'start';
        if (date == range[1]) return 'end';
        if (date > range[0] && date < range[1]) return 'middle';
      } else if (range is int && date == range) {
        return 'single';
      }
    }
    return null;
  }
}
