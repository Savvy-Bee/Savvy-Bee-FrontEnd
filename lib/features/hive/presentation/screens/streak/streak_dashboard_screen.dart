import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/game_card.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';

import '../../providers/hive_provider.dart';
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
  void initState() {
    super.initState();
    // Fetch streak details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hiveNotifierProvider.notifier).fetchStreakDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hiveAsync = ref.watch(hiveNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak'),
        backgroundColor: AppColors.primary,
        surfaceTintColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: () {},
            icon: AppIcon(AppIcons.shareIcon, size: 20),
          ),
        ],
      ),
      body: hiveAsync.when(
        data: (hiveState) => _buildContent(hiveState),
        loading: () =>
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildContent(HiveState hiveState) {
    final currentStreak = hiveState.currentStreak ?? 0;
    final streakHistory = hiveState.streakHistory ?? [];

    // Calculate days practiced in current month
    final now = DateTime.now();
    final daysInCurrentMonth = streakHistory.where((streak) {
      return streak.createdAt.year == now.year &&
          streak.createdAt.month == now.month;
    }).length;

    // Get highlighted dates for calendar
    final highlightedDates = _getHighlightedDates(streakHistory, now);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(hiveNotifierProvider.notifier).fetchStreakDetails();
      },
      child: ListView(
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
                        _buildStreakNumber('$currentStreak'),
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
                  currentStreak >= 7
                      ? 'Congrats on reaching your latest streak milestone!'
                      : 'Keep going! Build your streak by practicing daily.',
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
                _buildStreakCard(currentStreak),
                const Gap(24),
                SectionTitleWidget(
                  title: '${_getMonthName(now.month)} ${now.year}',
                ),
                const Gap(16),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Days practiced',
                        '$daysInCurrentMonth',
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
                  year: now.year,
                  month: now.month,
                  highlightedDates: highlightedDates,
                  specialDate: now.day,
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

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const Gap(16),
            Text(
              'Failed to load streak data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              error.toString(),
              style: TextStyle(color: AppColors.greyDark),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(hiveNotifierProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getHighlightedDates(
    List<dynamic> streakHistory,
    DateTime currentMonth,
  ) {
    final List<int> datesInMonth = [];

    for (var streak in streakHistory) {
      if (streak.createdAt.year == currentMonth.year &&
          streak.createdAt.month == currentMonth.month) {
        datesInMonth.add(streak.createdAt.day);
      }
    }

    // Sort dates
    datesInMonth.sort();

    // Group consecutive dates into ranges
    List<dynamic> ranges = [];
    if (datesInMonth.isEmpty) return ranges;

    int rangeStart = datesInMonth[0];
    int rangeEnd = datesInMonth[0];

    for (int i = 1; i < datesInMonth.length; i++) {
      if (datesInMonth[i] == rangeEnd + 1) {
        rangeEnd = datesInMonth[i];
      } else {
        if (rangeStart == rangeEnd) {
          ranges.add(rangeStart);
        } else {
          ranges.add([rangeStart, rangeEnd]);
        }
        rangeStart = datesInMonth[i];
        rangeEnd = datesInMonth[i];
      }
    }

    // Add last range
    if (rangeStart == rangeEnd) {
      ranges.add(rangeStart);
    } else {
      ranges.add([rangeStart, rangeEnd]);
    }

    return ranges;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
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

  Widget _buildStreakCard(int currentStreak) {
    final challengeDays = 7;
    final currentDay = (currentStreak % challengeDays) == 0
        ? challengeDays
        : (currentStreak % challengeDays);

    return GameCard(
      padding: const EdgeInsets.all(16).copyWith(bottom: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$challengeDays Day Challenge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              Text(
                'Day $currentDay of $challengeDays',
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
          StreakSlider(totalDays: challengeDays, currentDay: currentDay),
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
            color: Colors.white,
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
    final firstWeekday = firstDayOfMonth.weekday % 7;
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
                        ? const Color(0xFFD97706)
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
