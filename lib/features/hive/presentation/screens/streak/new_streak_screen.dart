import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/hive_screen.dart';

import '../../../domain/models/streak.dart';
import '../../providers/hive_provider.dart';

class NewStreakScreen extends ConsumerStatefulWidget {
  static String path = '/new-streak';

  const NewStreakScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewStreakScreenState();
}

class _NewStreakScreenState extends ConsumerState<NewStreakScreen>
    with SingleTickerProviderStateMixin {
  bool showFullInfo = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Fetch streak details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hiveNotifierProvider.notifier).fetchStreakDetails().then((
        value,
      ) {
        setState(() {
          showFullInfo = true;
        });
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hiveAsync = ref.watch(hiveNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternYellow),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: hiveAsync.when(
            data: (hiveState) => _buildContent(hiveState),
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stack) => _buildErrorState(error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HiveState hiveState) {
    final currentStreak = hiveState.currentStreak ?? 0;
    final streakHistory = hiveState.streakHistory ?? [];
    final today = DateTime.now();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: !showFullInfo ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Column(
            children: [
              // Fire image with scale animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: showFullInfo ? _scaleAnimation.value : 1.0,
                    child: Image.asset(
                      Assets.fire,
                      scale: showFullInfo ? 1.8 : 1,
                    ),
                  );
                },
              ),
              Gap(showFullInfo ? 24 : 48),

              // Streak number with scale animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: showFullInfo ? _scaleAnimation.value : 1.0,
                    child: Text(
                      '$currentStreak',
                      style: TextStyle(
                        fontSize: 160,
                        fontWeight: FontWeight.w900,
                        fontFamily: Constants.neulisNeueFontFamily,
                        color: AppColors.primary,
                        height: 1.0,
                      ),
                    ),
                  );
                },
              ),

              // Animated content that appears after loading
              if (showFullInfo) ...[
                const Gap(24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'day streak',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                  ),
                ),
                const Gap(24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _buildWeekCalendar(streakHistory, today),
                            ),
                            const Divider(height: 0),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                "Take a quiz everyday so your streak won't reset!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: Constants.neulisNeueFontFamily,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (showFullInfo) const Spacer(),
          if (showFullInfo)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomElevatedButton(
                    text: 'Continue',
                    onPressed: () => context.goNamed(HiveScreen.path),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(List<StreakData> streakHistory, DateTime today) {
    // Get the last 7 days including today
    final weekDays = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekDays.map((day) {
        final hasStreak = _hasStreakOnDate(streakHistory, day);
        final isToday = _isSameDay(day, today);
        final dayOfWeek = _getDayOfWeek(day.weekday);

        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              dayOfWeek,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isToday ? AppColors.primary : AppColors.greyDark,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasStreak
                    ? AppColors.primary
                    : isToday
                    ? AppColors.primaryFaded
                    : AppColors.greyLight,
                border: isToday
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: hasStreak
                  ? Icon(Icons.check, color: AppColors.white, size: 18)
                  : null,
            ),
          ],
        );
      }).toList(),
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
            CustomElevatedButton(
              text: 'Retry',
              onPressed: () {
                ref.invalidate(hiveNotifierProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _hasStreakOnDate(List<StreakData> streakHistory, DateTime date) {
    return streakHistory.any((streak) => _isSameDay(streak.createdAt, date));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayOfWeek(int weekday) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[weekday - 1];
  }
}
