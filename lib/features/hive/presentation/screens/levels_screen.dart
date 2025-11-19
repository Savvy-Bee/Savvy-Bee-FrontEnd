import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/hexagonal_button.dart';

import 'lesson/lesson_room_screen.dart';

class LevelsScreen extends ConsumerStatefulWidget {
  static String path = '/levels';

  const LevelsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends ConsumerState<LevelsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryFaint,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.quizzesBg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HexagonalButton(
                  number: '1',
                  onTap: () => context.pushNamed(LessonRoomScreen.path),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HexagonalButton(number: '2'),
                    HexagonalButton(number: '3'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HexagonalButton(number: '4'),
                    HexagonalButton(number: '5'),
                  ],
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
      backgroundColor: AppColors.primaryFaint,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BackButton(),
          Image.asset(Assets.honeyJar4, height: 40, width: 40),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '5 lessons',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'What is Saving?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [Image.asset(Assets.lessonProgress1, scale: 1.3), Gap(16)],
    );
  }
}
