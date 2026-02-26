class Illustrations {
  Illustrations._();

  static const String _basePath = 'assets/images/illustrations';
  static const String _lessonsPath = 'assets/images/lessons';

  static const String luna = '$_basePath/luna.png';
  static const String susu = '$_basePath/susu.png';
  static const String dash = '$_basePath/dash.png';
  static const String bloom = '$_basePath/bloom.png';
  static const String loki = '$_basePath/loki.png';
  static const String familyBee = '$_basePath/family_bee.png';
  static const String penny = '$_basePath/penny.png';

  static const String coinJar = '$_basePath/jar.png';
  static const String savvyCoin = '$_basePath/savvy_coin.png';

  static const String matchingAndQuizBee =
      '$_basePath/matching-and-quiz-bee.png';

  // Avatars
  static const String dashAvatar = '$_basePath/dash_head.png';
  static const String pennyAvatar = '$_basePath/penny_head.png';
  static const String susuAvatar = '$_basePath/susu_head.png';
  static const String bloomAvatar = '$_basePath/bloom_head.png';
  static const String booAvatar = '$_basePath/boo_head.png';
  static const String lunaAvatar = '$_basePath/luna_head.png';
  static const String lokiAvatar = '$_basePath/loki_head.png';

  static const List<String> avatars = [
    dashAvatar,
    pennyAvatar,
    susuAvatar,
    bloomAvatar,
    booAvatar,
    lunaAvatar,
    lokiAvatar,
  ];

  // Lessons Illustrations (old - kept for backwards compatibility)
  static const String lesson1 = '$_basePath/lesson-1.png';
  static const String lesson2 = '$_basePath/lesson-2.png';
  static const String lesson3 = '$_basePath/lesson-3.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // COURSE-SPECIFIC LESSON IMAGES
  // ═══════════════════════════════════════════════════════════════════════════

  // SAVINGS Course Lessons
  static const String savingsLesson1 = '$_lessonsPath/SAVINGS_/L1 SAVINGS.png';
  static const String savingsLesson2 = '$_lessonsPath/SAVINGS_/LV2 SAVINGS.png';
  static const String savingsLesson3 = '$_lessonsPath/SAVINGS_/L3 SAVINGS.png';
  static const String savingsLesson4 = '$_lessonsPath/SAVINGS_/L4 SAVINGS.png';
  static const String savingsLesson5 = '$_lessonsPath/SAVINGS_/L5 SAVINGS.png';

  // NUMERACY Course Lessons
  static const String numeracyLesson1 =
      '$_lessonsPath/NUMERACY_/L1 NUMERACY.png';
  static const String numeracyLesson2 =
      '$_lessonsPath/NUMERACY_/L2 NUMERACY.png';
  static const String numeracyLesson3 =
      '$_lessonsPath/NUMERACY_/LV3 NUMERACY.png';
  static const String numeracyLesson4 =
      '$_lessonsPath/NUMERACY_/L4 NUMERACY.png';
  static const String numeracyLesson5 =
      '$_lessonsPath/NUMERACY_/L5 NUMERACY.png';

  // BUDGETING Course Lessons
  static const String budgetingLesson1 =
      '$_lessonsPath/BUDGETING/LV1 BUDGETING.png';
  static const String budgetingLesson2 =
      '$_lessonsPath/BUDGETING/L2 BUDGETING.png';
  static const String budgetingLesson3 =
      '$_lessonsPath/BUDGETING/L3 BUDGETING.png';
  static const String budgetingLesson4 =
      '$_lessonsPath/BUDGETING/L4 BUDGETING.png';
  static const String budgetingLesson5 =
      '$_lessonsPath/BUDGETING/L5 BUDGETING.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHOD: Get lesson image by course title and lesson number
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns the appropriate lesson image based on course title and lesson number
  /// Falls back to default lesson1 if course/lesson not found
  static String getLessonImage(String courseTitle, int lessonNumber) {
    final normalizedCourse = courseTitle.toLowerCase().trim();

    // Map lesson numbers to indices (1-5)
    final lessonIndex = lessonNumber.clamp(1, 5);

    switch (normalizedCourse) {
      case 'savings':
      case 'saving':
      case 'savings 101':
        switch (lessonIndex) {
          case 1:
            return savingsLesson1;
          case 2:
            return savingsLesson2;
          case 3:
            return savingsLesson3;
          case 4:
            return savingsLesson4;
          case 5:
            return savingsLesson5;
          default:
            return lesson1; // Fallback
        }

      case 'numeracy':
        switch (lessonIndex) {
          case 1:
            return numeracyLesson1;
          case 2:
            return numeracyLesson2;
          case 3:
            return numeracyLesson3;
          case 4:
            return numeracyLesson4;
          case 5:
            return numeracyLesson5;
          default:
            return lesson1; // Fallback
        }

      case 'budgeting':
      case 'budgets':
      case 'budget':
      case 'budgeting basics':
        switch (lessonIndex) {
          case 1:
            return budgetingLesson1;
          case 2:
            return budgetingLesson2;
          case 3:
            return budgetingLesson3;
          case 4:
            return budgetingLesson4;
          case 5:
            return budgetingLesson5;
          default:
            return lesson1; // Fallback
        }

      default:
        // Fallback for unknown courses
        return lesson1;
    }
  }

  static const String hiveFlower = '$_basePath/hive-flower.png';

  // Financial health avatars
  static const String financialHealth1 = '$_basePath/financial-health-1.png';
  static const String financialHealth2 = '$_basePath/financial-health-2.png';
  static const String financialHealth3 = '$_basePath/financial-health-3.png';
  static const String financialHealth4 = '$_basePath/financial-health-4.png';
  static const String financialHealth5 = '$_basePath/financial-health-5.png';

  // Quiz bee
  static const String quizBeeWrong = '$_basePath/quiz-bee-wrong.png';
  static const String quizBeeRight = '$_basePath/quiz-bee-right.png';

  // Sleeping bee
  static const String sleepingBee = '$_basePath/sleeping-bee.png';

  // Matching bee
  static const String matchingBeeSmile = '$_basePath/matching-bee-smile.png';

  // Leaderboard
  static const String leaderboardBee = '$_basePath/leaderboard.png';

  // Premium
  static const String premiumBee = '$_basePath/premium-bee.png';
}

// class Illustrations {
//   Illustrations._();

//   static const String _basePath = 'assets/images/illustrations';

//   static const String luna = '$_basePath/luna.png';
//   static const String susu = '$_basePath/susu.png';
//   static const String dash = '$_basePath/dash.png';
//   static const String bloom = '$_basePath/bloom.png';
//   static const String loki = '$_basePath/loki.png';
//   static const String familyBee = '$_basePath/family_bee.png';
//   static const String penny = '$_basePath/penny.png';

//   static const String coinJar = '$_basePath/jar.png';
//   static const String savvyCoin = '$_basePath/savvy_coin.png';

//   static const String matchingAndQuizBee =
//       '$_basePath/matching-and-quiz-bee.png';

//   // Avatars
//   static const String dashAvatar = '$_basePath/dash_head.png';
//   static const String pennyAvatar = '$_basePath/penny_head.png';
//   static const String susuAvatar = '$_basePath/susu_head.png';
//   static const String bloomAvatar = '$_basePath/bloom_head.png';
//   static const String booAvatar = '$_basePath/boo_head.png';
//   static const String lunaAvatar = '$_basePath/luna_head.png';
//   static const String lokiAvatar = '$_basePath/loki_head.png';

//   static const List<String> avatars = [
//     dashAvatar,
//     pennyAvatar,
//     susuAvatar,
//     bloomAvatar,
//     booAvatar,
//     lunaAvatar,
//     lokiAvatar,
//   ];

//   // Lessons Illustrations
//   static const String lesson1 = '$_basePath/lesson-1.png';
//   static const String lesson2 = '$_basePath/lesson-2.png';
//   static const String lesson3 = '$_basePath/lesson-3.png';

//   static const String hiveFlower = '$_basePath/hive-flower.png';

//   // Financial health avatars
//   static const String financialHealth1 = '$_basePath/financial-health-1.png';
//   static const String financialHealth2 = '$_basePath/financial-health-2.png';
//   static const String financialHealth3 = '$_basePath/financial-health-3.png';
//   static const String financialHealth4 = '$_basePath/financial-health-4.png';
//   static const String financialHealth5 = '$_basePath/financial-health-5.png';

//   // Quiz bee
//   static const String quizBeeWrong = '$_basePath/quiz-bee-wrong.png';
//   static const String quizBeeRight = '$_basePath/quiz-bee-right.png';

//   // Sleeping bee
//   static const String sleepingBee = '$_basePath/sleeping-bee.png';

//   // Matching bee
//   static const String matchingBeeSmile = '$_basePath/matching-bee-smile.png';

//   // Leaderboard
//   static const String leaderboardBee = '$_basePath/leaderboard.png';

//   // Leaderboard
//   static const String premiumBee = '$_basePath/premium-bee.png';
// }
