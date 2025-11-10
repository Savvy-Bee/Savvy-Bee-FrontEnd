import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

class LessonScreen extends ConsumerStatefulWidget {
  static String path = '/lesson';

  const LessonScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(Assets.quizzesBg)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

        ],),
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
}
