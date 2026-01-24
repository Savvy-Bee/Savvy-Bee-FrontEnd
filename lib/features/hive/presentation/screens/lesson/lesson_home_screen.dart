import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/levels_screen.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../providers/course_providers.dart';

class LessonHomeScreen extends ConsumerStatefulWidget {
  static const String path = '/lesson-home';

  final Course course;
  const LessonHomeScreen({super.key, required this.course});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LessonHomeScreenState();
}

class _LessonHomeScreenState extends ConsumerState<LessonHomeScreen> {
  // final int _selectedLessonIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 12,
                children: List.generate(widget.course.lessons.length, (index) {
                  final lesson = widget.course.lessons[index];

                  // Check if this lesson is accessible
                  final tracker = ref.watch(quizProgressProvider);
                  final isFirstLesson = index == 0;
                  bool canAccess = isFirstLesson;

                  if (!isFirstLesson) {
                    final previousLesson = widget.course.lessons[index - 1];
                    final prevCompleted = tracker.getCompletedLevelsForLesson(
                      previousLesson.lessonNumber,
                    );
                    final prevTotal = previousLesson.levels.length;
                    canAccess = prevCompleted == prevTotal && prevTotal > 0;
                  }

                  return GestureDetector(
                    onTap: canAccess
                        ? () {
                            context.pushNamed(LevelsScreen.path, extra: lesson);
                          }
                        : null, // No action if locked
                    child: _buildLessonCard(
                      status: lesson.lessonNumber,
                      points: 0,
                      lesson: lesson,
                      illustrationAsset: Illustrations.lesson1,
                      title: lesson.lessonTitle,
                      description: lesson.lessonDescription,
                      lessonIndex: index,
                      totalLessons: widget.course.lessons.length,
                    ),
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 32),
            child: CustomElevatedButton(
              text: 'Continue',
              onPressed: () {
                final tracker = ref.read(quizProgressProvider);

                // Find first incomplete lesson
                int targetIndex = 0;
                for (int i = 0; i < widget.course.lessons.length; i++) {
                  final lesson = widget.course.lessons[i];
                  bool hasIncomplete = false;

                  for (final level in lesson.levels) {
                    if (!tracker.isLevelCompleted(
                      lesson.lessonNumber,
                      level.levelNumber,
                    )) {
                      hasIncomplete = true;
                      break;
                    }
                  }

                  if (hasIncomplete) {
                    targetIndex = i;
                    break;
                  }
                }

                final selectedLesson = widget.course.lessons[targetIndex];
                context.pushNamed(LevelsScreen.path, extra: selectedLesson);
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: CustomElevatedButton(
          //     text: 'Continue',
          //     onPressed: () {
          //       final selectedLesson =
          //           widget.course.lessons[_selectedLessonIndex];

          //       context.pushNamed(LevelsScreen.path, extra: selectedLesson);
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BackButton(),
          Image.asset(Assets.lessonProgress1, scale: 1.3),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.course.courseTitle.truncate(10),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.course.lessons.length} lessons',
                    style: TextStyle(fontSize: 8),
                  ),
                  // Text('5 quizzes', style: TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Illustrations.hiveFlower),
            const Gap(4),
            Text(
              '200',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hive, color: AppColors.primary),
            const Gap(4),
            Text(
              '200',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(16),
      ],
    );
  }

  Widget _buildLessonCard({
    required String status,
    required int points,
    required Lesson lesson,
    required String illustrationAsset,
    required String title,
    required String description,
    required int lessonIndex,
    required int totalLessons,
  }) {
    final size = MediaQuery.sizeOf(context);

    final width = size.width * 0.8;
    final height = size.height * 0.6;
    final tracker = ref.watch(quizProgressProvider);
    final completedLevels = tracker.getCompletedLevelsForLesson(
      lesson.lessonNumber,
    );
    final totalLevels = lesson.levels.length;

    // Calculate completion states
    final progressPercent = totalLevels > 0
        ? (completedLevels / totalLevels)
        : 0.0;
    final isCompleted = completedLevels == totalLevels && totalLevels > 0;
    final isInProgress = completedLevels > 0 && !isCompleted;
    final hasNotStarted = completedLevels == 0;

    // Check if previous lesson is completed (for locking)
    final isFirstLesson = lessonIndex == 0;
    bool isPreviousLessonCompleted = true;

    if (!isFirstLesson && lessonIndex > 0) {
      final previousLesson = widget.course.lessons[lessonIndex - 1];
      final prevCompletedLevels = tracker.getCompletedLevelsForLesson(
        previousLesson.lessonNumber,
      );
      final prevTotalLevels = previousLesson.levels.length;
      isPreviousLessonCompleted =
          prevCompletedLevels == prevTotalLevels && prevTotalLevels > 0;
    }

    // Lesson is locked if it hasn't started AND previous lesson isn't completed
    // (First lesson is never locked)
    final isLocked =
        !isFirstLesson && hasNotStarted && !isPreviousLessonCompleted;

    // Calculate points earned (20 points per completed level)
    final pointsEarned = completedLevels * 20;

    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLocked
                    ? 'Locked'
                    : isCompleted
                    ? 'Completed'
                    : isInProgress
                    ? 'In progress'
                    : 'Not started',
                style: TextStyle(
                  fontWeight: FontWeight.bold,

                  color: isLocked
                      ? AppColors.buttonDisabled
                      : hasNotStarted
                      ? AppColors.buttonDisabled
                      : null,
                ),
              ),
              const Spacer(),

              // Show lock icon if locked, otherwise show points
              isLocked
                  ? Icon(Icons.lock_outline, color: AppColors.buttonDisabled)
                  : isCompleted || isInProgress
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Text(
                          '+$pointsEarned',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image.asset(Illustrations.hiveFlower),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),

        // Wrap card in Opacity and AbsorbPointer to disable when locked
        AbsorbPointer(
          absorbing: !isLocked,
          child: CustomCard(
            hasShadow: !isLocked,
            width: width,
            height: height,
            borderColor: isLocked
                ? AppColors.greyDark
                : isCompleted
                ? AppColors.success
                : isInProgress
                ? AppColors.primary
                : AppColors.primary,
            borderWidth: 3,
            bgColor: isLocked
                ? AppColors.greyMid
                : isCompleted
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.primaryFaded,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lesson',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,

                            height: 0.9,
                            color: isLocked ? AppColors.greyDark : null,
                          ),
                        ),
                        Text(
                          lesson.lessonNumber,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,

                            height: 0.9,
                            color: isLocked ? AppColors.greyDark : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Illustration
                Image.asset(
                  illustrationAsset,
                  scale: 1.3,
                  color: isLocked ? AppColors.greyDark : null,
                  fit: BoxFit.contain,
                ),

                // Title and description section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,

                        height: 0.9,
                        color: isLocked ? AppColors.greyDark : null,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 0.9,
                        color: isLocked ? AppColors.greyDark : null,
                      ),
                    ),

                    // Show progress indicator if in progress
                    if (isInProgress) ...[
                      const Gap(12),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progressPercent,
                              backgroundColor: AppColors.greyLight,
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            '${(progressPercent * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
