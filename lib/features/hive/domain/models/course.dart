// Main course model
class Course {
  final String courseTitle;
  final String courseDescription;
  final List<Lesson> lessons;

  Course({
    required this.courseTitle,
    required this.courseDescription,
    required this.lessons,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseTitle: json['courseTitle'] as String,
      courseDescription: json['courseDescription'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((lesson) => Lesson.fromJson(lesson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseTitle': courseTitle,
      'courseDescription': courseDescription,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

// Lesson model
class Lesson {
  final String lessonNumber;
  final String lessonTitle;
  final String lessonDescription;
  final List<Level> levels;

  Lesson({
    required this.lessonNumber,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.levels,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonNumber: json['lessonNumber'] as String,
      lessonTitle: json['lessonTitle'] as String,
      lessonDescription: json['lessonDescription'] as String,
      levels: (json['levels'] as List<dynamic>)
          .map((level) => Level.fromJson(level as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonNumber': lessonNumber,
      'lessonTitle': lessonTitle,
      'lessonDescription': lessonDescription,
      'levels': levels.map((level) => level.toJson()).toList(),
    };
  }
}

// Level model
class Level {
  final int levelNumber;
  final String introduction;
  final List<Section> sections;
  final String? funFact;
  final List<String> highlights;
  final String? tip;
  final Quiz quiz;

  Level({
    required this.levelNumber,
    required this.introduction,
    required this.sections,
    this.funFact,
    required this.highlights,
    this.tip,
    required this.quiz,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelNumber: json['levelNumber'] as int,
      introduction: json['introduction'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((section) => Section.fromJson(section as Map<String, dynamic>))
          .toList(),
      funFact: json['funFact'] as String?,
      highlights: (json['highlights'] as List<dynamic>)
          .map((h) => h as String)
          .toList(),
      tip: json['tip'] as String?,
      quiz: Quiz.fromJson(json['quiz'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'introduction': introduction,
      'sections': sections.map((section) => section.toJson()).toList(),
      if (funFact != null) 'funFact': funFact,
      'highlights': highlights,
      if (tip != null) 'tip': tip,
      'quiz': quiz.toJson(),
    };
  }
}

// Section model
class Section {
  final String heading;
  final String? content;
  final List<String>? bulletPoints;

  Section({required this.heading, this.content, this.bulletPoints});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      heading: json['heading'] as String,
      content: json['content'] as String?,
      bulletPoints: json['bulletPoints'] != null
          ? (json['bulletPoints'] as List<dynamic>)
                .map((bp) => bp as String)
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      if (content != null) 'content': content,
      if (bulletPoints != null) 'bulletPoints': bulletPoints,
    };
  }
}

// Quiz model
class Quiz {
  final String focus;
  final List<QuizQuestion> questions;

  Quiz({required this.focus, required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      focus: json['focus'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'focus': focus,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

// Base quiz question class
abstract class QuizQuestion {
  final String type;
  final String question;

  QuizQuestion({required this.type, required this.question});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'multiChoice':
        return MultiChoiceQuestion.fromJson(json);
      case 'fillInTheGap':
        return FillInTheGapQuestion.fromJson(json);
      case 'match':
        return MatchQuestion.fromJson(json);
      case 'trueFalse':
        return TrueFalseQuestion.fromJson(json);
      case 'reorder':
        return ReorderQuestion.fromJson(json);
      case 'dragAndDrop':
        return DragAndDropQuestion.fromJson(json);
      default:
        throw Exception('Unknown question type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

// Multi-choice question
class MultiChoiceQuestion extends QuizQuestion {
  final List<String> options;
  final int correctAnswer;

  MultiChoiceQuestion({
    required super.question,
    required this.options,
    required this.correctAnswer,
  }) : super(type: 'multiChoice');

  factory MultiChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultiChoiceQuestion(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => o as String)
          .toList(),
      correctAnswer: json['correctAnswer'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

// Fill in the gap question
class FillInTheGapQuestion extends QuizQuestion {
  final List<String> correctAnswer;

  FillInTheGapQuestion({required super.question, required this.correctAnswer})
    : super(type: 'fillInTheGap');

  factory FillInTheGapQuestion.fromJson(Map<String, dynamic> json) {
    return FillInTheGapQuestion(
      question: json['question'] as String,
      correctAnswer: (json['correctAnswer'] as List<dynamic>)
          .map((a) => a as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'question': question, 'correctAnswer': correctAnswer};
  }
}

// Match question
class MatchQuestion extends QuizQuestion {
  final List<String> leftOptions;
  final List<String> rightOptions;
  final Map<String, int> correctMatches;

  MatchQuestion({
    required super.question,
    required this.leftOptions,
    required this.rightOptions,
    required this.correctMatches,
  }) : super(type: 'match');

  factory MatchQuestion.fromJson(Map<String, dynamic> json) {
    return MatchQuestion(
      question: json['question'] as String,
      leftOptions: (json['leftOptions'] as List<dynamic>)
          .map((o) => o as String)
          .toList(),
      rightOptions: (json['rightOptions'] as List<dynamic>)
          .map((o) => o as String)
          .toList(),
      correctMatches: (json['correctMatches'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'question': question,
      'leftOptions': leftOptions,
      'rightOptions': rightOptions,
      'correctMatches': correctMatches,
    };
  }
}

// True/False question
class TrueFalseQuestion extends QuizQuestion {
  final bool correctAnswer;

  TrueFalseQuestion({required super.question, required this.correctAnswer})
    : super(type: 'trueFalse');

  factory TrueFalseQuestion.fromJson(Map<String, dynamic> json) {
    return TrueFalseQuestion(
      question: json['question'] as String,
      correctAnswer: json['correctAnswer'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'question': question, 'correctAnswer': correctAnswer};
  }
}

// Reorder question
class ReorderQuestion extends QuizQuestion {
  final List<String> options;
  final List<String> correctAnswer;

  ReorderQuestion({
    required super.question,
    required this.options,
    required this.correctAnswer,
  }) : super(type: 'reorder');

  factory ReorderQuestion.fromJson(Map<String, dynamic> json) {
    return ReorderQuestion(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => o as String)
          .toList(),
      correctAnswer: (json['correctAnswer'] as List<dynamic>)
          .map((a) => a as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

// Drag and drop question
class DragAndDropQuestion extends QuizQuestion {
  final List<String> items;
  final Map<String, List<int>> groups;

  DragAndDropQuestion({
    required super.question,
    required this.items,
    required this.groups,
  }) : super(type: 'dragAndDrop');

  factory DragAndDropQuestion.fromJson(Map<String, dynamic> json) {
    return DragAndDropQuestion(
      question: json['question'] as String,
      items: (json['items'] as List<dynamic>).map((i) => i as String).toList(),
      groups: (json['groups'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((v) => v as int).toList(),
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'question': question,
      'items': items,
      'groups': groups,
    };
  }
}
