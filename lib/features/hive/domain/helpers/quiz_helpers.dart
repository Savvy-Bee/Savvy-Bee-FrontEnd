import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
// import '../models/quiz_data_models.dart' hide QuizQuestion, Lesson;

/// Course Loader - handles loading course data from assets
class CourseLoader {
  static const String _basePath = 'assets/data/courses';

  /// Load a specific course
  static Future<Course> loadCourse(String courseId) async {
    try {
      final jsonString = await rootBundle.loadString(
        '$_basePath/$courseId.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Course.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load course $courseId: $e');
    }
  }

  /// Load all available courses
  static Future<List<Course>> loadAllCourses(List<String> courseIds) async {
    final courses = <Course>[];

    for (final courseId in courseIds) {
      try {
        courses.add(await loadCourse(courseId));
      } catch (e) {
        log('Error loading course $courseId: $e');
      }
    }

    return courses;
  }

  /// Parse JSON string directly
  static Course parseJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Course.fromJson(json);
  }
}

/// Quiz Progress Tracker
class QuizProgressTracker {
  final Map<String, LevelProgress> _progress = {};

  /// Start a new level
  void startLevel(String lessonNumber, int levelNumber) {
    final key = _getKey(lessonNumber, levelNumber);
    if (!_progress.containsKey(key)) {
      _progress[key] = LevelProgress(
        lessonNumber: lessonNumber,
        levelNumber: levelNumber,
        lessonCompleted: false,
        quizCompleted: false,
        score: 0,
        attempts: 0,
      );
    }
  }

  /// Mark lesson as completed
  void completeLesson(String lessonNumber, int levelNumber) {
    final key = _getKey(lessonNumber, levelNumber);
    final current = _progress[key];
    if (current != null) {
      _progress[key] = current.copyWith(lessonCompleted: true);
    } else {
      startLevel(lessonNumber, levelNumber);
      _progress[key] = _progress[key]!.copyWith(lessonCompleted: true);
    }
  }

  /// Mark quiz as completed with score
  void completeQuiz(String lessonNumber, int levelNumber, int score) {
    final key = _getKey(lessonNumber, levelNumber);
    final current = _progress[key];
    if (current != null) {
      _progress[key] = current.copyWith(
        quizCompleted: true,
        score: score,
        attempts: current.attempts + 1,
      );
    } else {
      startLevel(lessonNumber, levelNumber);
      _progress[key] = _progress[key]!.copyWith(
        quizCompleted: true,
        score: score,
        attempts: 1,
      );
    }
  }

  /// Check if level is completed
  bool isLevelCompleted(String lessonNumber, int levelNumber) {
    final key = _getKey(lessonNumber, levelNumber);
    final progress = _progress[key];
    return progress?.quizCompleted ?? false;
  }

  /// Check if lesson content is completed
  bool isLessonCompleted(String lessonNumber, int levelNumber) {
    final key = _getKey(lessonNumber, levelNumber);
    final progress = _progress[key];
    return progress?.lessonCompleted ?? false;
  }

  /// Get level progress
  LevelProgress? getProgress(String lessonNumber, int levelNumber) {
    return _progress[_getKey(lessonNumber, levelNumber)];
  }

  /// Calculate total score for a lesson
  int getLessonScore(String lessonNumber) {
    return _progress.values
        .where((p) => p.lessonNumber == lessonNumber && p.quizCompleted)
        .fold(0, (sum, p) => sum + p.score);
  }

  /// Calculate total score across all lessons
  int get totalScore {
    return _progress.values
        .where((p) => p.quizCompleted)
        .fold(0, (sum, p) => sum + p.score);
  }

  /// Get number of completed levels
  int get completedLevels {
    return _progress.values.where((p) => p.quizCompleted).length;
  }

  /// Get number of completed levels for a specific lesson
  int getCompletedLevelsForLesson(String lessonNumber) {
    return _progress.values
        .where((p) => p.lessonNumber == lessonNumber && p.quizCompleted)
        .length;
  }

  /// Clear all progress
  void clearProgress() {
    _progress.clear();
  }

  /// Reset specific level
  void resetLevel(String lessonNumber, int levelNumber) {
    _progress.remove(_getKey(lessonNumber, levelNumber));
  }

  String _getKey(String lessonNumber, int levelNumber) =>
      '$lessonNumber-$levelNumber';

  /// Export progress as JSON
  Map<String, dynamic> toJson() {
    return {
      'progress': _progress.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// Import progress from JSON
  void fromJson(Map<String, dynamic> json) {
    _progress.clear();
    final progressMap = json['progress'] as Map<String, dynamic>;
    progressMap.forEach((key, value) {
      _progress[key] = LevelProgress.fromJson(value as Map<String, dynamic>);
    });
  }
}

/// Level Progress Model
class LevelProgress {
  final String lessonNumber;
  final int levelNumber;
  final bool lessonCompleted;
  final bool quizCompleted;
  final int score;
  final int attempts;

  LevelProgress({
    required this.lessonNumber,
    required this.levelNumber,
    required this.lessonCompleted,
    required this.quizCompleted,
    required this.score,
    required this.attempts,
  });

  LevelProgress copyWith({
    String? lessonNumber,
    int? levelNumber,
    bool? lessonCompleted,
    bool? quizCompleted,
    int? score,
    int? attempts,
  }) {
    return LevelProgress(
      lessonNumber: lessonNumber ?? this.lessonNumber,
      levelNumber: levelNumber ?? this.levelNumber,
      lessonCompleted: lessonCompleted ?? this.lessonCompleted,
      quizCompleted: quizCompleted ?? this.quizCompleted,
      score: score ?? this.score,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonNumber': lessonNumber,
      'levelNumber': levelNumber,
      'lessonCompleted': lessonCompleted,
      'quizCompleted': quizCompleted,
      'score': score,
      'attempts': attempts,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      lessonNumber: json['lessonNumber'] as String,
      levelNumber: json['levelNumber'] as int,
      lessonCompleted: json['lessonCompleted'] as bool,
      quizCompleted: json['quizCompleted'] as bool,
      score: json['score'] as int,
      attempts: json['attempts'] as int,
    );
  }
}

/// Quiz Validator - validates user answers
class QuizValidator {
  /// Validate multiple choice answer
  static bool validateMultiChoice(
    MultiChoiceQuestion question,
    int userAnswer,
  ) {
    return question.correctAnswer == userAnswer;
  }

  /// Validate fill in the gap answer (case insensitive, trimmed)
  static bool validateFillInTheGap(
    FillInTheGapQuestion question,
    List<String> userAnswers,
  ) {
    if (userAnswers.length != question.correctAnswer.length) return false;

    for (int i = 0; i < userAnswers.length; i++) {
      final userAnswer = userAnswers[i].trim().toLowerCase();
      final correctAnswer = question.correctAnswer[i].trim().toLowerCase();

      // Check for alternative answers (pipe separated)
      if (correctAnswer.contains('|')) {
        final alternatives = correctAnswer.split('|').map((s) => s.trim());
        if (!alternatives.contains(userAnswer)) return false;
      } else {
        if (userAnswer != correctAnswer) return false;
      }
    }

    return true;
  }

  /// Validate true/false answer
  static bool validateTrueFalse(TrueFalseQuestion question, bool userAnswer) {
    return question.correctAnswer == userAnswer;
  }

  /// Validate match answer
  static bool validateMatch(
    MatchQuestion question,
    Map<String, int> userMatches,
  ) {
    if (userMatches.length != question.correctMatches.length) return false;

    return question.correctMatches.entries.every(
      (entry) => userMatches[entry.key] == entry.value,
    );
  }

  /// Validate reorder answer
  static bool validateReorder(
    ReorderQuestion question,
    List<String> userOrder,
  ) {
    final correctOrder = question.correctAnswer;
    if (userOrder.length != correctOrder.length) return false;

    for (int i = 0; i < userOrder.length; i++) {
      if (userOrder[i].trim() != correctOrder[i].trim()) return false;
    }

    return true;
  }

  /// Validate drag and drop answer
  static bool validateDragAndDrop(
    DragAndDropQuestion question,
    Map<String, List<int>> userGroups,
  ) {
    final correctGroups = question.groups;

    // Check if all groups are present
    if (userGroups.length != correctGroups.length) return false;

    return correctGroups.entries.every((entry) {
      final userGroup = userGroups[entry.key];
      if (userGroup == null) return false;

      // Check if all items match (order may not matter for drag and drop)
      if (userGroup.length != entry.value.length) return false;

      final userSet = userGroup.toSet();
      final correctSet = entry.value.toSet();
      return userSet.containsAll(correctSet) && correctSet.containsAll(userSet);
    });
  }

  /// General validation method
  static bool validate(QuizQuestion question, dynamic userAnswer) {
    if (question is MultiChoiceQuestion) {
      return validateMultiChoice(question, userAnswer as int);
    } else if (question is FillInTheGapQuestion) {
      return validateFillInTheGap(question, userAnswer as List<String>);
    } else if (question is TrueFalseQuestion) {
      return validateTrueFalse(question, userAnswer as bool);
    } else if (question is MatchQuestion) {
      return validateMatch(question, userAnswer as Map<String, int>);
    } else if (question is ReorderQuestion) {
      return validateReorder(question, userAnswer as List<String>);
    } else if (question is DragAndDropQuestion) {
      return validateDragAndDrop(
        question,
        userAnswer as Map<String, List<int>>,
      );
    }
    return false;
  }
}

/// Quiz Score Calculator
class QuizScoreCalculator {
  static const int pointsPerQuestion = 20;

  /// Calculate score for a quiz based on correct answers
  static int calculateScore(List<bool> results) {
    final correctAnswers = results.where((r) => r).length;
    return correctAnswers * pointsPerQuestion;
  }

  /// Calculate score from question results
  static int calculateScoreFromQuestions(
    List<QuizQuestion> questions,
    List<dynamic> userAnswers,
  ) {
    if (questions.length != userAnswers.length) {
      throw ArgumentError('Questions and answers length mismatch');
    }

    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (QuizValidator.validate(questions[i], userAnswers[i])) {
        correctCount++;
      }
    }

    return correctCount * pointsPerQuestion;
  }

  /// Calculate percentage
  static double calculatePercentage(int score, int totalQuestions) {
    final maxScore = totalQuestions * pointsPerQuestion;
    if (maxScore == 0) return 0.0;
    return (score / maxScore) * 100;
  }

  /// Get grade based on percentage
  static String getGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  /// Get grade color
  static String getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return '#4CAF50'; // Green
      case 'B':
        return '#8BC34A'; // Light Green
      case 'C':
        return '#FFC107'; // Amber
      case 'D':
        return '#FF9800'; // Orange
      case 'F':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get performance message
  static String getPerformanceMessage(double percentage) {
    if (percentage >= 90) return 'Excellent work! 🎉';
    if (percentage >= 80) return 'Great job! 👏';
    if (percentage >= 70) return 'Good effort! 👍';
    if (percentage >= 60) return 'Keep practicing! 💪';
    if (percentage >= 50) return 'You can do better! 📚';
    return 'Need more practice. Don\'t give up! 🌟';
  }
}

/// Extension on Course
extension CourseExtensions on Course {
  /// Get total number of levels across all lessons
  int get totalLevels =>
      lessons.fold(0, (sum, lesson) => sum + lesson.levels.length);

  /// Get a specific lesson
  Lesson? getLesson(String lessonNumber) {
    try {
      return lessons.firstWhere((l) => l.lessonNumber == lessonNumber);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific level
  Level? getLevel(String lessonNumber, int levelNumber) {
    final lesson = getLesson(lessonNumber);
    return lesson?.levels.firstWhere((l) => l.levelNumber == levelNumber);
  }

  /// Get all levels flattened
  List<Level> get allLevels {
    return lessons.expand((lesson) => lesson.levels).toList();
  }

  /// Get total questions across all lessons
  int get totalQuestions {
    return allLevels.fold(0, (sum, level) => sum + level.quiz.questions.length);
  }

  /// Get maximum possible score across all lessons
  int get maxScore => totalQuestions * QuizScoreCalculator.pointsPerQuestion;
}

/// Extension on List<Course>
extension CourseListExtensions on List<Course> {
  /// Get total number of lessons across all courses
  int get totalLessons => fold(0, (sum, course) => sum + course.lessons.length);

  /// Get total number of levels across all courses
  int get totalLevels => fold(0, (sum, course) => sum + course.totalLevels);

  /// Get total questions across all courses
  int get totalQuestions =>
      fold(0, (sum, course) => sum + course.totalQuestions);

  /// Get maximum possible score across all courses
  int get maxScore => totalQuestions * QuizScoreCalculator.pointsPerQuestion;
}

/// Usage Example:
///
/// ```dart
/// // 1. Load course data
/// final course = await CourseLoader.loadCourse('introduction_to_beekeeping');
/// final allCourses = await CourseLoader.loadAllCourses(['course1', 'course2']);
///
/// // 2. Track progress
/// final tracker = QuizProgressTracker();
/// tracker.startLevel('1.1', 1);
/// tracker.completeLesson('1.1', 1);
///
/// // 3. Validate answer
/// final lesson = course.lessons[0];
/// final level = lesson.levels[0];
/// final question = level.quiz.questions[0];
/// final isCorrect = QuizValidator.validate(question, userAnswer);
///
/// // 4. Calculate score
/// final results = [true, false, true, true, false];
/// final score = QuizScoreCalculator.calculateScore(results);
/// final percentage = QuizScoreCalculator.calculatePercentage(score, 5);
/// final grade = QuizScoreCalculator.getGrade(percentage);
/// final message = QuizScoreCalculator.getPerformanceMessage(percentage);
///
/// tracker.completeQuiz('1.1', 1, score);
///
/// // 5. Get lesson score
/// final lessonScore = tracker.getLessonScore('1.1');
/// final totalScore = tracker.totalScore;
///
/// // 6. Save/Load progress
/// final progressJson = tracker.toJson();
/// // Later...
/// tracker.fromJson(progressJson);
/// ```
