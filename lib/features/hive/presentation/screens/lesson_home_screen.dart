import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/levels_screen.dart';

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
      'title': 'What is Saving',
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
                  onPressed: () => context.pushNamed(LevelsScreen.path),
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
          Image.asset(Assets.lessonProgress1, scale: 1.3),
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
    required int lessonNumber,
    required String illustrationAsset,
    required String title,
    required String description,
  }) {
    final size = MediaQuery.sizeOf(context);

    final width = size.width / 1.2;
    final height = size.height / 1.5;

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
