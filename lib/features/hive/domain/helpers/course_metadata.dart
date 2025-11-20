// lib/features/hive/domain/helpers/course_metadata.dart

import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';

/// Course metadata helper - provides additional display information for courses
class CourseMetadata {
  final String courseId;
  final String displayTitle;
  final String? imagePath;
  final String? iconPath;
  final String difficultyLevel;
  final List<String> tags;
  final int estimatedMinutes;

  const CourseMetadata({
    required this.courseId,
    required this.displayTitle,
    this.imagePath,
    this.iconPath,
    required this.difficultyLevel,
    this.tags = const [],
    this.estimatedMinutes = 0,
  });
}

/// Predefined course metadata
class CourseMetadataRegistry {
  static const Map<String, CourseMetadata> registry = {
    'savings_101': CourseMetadata(
      courseId: 'savings_101',
      displayTitle: 'Savings 101',
      difficultyLevel: 'Beginner-friendly',
      tags: ['savings', 'budgeting', 'beginner'],
      estimatedMinutes: 45,
    ),
    'budgeting_basics': CourseMetadata(
      courseId: 'budgeting_basics',
      displayTitle: 'Budgeting Basics',
      difficultyLevel: 'Beginner-friendly',
      tags: ['budgeting', 'planning', 'beginner'],
      estimatedMinutes: 60,
    ),
    'investing_intro': CourseMetadata(
      courseId: 'investing_intro',
      displayTitle: 'Investing Intro',
      difficultyLevel: 'Intermediate',
      tags: ['investing', 'stocks', 'intermediate'],
      estimatedMinutes: 75,
    ),
    'debt_management': CourseMetadata(
      courseId: 'debt_management',
      displayTitle: 'Debt Management',
      difficultyLevel: 'Beginner-friendly',
      tags: ['debt', 'credit', 'beginner'],
      estimatedMinutes: 50,
    ),
    'credit_scores': CourseMetadata(
      courseId: 'credit_scores',
      displayTitle: 'Credit Scores',
      difficultyLevel: 'Beginner-friendly',
      tags: ['credit', 'scores', 'beginner'],
      estimatedMinutes: 40,
    ),
    'emergency_funds': CourseMetadata(
      courseId: 'emergency_funds',
      displayTitle: 'Emergency Funds',
      difficultyLevel: 'Beginner-friendly',
      tags: ['savings', 'emergency', 'beginner'],
      estimatedMinutes: 35,
    ),
    'retirement_planning': CourseMetadata(
      courseId: 'retirement_planning',
      displayTitle: 'Retirement Planning',
      difficultyLevel: 'Intermediate',
      tags: ['retirement', '401k', 'intermediate'],
      estimatedMinutes: 90,
    ),
    'tax_basics': CourseMetadata(
      courseId: 'tax_basics',
      displayTitle: 'Tax Basics',
      difficultyLevel: 'Intermediate',
      tags: ['taxes', 'deductions', 'intermediate'],
      estimatedMinutes: 70,
    ),
  };

  static CourseMetadata? getMetadata(String courseId) {
    return registry[courseId];
  }

  static String getDifficultyLevel(String courseId) {
    return registry[courseId]?.difficultyLevel ?? 'Beginner-friendly';
  }

  static String getEstimatedTime(String courseId) {
    final minutes = registry[courseId]?.estimatedMinutes ?? 0;
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $remainingMinutes min';
    }
  }
}

/// Extension on Course to get metadata
extension CourseMetadataExtension on Course {
  /// Get metadata for this course by inferring courseId from title
  CourseMetadata? get metadata {
    final courseId = _inferCourseId();
    return CourseMetadataRegistry.getMetadata(courseId);
  }

  /// Infer course ID from title
  String _inferCourseId() {
    return courseTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  /// Get difficulty level
  String get difficultyLevel {
    return metadata?.difficultyLevel ?? _inferDifficultyFromStructure();
  }

  /// Infer difficulty from course structure
  String _inferDifficultyFromStructure() {
    // final totalLevels = this.totalLevels; // TODO: Add totalLevels to courses
    final totalLevels = 5;

    if (totalLevels <= 3) {
      return 'Beginner-friendly';
    } else if (totalLevels <= 6) {
      return 'Intermediate';
    } else {
      return 'Advanced';
    }
  }

  /// Get estimated time
  String get estimatedTime {
    // final minutes = metadata?.estimatedMinutes ?? (totalLevels * 10); // TODO: Add totalLevels to courses
    final minutes = metadata?.estimatedMinutes ?? (5 * 10);
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $remainingMinutes min';
    }
  }
}
