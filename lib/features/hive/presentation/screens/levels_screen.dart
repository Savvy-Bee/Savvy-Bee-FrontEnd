import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/hexagonal_button.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';

import 'lesson/lesson_room_screen.dart';

class LevelsScreen extends ConsumerStatefulWidget {
  static String path = '/levels';

  final Lesson lesson;
  const LevelsScreen({super.key, required this.lesson});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends ConsumerState<LevelsScreen> {
  @override
  Widget build(BuildContext context) {
    final levels = widget.lesson.levels;

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

          /// LEVEL GRID
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// FIRST LEVEL - Alone at the top
                HexagonalButton(
                  number: levels.first.levelNumber.toString(),
                  onTap: () => context.pushNamed(
                    LessonRoomScreen.path,
                    extra: LessonRoomArgs(
                      lessonNumber: widget.lesson.lessonNumber,
                      level: levels.first,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// REMAINING LEVELS - Two side-by-side
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(levels.length - 1, (i) {
                    final level = levels[i + 1];
                    return HexagonalButton(
                      number: level.levelNumber.toString(),
                      onTap: () => context.pushNamed(
                        LessonRoomScreen.path,
                        extra: LessonRoomArgs(
                          lessonNumber: widget.lesson.lessonNumber,
                          level: level,
                        ),
                      ),
                    );
                  }),
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
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          BackButton(),
          Image.asset(Assets.honeyJar4, height: 40, width: 40),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.lesson.levels.length} levels',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.lesson.lessonTitle.truncate(20),
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
