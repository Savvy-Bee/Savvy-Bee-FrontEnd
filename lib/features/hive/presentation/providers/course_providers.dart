import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/helpers/quiz_helpers.dart';

/// Provider for course IDs to load
final courseIdsProvider = Provider<List<String>>((ref) {
  return ['savings_101', 'numeracy', 'budget_101'];
});

/// Provider to load a single course
final courseProvider = FutureProvider.family<Course, String>((
  ref,
  courseId,
) async {
  return await CourseLoader.loadCourse(courseId);
});

/// Provider to load all courses
final allCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final courseIds = ref.watch(courseIdsProvider);
  return await CourseLoader.loadAllCourses(courseIds);
});

/// Repository provider
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

/// State notifier for quiz progress tracking
class QuizProgressNotifier extends StateNotifier<QuizProgressTracker> {
  final ProgressRepository _repository;

  QuizProgressNotifier(this._repository) : super(QuizProgressTracker());

  /// Initialize and load progress (call this after provider is created)
  Future<void> initialize() async {
    final json = await _repository.loadProgress();
    if (json != null) {
      state.fromJson(json);
      // Trigger a rebuild by creating a new instance
      state = _cloneState();
    }
  }

  /// Helper method to clone the current state
  QuizProgressTracker _cloneState() {
    final tracker = QuizProgressTracker();
    tracker.fromJson(state.toJson());
    return tracker;
  }

  /// Save progress to storage
  Future<void> _saveProgress() async {
    await _repository.saveProgress(state.toJson());
  }

  /// Start a new level
  Future<void> startLevel(String lessonNumber, int levelNumber) async {
    state.startLevel(lessonNumber, levelNumber);
    state = _cloneState();
    await _saveProgress();
  }

  /// Complete a lesson
  Future<void> completeLesson(String lessonNumber, int levelNumber) async {
    state.completeLesson(lessonNumber, levelNumber);
    state = _cloneState();
    await _saveProgress();
  }

  /// Complete a quiz with score
  Future<void> completeQuiz(
    String lessonNumber,
    int levelNumber,
    int score,
  ) async {
    state.completeQuiz(lessonNumber, levelNumber, score);
    state = _cloneState();
    await _saveProgress();
  }

  /// Reset a specific level
  Future<void> resetLevel(String lessonNumber, int levelNumber) async {
    state.resetLevel(lessonNumber, levelNumber);
    state = _cloneState();
    await _saveProgress();
  }

  /// Clear all progress
  Future<void> clearProgress() async {
    state.clearProgress();
    state = QuizProgressTracker();
    await _saveProgress();
  }
}

/// Provider for quiz progress tracking
final quizProgressProvider =
    StateNotifierProvider<QuizProgressNotifier, QuizProgressTracker>((ref) {
      final repository = ref.watch(progressRepositoryProvider);
      return QuizProgressNotifier(repository);
    });

/// Provider to check if a level is completed
final isLevelCompletedProvider =
    Provider.family<bool, ({String lessonNumber, int levelNumber})>((
      ref,
      params,
    ) {
      final tracker = ref.watch(quizProgressProvider);
      return tracker.isLevelCompleted(params.lessonNumber, params.levelNumber);
    });

/// Provider to check if lesson content is completed
final isLessonContentCompletedProvider =
    Provider.family<bool, ({String lessonNumber, int levelNumber})>((
      ref,
      params,
    ) {
      final tracker = ref.watch(quizProgressProvider);
      return tracker.isLessonCompleted(params.lessonNumber, params.levelNumber);
    });

/// Provider to get level progress
final levelProgressProvider =
    Provider.family<LevelProgress?, ({String lessonNumber, int levelNumber})>((
      ref,
      params,
    ) {
      final tracker = ref.watch(quizProgressProvider);
      return tracker.getProgress(params.lessonNumber, params.levelNumber);
    });

/// Provider to get total score
final totalScoreProvider = Provider<int>((ref) {
  final tracker = ref.watch(quizProgressProvider);
  return tracker.totalScore;
});

/// Provider to get completed levels count
final completedLevelsProvider = Provider<int>((ref) {
  final tracker = ref.watch(quizProgressProvider);
  return tracker.completedLevels;
});

/// Provider to get lesson score
final lessonScoreProvider = Provider.family<int, String>((ref, lessonNumber) {
  final tracker = ref.watch(quizProgressProvider);
  return tracker.getLessonScore(lessonNumber);
});

/// Provider to get course statistics
final courseStatsProvider = Provider.family<CourseStats, Course>((ref, course) {
  final tracker = ref.watch(quizProgressProvider);

  int completedLessons = 0;
  int totalLevels = course.totalLevels;
  int completedLevels = 0;

  for (final lesson in course.lessons) {
    bool lessonFullyCompleted = true;
    for (final level in lesson.levels) {
      final isCompleted = tracker.isLevelCompleted(
        lesson.lessonNumber,
        level.levelNumber,
      );
      if (isCompleted) {
        completedLevels++;
      } else {
        lessonFullyCompleted = false;
      }
    }
    if (lessonFullyCompleted && lesson.levels.isNotEmpty) {
      completedLessons++;
    }
  }

  return CourseStats(
    totalLessons: course.lessons.length,
    completedLessons: completedLessons,
    totalLevels: totalLevels,
    completedLevels: completedLevels,
    progressPercentage: totalLevels > 0
        ? (completedLevels / totalLevels * 100)
        : 0,
  );
});

/// Course statistics model
class CourseStats {
  final int totalLessons;
  final int completedLessons;
  final int totalLevels;
  final int completedLevels;
  final double progressPercentage;

  CourseStats({
    required this.totalLessons,
    required this.completedLessons,
    required this.totalLevels,
    required this.completedLevels,
    required this.progressPercentage,
  });

  bool get isCompleted => completedLevels == totalLevels && totalLevels > 0;
  bool get isStarted => completedLevels > 0;
}

/// Provider to get difficulty level color
final difficultyColorProvider = Provider.family<String, String>((
  ref,
  difficulty,
) {
  switch (difficulty.toLowerCase()) {
    case 'beginner':
    case 'beginner-friendly':
      return '#4CAF50'; // Green
    case 'intermediate':
      return '#FFC107'; // Amber
    case 'advanced':
      return '#F44336'; // Red
    default:
      return '#9E9E9E'; // Grey
  }
});
