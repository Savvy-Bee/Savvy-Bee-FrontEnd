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

class LessonHomeScreen extends ConsumerStatefulWidget {
  static String path = '/lesson-home';

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

                  return GestureDetector(
                    onTap: () {
                      // setState(() => _selectedLessonIndex = index);
                      context.pushNamed(LevelsScreen.path, extra: lesson);
                    },
                    child: _buildLessonCard(
                      status: lesson.lessonNumber,
                      points: 0,
                      lessonNumber: lesson.lessonNumber,
                      illustrationAsset: Illustrations.lesson1,
                      title: lesson.lessonTitle,
                      description: lesson.lessonDescription,
                    ),
                  );
                }),
              ),
            ),
          ),
          // This doesn't work at the moment
          // Padding(
          //   padding: const EdgeInsets.all(16).copyWith(bottom: 32),
          //   child: CustomElevatedButton(
          //     text: 'Continue',
          //     onPressed: () {
          //       // Undefined name '_selectedLessonIndex'.
          //       final selectedLesson =
          //           widget.course.lessons[_selectedLessonIndex];
          //           context.pushNamed(LevelsScreen.path, extra: selectedLesson);
          //     },
          //   ),
          // ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
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
    required String lessonNumber,
    required String illustrationAsset,
    required String title,
    required String description,
  }) {
    final size = MediaQuery.sizeOf(context);

    final width = size.width * 0.8;
    final height = size.height * 0.6;

    final locked = status == "Not started";

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
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                  color: locked ? AppColors.buttonDisabled : null,
                ),
              ),
              const Spacer(),
              locked
                  ? Icon(Icons.lock_outline)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Text(
                          '+$points',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.neulisNeueFontFamily,
                          ),
                        ),
                        Image.asset(Illustrations.hiveFlower),
                      ],
                    ),
            ],
          ),
        ),
        CustomCard(
          hasShadow: true,
          width: width,
          height: height,
          borderColor: locked ? AppColors.grey : AppColors.primary,
          borderWidth: 3,
          bgColor: locked ? AppColors.greyMid : AppColors.primaryFaded,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lesson',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.neulisNeueFontFamily,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        lessonNumber,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.neulisNeueFontFamily,
                          height: 0.9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Image.asset(illustrationAsset, scale: 1.3),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                      height: 0.9,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, height: 0.9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
