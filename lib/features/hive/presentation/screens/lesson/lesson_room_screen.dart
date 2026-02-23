import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/quiz/quiz_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/app_icons.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/custom_page_indicator.dart';
import '../../widgets/lesson_card.dart';

class LessonRoomArgs {
  final String lessonNumber;
  final Level level;

  LessonRoomArgs({required this.lessonNumber, required this.level});
}

class LessonRoomScreen extends ConsumerStatefulWidget {
  static const String path = '/lesson-room';

  final LessonRoomArgs args;

  const LessonRoomScreen({super.key, required this.args});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LessonRoomScreenState();
}

class _LessonRoomScreenState extends ConsumerState<LessonRoomScreen> {
  late final PageController _pageController;

  late final List<Widget> _pages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _pages = _buildPages(widget.args.level);

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() => _currentPage = newPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Track when user taps "Take the quiz" button
  void _startQuiz() {
    // Track quiz started with the quiz focus/title as module name
    MixpanelService.trackQuizStarted(widget.args.level.quiz.focus);

    context.pushReplacementNamed(
      QuizScreen.path,
      extra: QuizData(
        lessonNumber: widget.args.lessonNumber,
        levelNumber: widget.args.level.levelNumber,
        quizQuestions: widget.args.level.quiz.questions,
        moduleName: widget
            .args
            .level
            .quiz
            .focus, // Pass module name for completion tracking
      ),
    );
  }

  void _shareLesson() {
    final level = widget.args.level;
    final lessonNumber = widget.args.lessonNumber;

    // Determine what content to share based on current page
    String shareText;

    if (_currentPage == 0) {
      // Introduction page
      shareText =
          '''
🐝 Learning with SavvyBee!

📚 Lesson ${lessonNumber}: ${level.levelNumber}

${level.introduction}

Join me on my financial literacy journey!
''';
    } else if (_currentPage < _pages.length - 2) {
      // Section pages (skip last 2 pages which are highlights/tip/quiz)
      final sectionIndex = _currentPage - 1;
      if (sectionIndex >= 0 && sectionIndex < level.sections.length) {
        final section = level.sections[sectionIndex];

        final bullets = section.bulletPoints != null
            ? '\n\n' + section.bulletPoints!.map((b) => '• $b').join('\n')
            : '';

        shareText =
            '''
🐝 Learning with SavvyBee!

📚 ${section.heading}

${section.content}$bullets

Join me on my financial literacy journey!
''';
      } else {
        // Fallback for edge cases
        shareText =
            '''
🐝 Learning with SavvyBee!

📚 Lesson ${lessonNumber}
I'm learning about ${level.quiz.focus}

Join me on my financial literacy journey!
''';
      }
    } else {
      // Highlights, Tips, or Quiz page
      shareText =
          '''
🐝 Learning with SavvyBee!

📚 Just completed Lesson ${lessonNumber}
Topic: ${level.quiz.focus}

💡 Key Highlights:
${level.highlights.map((h) => '• $h').join('\n')}

Join me on my financial literacy journey!
''';
    }

    // Share the text
    Share.share(shareText, subject: 'SavvyBee - ${level.quiz.focus}');

    // Optional: Track the share event in Mixpanel
    MixpanelService.trackLessonShared(
      moduleName: level.quiz.focus,
      lessonNumber: lessonNumber,
      pageIndex: _currentPage,
    );
  }

  // ----------------------------
  // BUILD ALL LEVEL PAGES
  // ----------------------------
  List<Widget> _buildPages(Level level) {
    final pages = <Widget>[];

    // 1. INTRO PAGE
    pages.add(
      LessonCard(
        superscript: 'Introduction',
        bodyText: level.introduction,
        // enumeratedItems[level.introduction],
      ),
    );

    // 2. SECTIONS
    for (final section in level.sections) {
      pages.add(
        LessonCard(
          superscript: section.heading,
          title: section.heading,
          enumeratedItems: section.bulletPoints != null
              ? section.bulletPoints!
              : [],
          bodyText: section.content,
        ),
      );
    }

    // 3. FUN FACT
    if (level.funFact != null) {
      pages.add(
        LessonCard(
          superscript: 'Fun Fact',
          enumeratedItems: [level.funFact!],
          isHighlight: true,
        ),
      );
    }

    // 4. HIGHLIGHTS
    pages.add(
      LessonCard(
        superscript: 'Highlights',
        isHighlight: true,
        enumeratedItems: level.highlights,
      ),
    );

    // 5. TIP
    if (level.tip != null) {
      pages.add(LessonCard(superscript: 'Tip', enumeratedItems: [level.tip!]));
    }

    // 6. QUIZ START PAGE
    pages.add(
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: CustomCard(
            bgColor: AppColors.white,
            hasShadow: true,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 24),
            shadow: [
              BoxShadow(
                blurRadius: 20,
                spreadRadius: 3,
                offset: Offset(0, 4),
                color: AppColors.black.withValues(alpha: 0.15),
              ),
            ],
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  bgColor: AppColors.primary,
                  borderRadius: 16,
                  borderColor: Colors.transparent,
                  child: Text(
                    'Test your knowledge',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 12 * 0.02,
                    ),
                  ),
                ),
                Text(
                  'Take the quiz',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 12 * 0.02,
                  ),
                ),
                Image.asset(Illustrations.lesson1, scale: 1.3),
                CustomElevatedButton(
                  text: 'Take the quiz',
                  onPressed: _startQuiz, // Use the tracking wrapper
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return pages;
  }

  // ----------------------------
  // UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    const double spacingValue = 5.0;
    const double horizontalPadding = 16.0;

    final dotCount = _pages.length;

    final double availableWidth = screenWidth - (7 * horizontalPadding);
    final double totalSpacing = (dotCount - 1) * spacingValue;
    final double availableWidthForDots = availableWidth - totalSpacing;
    final double calculatedDotWidth = availableWidthForDots / dotCount;

    return Scaffold(
      backgroundColor: AppColors.blue,
      appBar: _buildAppBar(calculatedDotWidth, spacingValue, horizontalPadding),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(Assets.quizzesBg, fit: BoxFit.cover),
          ),

          // PAGES
          PageView(controller: _pageController, children: _pages),

          // BOTTOM CONTROLS
          Align(alignment: Alignment.bottomCenter, child: _buildControls()),
        ],
      ),
    );
  }

  // ----------------------------
  // CONTROLS
  // ----------------------------
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// SHARE BUTTON
          IconButton.filled(
            onPressed: _shareLesson,
            icon: AppIcon(AppIcons.shareIcon, color: AppColors.primary),
            style: IconButton.styleFrom(backgroundColor: AppColors.background),
          ),

          /// PREV / NEXT
          Row(
            spacing: 8,
            children: [
              IconButton.filled(
                onPressed: _currentPage > 0
                    ? () => _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )
                    : null,
                icon: const Icon(Icons.keyboard_arrow_left_rounded),
              ),
              IconButton.filled(
                onPressed: _currentPage < _pages.length - 1
                    ? () => _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )
                    : null,
                icon: const Icon(Icons.keyboard_arrow_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // APP BAR
  // ----------------------------
  AppBar _buildAppBar(
    double calculatedDotWidth,
    double spacingValue,
    double horizontalPadding,
  ) {
    return AppBar(
      backgroundColor: AppColors.blue,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.movie),
            iconSize: 18,
            style: Constants.collapsedButtonStyle,
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.bookmark_outline),
          //   iconSize: 18,
          //   style: Constants.collapsedButtonStyle,
          // ),

          // this gap is in place of the icon commented
          Gap(18),

          /// PAGE INDICATOR
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: PreviousColoredSlideEffect(
              dotHeight: 3,
              dotWidth: calculatedDotWidth,
              spacing: spacingValue,
              activeDotColor: AppColors.white,
              dotColor: AppColors.white.withOpacity(.5),
            ),
          ),

          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
            iconSize: 18,
            style: Constants.collapsedButtonStyle,
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
// import 'package:savvy_bee_mobile/features/hive/presentation/screens/quiz/quiz_screen.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/utils/assets/app_icons.dart';
// import '../../../../../core/utils/assets/assets.dart';
// import '../../../../../core/utils/constants.dart';
// import '../../../../../core/utils/custom_page_indicator.dart';
// import '../../widgets/lesson_card.dart';

// class LessonRoomArgs {
//   final String lessonNumber;
//   final Level level;

//   LessonRoomArgs({required this.lessonNumber, required this.level});
// }

// class LessonRoomScreen extends ConsumerStatefulWidget {
//   static const String path = '/lesson-room';

//   final LessonRoomArgs args;

//   const LessonRoomScreen({super.key, required this.args});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _LessonRoomScreenState();
// }

// class _LessonRoomScreenState extends ConsumerState<LessonRoomScreen> {
//   late final PageController _pageController;

//   late final List<Widget> _pages;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();

//     _pageController = PageController();
//     _pages = _buildPages(widget.args.level);

//     _pageController.addListener(() {
//       final newPage = _pageController.page?.round() ?? 0;
//       if (newPage != _currentPage) {
//         setState(() => _currentPage = newPage);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   // ----------------------------
//   // BUILD ALL LEVEL PAGES
//   // ----------------------------
//   List<Widget> _buildPages(Level level) {
//     final pages = <Widget>[];

//     // 1. INTRO PAGE
//     pages.add(
//       LessonCard(
//         superscript: 'Introduction',
//         bodyText: level.introduction,
//         // enumeratedItems[level.introduction],
//       ),
//     );

//     // 2. SECTIONS
//     for (final section in level.sections) {
//       pages.add(
//         LessonCard(
//           superscript: section.heading,
//           title: section.heading,
//           enumeratedItems: section.bulletPoints != null
//               ? section.bulletPoints!
//               :[
//           ],
//           bodyText: section.content,
//         ),
//       );
//     }

//     // 3. FUN FACT
//     if (level.funFact != null) {
//       pages.add(
//         LessonCard(
//           superscript: 'Fun Fact',
//           enumeratedItems: [level.funFact!],
//           isHighlight: true,
//         ),
//       );
//     }

//     // 4. HIGHLIGHTS
//     pages.add(
//       LessonCard(
//         superscript: 'Highlights',
//         isHighlight: true,
//         enumeratedItems: level.highlights,
//       ),
//     );

//     // 5. TIP
//     if (level.tip != null) {
//       pages.add(LessonCard(superscript: 'Tip', enumeratedItems: [level.tip!]));
//     }

//     // 6. QUIZ START PAGE
//     pages.add(
//       Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
//           child: CustomCard(
//             bgColor: AppColors.white,
//             hasShadow: true,
//             borderColor: Colors.transparent,
//             padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 24),
//             shadow: [
//               BoxShadow(
//                 blurRadius: 20,
//                 spreadRadius: 3,
//                 offset: Offset(0, 4),
//                 color: AppColors.black.withValues(alpha: 0.15),
//               ),
//             ],
//             child: Column(
//               spacing: 16,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CustomCard(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 5,
//                   ),
//                   bgColor: AppColors.primary,
//                   borderRadius: 16,
//                   borderColor: Colors.transparent,
//                   child: Text(
//                     'Test your knowledge',
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Text(
//                   'Take the quiz',
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                 ),
//                 Image.asset(Illustrations.lesson1, scale: 1.3),
//                 CustomElevatedButton(
//                   text: 'Take the quiz',
//                   onPressed: () {
//                     context.pushReplacementNamed(
//                       QuizScreen.path,
//                       extra: QuizData(
//                         lessonNumber: widget.args.lessonNumber,
//                         levelNumber: level.levelNumber,
//                         quizQuestions: level.quiz.questions,
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     return pages;
//   }

//   // ----------------------------
//   // UI
//   // ----------------------------
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.sizeOf(context).width;
//     const double spacingValue = 5.0;
//     const double horizontalPadding = 16.0;

//     final dotCount = _pages.length;

//     final double availableWidth = screenWidth - (7 * horizontalPadding);
//     final double totalSpacing = (dotCount - 1) * spacingValue;
//     final double availableWidthForDots = availableWidth - totalSpacing;
//     final double calculatedDotWidth = availableWidthForDots / dotCount;

//     return Scaffold(
//       backgroundColor: AppColors.blue,
//       appBar: _buildAppBar(calculatedDotWidth, spacingValue, horizontalPadding),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(Assets.quizzesBg, fit: BoxFit.cover),
//           ),

//           // PAGES
//           PageView(controller: _pageController, children: _pages),

//           // BOTTOM CONTROLS
//           Align(alignment: Alignment.bottomCenter, child: _buildControls()),
//         ],
//       ),
//     );
//   }

//   // ----------------------------
//   // CONTROLS
//   // ----------------------------
//   Widget _buildControls() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           /// SHARE BUTTON
//           IconButton.filled(
//             onPressed: () {},
//             icon: AppIcon(AppIcons.shareIcon, color: AppColors.primary),
//             style: IconButton.styleFrom(backgroundColor: AppColors.background),
//           ),

//           /// PREV / NEXT
//           Row(
//             spacing: 8,
//             children: [
//               IconButton.filled(
//                 onPressed: _currentPage > 0
//                     ? () => _pageController.previousPage(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeOut,
//                       )
//                     : null,
//                 icon: const Icon(Icons.keyboard_arrow_left_rounded),
//               ),
//               IconButton.filled(
//                 onPressed: _currentPage < _pages.length - 1
//                     ? () => _pageController.nextPage(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeOut,
//                       )
//                     : null,
//                 icon: const Icon(Icons.keyboard_arrow_right_rounded),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ----------------------------
//   // APP BAR
//   // ----------------------------
//   AppBar _buildAppBar(
//     double calculatedDotWidth,
//     double spacingValue,
//     double horizontalPadding,
//   ) {
//     return AppBar(
//       backgroundColor: AppColors.blue,
//       titleSpacing: 0,
//       automaticallyImplyLeading: false,
//       title: Row(
//         children: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.movie),
//             iconSize: 18,
//             style: Constants.collapsedButtonStyle,
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.bookmark_outline),
//             iconSize: 18,
//             style: Constants.collapsedButtonStyle,
//           ),

//           /// PAGE INDICATOR
//           SmoothPageIndicator(
//             controller: _pageController,
//             count: _pages.length,
//             effect: PreviousColoredSlideEffect(
//               dotHeight: 3,
//               dotWidth: calculatedDotWidth,
//               spacing: spacingValue,
//               activeDotColor: AppColors.white,
//               dotColor: AppColors.white.withOpacity(.5),
//             ),
//           ),

//           IconButton(
//             onPressed: () => context.pop(),
//             icon: const Icon(Icons.close),
//             iconSize: 18,
//             style: Constants.collapsedButtonStyle,
//           ),
//         ],
//       ),
//     );
//   }
// }
