// lib/features/hive/domain/helpers/quiz_helpers.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_data_models.dart';

/// Quiz Loader - handles loading quiz data from assets
class QuizLoader {
  static const String _basePath = 'assets/data/quizzes';

  /// Load a specific level
  static Future<QuizLevel> loadLevel(int level) async {
    try {
      final jsonString = await rootBundle.loadString('$_basePath/level$level.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return QuizLevel.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load level $level: $e');
    }
  }

  /// Load bonus level
  static Future<QuizLevel> loadBonusLevel(String type) async {
    try {
      final jsonString = await rootBundle.loadString('$_basePath/bonus_$type.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return QuizLevel.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load bonus level $type: $e');
    }
  }

  /// Load all available levels
  static Future<List<QuizLevel>> loadAllLevels() async {
    final levels = <QuizLevel>[];

    // Load levels 2-5
    for (int i = 2; i <= 5; i++) {
      try {
        levels.add(await loadLevel(i));
      } catch (e) {
        print('Error loading level $i: $e');
      }
    }

    // Load bonus levels
    for (final bonusType in ['student', 'professional']) {
      try {
        levels.add(await loadBonusLevel(bonusType));
      } catch (e) {
        print('Error loading $bonusType bonus level: $e');
      }
    }

    return levels;
  }

  /// Parse JSON string directly
  static QuizLevel parseJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return QuizLevel.fromJson(json);
  }
}

/// Quiz Progress Tracker
class QuizProgressTracker {
  final Map<String, ModuleProgress> _progress = {};

  /// Start a new module
  void startModule(int level, int moduleNumber) {
    final key = _getKey(level, moduleNumber);
    if (!_progress.containsKey(key)) {
      _progress[key] = ModuleProgress(
        level: level,
        moduleNumber: moduleNumber,
        lessonCompleted: false,
        quizCompleted: false,
        score: 0,
        attempts: 0,
      );
    }
  }

  /// Mark lesson as completed
  void completeLesson(int level, int moduleNumber) {
    final key = _getKey(level, moduleNumber);
    final current = _progress[key];
    if (current != null) {
      _progress[key] = current.copyWith(lessonCompleted: true);
    } else {
      startModule(level, moduleNumber);
      _progress[key] = _progress[key]!.copyWith(lessonCompleted: true);
    }
  }

  /// Mark quiz as completed with score
  void completeQuiz(int level, int moduleNumber, int score) {
    final key = _getKey(level, moduleNumber);
    final current = _progress[key];
    if (current != null) {
      _progress[key] = current.copyWith(
        quizCompleted: true,
        score: score,
        attempts: current.attempts + 1,
      );
    } else {
      startModule(level, moduleNumber);
      _progress[key] = _progress[key]!.copyWith(
        quizCompleted: true,
        score: score,
        attempts: 1,
      );
    }
  }

  /// Check if module is completed
  bool isModuleCompleted(int level, int moduleNumber) {
    final key = _getKey(level, moduleNumber);
    final progress = _progress[key];
    return progress?.quizCompleted ?? false;
  }

  /// Check if lesson is completed
  bool isLessonCompleted(int level, int moduleNumber) {
    final key = _getKey(level, moduleNumber);
    final progress = _progress[key];
    return progress?.lessonCompleted ?? false;
  }

  /// Get module progress
  ModuleProgress? getProgress(int level, int moduleNumber) {
    return _progress[_getKey(level, moduleNumber)];
  }

  /// Calculate total score for a level
  int getLevelScore(int level) {
    return _progress.values
        .where((p) => p.level == level && p.quizCompleted)
        .fold(0, (sum, p) => sum + p.score);
  }

  /// Calculate total score across all levels
  int get totalScore {
    return _progress.values
        .where((p) => p.quizCompleted)
        .fold(0, (sum, p) => sum + p.score);
  }

  /// Get number of completed modules
  int get completedModules {
    return _progress.values.where((p) => p.quizCompleted).length;
  }

  /// Clear all progress
  void clearProgress() {
    _progress.clear();
  }

  /// Reset specific module
  void resetModule(int level, int moduleNumber) {
    _progress.remove(_getKey(level, moduleNumber));
  }

  String _getKey(int level, int moduleNumber) => '$level-$moduleNumber';

  /// Export progress as JSON
  Map<String, dynamic> toJson() {
    return {
      'progress': _progress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  /// Import progress from JSON
  void fromJson(Map<String, dynamic> json) {
    _progress.clear();
    final progressMap = json['progress'] as Map<String, dynamic>;
    progressMap.forEach((key, value) {
      _progress[key] = ModuleProgress.fromJson(value as Map<String, dynamic>);
    });
  }
}

/// Module Progress Model
class ModuleProgress {
  final int level;
  final int moduleNumber;
  final bool lessonCompleted;
  final bool quizCompleted;
  final int score;
  final int attempts;

  ModuleProgress({
    required this.level,
    required this.moduleNumber,
    required this.lessonCompleted,
    required this.quizCompleted,
    required this.score,
    required this.attempts,
  });

  ModuleProgress copyWith({
    int? level,
    int? moduleNumber,
    bool? lessonCompleted,
    bool? quizCompleted,
    int? score,
    int? attempts,
  }) {
    return ModuleProgress(
      level: level ?? this.level,
      moduleNumber: moduleNumber ?? this.moduleNumber,
      lessonCompleted: lessonCompleted ?? this.lessonCompleted,
      quizCompleted: quizCompleted ?? this.quizCompleted,
      score: score ?? this.score,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'moduleNumber': moduleNumber,
      'lessonCompleted': lessonCompleted,
      'quizCompleted': quizCompleted,
      'score': score,
      'attempts': attempts,
    };
  }

  factory ModuleProgress.fromJson(Map<String, dynamic> json) {
    return ModuleProgress(
      level: json['level'] as int,
      moduleNumber: json['moduleNumber'] as int,
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
  static bool validateMultiChoice(QuizQuestion question, int userAnswer) {
    return question.correctAnswer == userAnswer;
  }

  /// Validate fill in the gap answer (case insensitive, trimmed)
  static bool validateFillInTheGap(QuizQuestion question, String userAnswer) {
    final answer = userAnswer.trim().toLowerCase();
    final correct = question.correctAnswerText?.trim().toLowerCase();

    // Check for alternative answers (comma separated)
    if (correct?.contains(',') ?? false) {
      final alternatives = correct!.split(',').map((s) => s.trim());
      return alternatives.contains(answer);
    }

    return answer == correct;
  }

  /// Validate true/false answer
  static bool validateTrueFalse(QuizQuestion question, bool userAnswer) {
    return question.correctBool == userAnswer;
  }

  /// Validate match answer
  static bool validateMatch(QuizQuestion question, Map<int, int> userMatches) {
    if (userMatches.length != question.correctMatches?.length) return false;

    return question.correctMatches!.entries.every(
      (entry) => userMatches[entry.key] == entry.value,
    );
  }

  /// Validate reorder answer
  static bool validateReorder(QuizQuestion question, List<String> userOrder) {
    final correctOrder = question.correctOrder;
    if (correctOrder == null || userOrder.length != correctOrder.length) {
      return false;
    }

    for (int i = 0; i < userOrder.length; i++) {
      if (userOrder[i] != correctOrder[i]) return false;
    }

    return true;
  }

  /// Validate drag and drop answer
  static bool validateDragAndDrop(
    QuizQuestion question,
    Map<String, List<String>> userCategories,
  ) {
    final correctCategories = question.categories;
    if (correctCategories == null) return false;

    return correctCategories.entries.every((entry) {
      final userCategory = userCategories[entry.key];
      if (userCategory == null) return false;

      // Check if all items match (order may not matter for drag and drop)
      if (userCategory.length != entry.value.length) return false;

      return entry.value.every((item) => userCategory.contains(item));
    });
  }

  /// General validation method - uses the question's built-in method
  static bool validate(QuizQuestion question, dynamic userAnswer) {
    return question.isAnswerCorrect(userAnswer);
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
      if (questions[i].isAnswerCorrect(userAnswers[i])) {
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

/// Extension on List<QuizLevel>
extension QuizLevelListExtensions on List<QuizLevel> {
  /// Get total number of modules across all levels
  int get totalModules => fold(0, (sum, level) => sum + level.modules.length);

  /// Get a specific level
  QuizLevel? getLevel(int levelNumber) {
    try {
      return firstWhere((l) => l.level == levelNumber);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific module
  QuizModule? getModule(int level, int moduleNumber) {
    final quizLevel = getLevel(level);
    return quizLevel?.getModule(moduleNumber);
  }

  /// Get all modules flattened
  List<QuizModule> get allModules {
    return expand((level) => level.modules).toList();
  }

  /// Get total questions across all levels
  int get totalQuestions {
    return fold(0, (sum, level) => sum + level.totalQuestions);
  }

  /// Get maximum possible score across all levels
  int get maxScore => totalQuestions * QuizScoreCalculator.pointsPerQuestion;
}

/// Usage Example:
///
/// ```dart
/// // 1. Load quiz data
/// final level2 = await QuizLoader.loadLevel(2);
/// final allLevels = await QuizLoader.loadAllLevels();
///
/// // 2. Track progress
/// final tracker = QuizProgressTracker();
/// tracker.startModule(2, 1);
/// tracker.completeLesson(2, 1);
///
/// // 3. Validate answer
/// final question = level2.modules[0].quiz.questions[0];
/// final isCorrect = question.isAnswerCorrect(userAnswer);
/// // or
/// final isCorrect2 = QuizValidator.validate(question, userAnswer);
///
/// // 4. Calculate score
/// final results = [true, false, true, true, false];
/// final score = QuizScoreCalculator.calculateScore(results);
/// final percentage = QuizScoreCalculator.calculatePercentage(score, 5);
/// final grade = QuizScoreCalculator.getGrade(percentage);
/// final message = QuizScoreCalculator.getPerformanceMessage(percentage);
///
/// tracker.completeQuiz(2, 1, score);
///
/// // 5. Get level score
/// final levelScore = tracker.getLevelScore(2);
/// final totalScore = tracker.totalScore;
///
/// // 6. Save/Load progress
/// final progressJson = tracker.toJson();
/// // Later...
/// tracker.fromJson(progressJson);
/// ```