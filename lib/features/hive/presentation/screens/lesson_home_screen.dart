import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/lesson_screen.dart';

class LessonHomeScreen extends ConsumerStatefulWidget {
  static String path = '/lesson-home';

  const LessonHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LessonHomeScreenState();
}

class _LessonHomeScreenState extends ConsumerState<LessonHomeScreen> {
  final List<Map<String, dynamic>> lessons = [
    {
      'status': 'Completed',
      'points': 50,
      'lessonNumber': 1,
      'illustrationAsset': Illustrations.lesson3,
      'title': 'Ways people save money',
      'description':
          'There are different ways to save money: bank accounts, apps, and piggy banks.',
    },
    {
      'status': 'Current',
      'points': 50,
      'lessonNumber': 2,
      'illustrationAsset': Illustrations.lesson2,
      'title': 'Good vs. Not-so-Good',
      'description': 'Learn which saving habits help and which ones hurt.',
    },
    {
      'status': 'Not started',
      'points': 50,
      'lessonNumber': 3,
      'illustrationAsset': Illustrations.lesson1,
      'title': 'Needs vs. Wants',
      'description':
          'Understand the difference between what you need and what you want.',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: 35),
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 12,
              children: List.generate(
                lessons.length,
                (index) => _buildLessonCard(
                  status: lessons[index]['status'],
                  points: lessons[index]['points'],
                  lessonNumber: lessons[index]['lessonNumber'],
                  illustrationAsset: lessons[index]['illustrationAsset'],
                  title: lessons[index]['title'],
                  description: lessons[index]['description'],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Gap(40),
                CustomElevatedButton(
                  text: 'Continue',
                  onPressed: () => context.pushNamed(LessonScreen.path),
                ),
              ],
            ),
          ),
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
          Image.asset(Assets.honeyJar, height: 35, width: 35),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Savings 101',
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
                  Text('5 lessons', style: TextStyle(fontSize: 8)),
                  Text('5 quizzes', style: TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [Image.asset(Assets.lessonProgress1)],
    );
  }

  Widget _buildLessonCard({
    required String status,
    required int points,
    required int lessonNumber,
    required String illustrationAsset,
    required String title,
    required String description,
  }) {
    var width = MediaQuery.sizeOf(context).width / 1.2;
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
        OutlinedCard(
          hasShadow: true,
          width: width,
          borderColor: locked ? AppColors.grey : AppColors.primary,
          borderWidth: 3,
          bgColor: locked ? AppColors.greyLight : AppColors.primaryFaded,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 45),
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
                        '$lessonNumber',
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
              const Gap(8),
              Image.asset(illustrationAsset),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                      height: 0.9,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
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
