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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 12,
              children: List.generate(3, (index) => _buildLessonCard()),
            ),
          ),
          const Gap(40),
          CustomElevatedButton(
            text: 'Continue',
            onPressed: () => context.pushNamed(LessonScreen.path),
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

  Widget _buildLessonCard() {
    var width = MediaQuery.sizeOf(context).width / 1.2;
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
                'In progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Text(
                    '+20',
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
          borderColor: AppColors.primary,
          borderWidth: 3,
          bgColor: AppColors.primaryFaded,
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
                        '1',
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
              Image.asset(Illustrations.lesson1),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'What is Saving?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut',
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
