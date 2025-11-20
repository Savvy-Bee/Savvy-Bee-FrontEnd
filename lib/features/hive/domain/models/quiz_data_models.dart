// /// Enum for Quiz Types
// enum QuizType {
//   multiChoice,
//   fillInTheGap,
//   match,
//   trueFalse,
//   dragAndDrop,
//   reorder,
// }

// /// Extension to convert string to QuizType
// extension QuizTypeExtension on QuizType {
//   String toJson() {
//     switch (this) {
//       case QuizType.multiChoice:
//         return 'multiChoice';
//       case QuizType.fillInTheGap:
//         return 'fillInTheGap';
//       case QuizType.match:
//         return 'match';
//       case QuizType.trueFalse:
//         return 'trueFalse';
//       case QuizType.dragAndDrop:
//         return 'dragAndDrop';
//       case QuizType.reorder:
//         return 'reorder';
//     }
//   }

//   static QuizType fromJson(String value) {
//     switch (value) {
//       case 'multiChoice':
//         return QuizType.multiChoice;
//       case 'fillInTheGap':
//         return QuizType.fillInTheGap;
//       case 'match':
//         return QuizType.match;
//       case 'trueFalse':
//         return QuizType.trueFalse;
//       case 'dragAndDrop':
//         return QuizType.dragAndDrop;
//       case 'reorder':
//         return QuizType.reorder;
//       default:
//         throw Exception('Unknown QuizType: $value');
//     }
//   }
// }

// /// Root Level Model
// class QuizLevel {
//   final int level;
//   final String title;
//   final List<QuizModule> modules;
//   final String? bonusLevel;

//   QuizLevel({
//     required this.level,
//     required this.title,
//     required this.modules,
//     this.bonusLevel,
//   });

//   factory QuizLevel.fromJson(Map<String, dynamic> json) {
//     return QuizLevel(
//       level: json['level'] as int,
//       title: json['title'] as String,
//       modules: (json['modules'] as List)
//           .map((m) => QuizModule.fromJson(m as Map<String, dynamic>))
//           .toList(),
//       bonusLevel: json['bonusLevel'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'level': level,
//       'title': title,
//       'modules': modules.map((m) => m.toJson()).toList(),
//       if (bonusLevel != null) 'bonusLevel': bonusLevel,
//     };
//   }

//   QuizLevel copyWith({
//     int? level,
//     String? title,
//     List<QuizModule>? modules,
//     String? bonusLevel,
//   }) {
//     return QuizLevel(
//       level: level ?? this.level,
//       title: title ?? this.title,
//       modules: modules ?? this.modules,
//       bonusLevel: bonusLevel ?? this.bonusLevel,
//     );
//   }
// }

// /// Module Model (contains lesson + quiz)
// class QuizModule {
//   final int moduleNumber;
//   final String title;
//   final Lesson lesson;
//   final Quiz quiz;

//   QuizModule({
//     required this.moduleNumber,
//     required this.title,
//     required this.lesson,
//     required this.quiz,
//   });

//   factory QuizModule.fromJson(Map<String, dynamic> json) {
//     return QuizModule(
//       moduleNumber: json['moduleNumber'] as int,
//       title: json['title'] as String,
//       lesson: Lesson.fromJson(json['lesson'] as Map<String, dynamic>),
//       quiz: Quiz.fromJson(json['quiz'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'moduleNumber': moduleNumber,
//       'title': title,
//       'lesson': lesson.toJson(),
//       'quiz': quiz.toJson(),
//     };
//   }

//   QuizModule copyWith({
//     int? moduleNumber,
//     String? title,
//     Lesson? lesson,
//     Quiz? quiz,
//   }) {
//     return QuizModule(
//       moduleNumber: moduleNumber ?? this.moduleNumber,
//       title: title ?? this.title,
//       lesson: lesson ?? this.lesson,
//       quiz: quiz ?? this.quiz,
//     );
//   }
// }

// /// Lesson Model
// class Lesson {
//   final String introduction;
//   final List<LessonSection> sections;
//   final List<String> highlights;
//   final String? funFact;
//   final String? tip;
//   final String? conclusion;

//   Lesson({
//     required this.introduction,
//     required this.sections,
//     required this.highlights,
//     this.funFact,
//     this.tip,
//     this.conclusion,
//   });

//   factory Lesson.fromJson(Map<String, dynamic> json) {
//     return Lesson(
//       introduction: json['introduction'] as String,
//       sections: (json['sections'] as List)
//           .map((s) => LessonSection.fromJson(s as Map<String, dynamic>))
//           .toList(),
//       highlights: (json['highlights'] as List).cast<String>(),
//       funFact: json['funFact'] as String?,
//       tip: json['tip'] as String?,
//       conclusion: json['conclusion'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'introduction': introduction,
//       'sections': sections.map((s) => s.toJson()).toList(),
//       'highlights': highlights,
//       if (funFact != null) 'funFact': funFact,
//       if (tip != null) 'tip': tip,
//       if (conclusion != null) 'conclusion': conclusion,
//     };
//   }

//   Lesson copyWith({
//     String? introduction,
//     List<LessonSection>? sections,
//     List<String>? highlights,
//     String? funFact,
//     String? tip,
//     String? conclusion,
//   }) {
//     return Lesson(
//       introduction: introduction ?? this.introduction,
//       sections: sections ?? this.sections,
//       highlights: highlights ?? this.highlights,
//       funFact: funFact ?? this.funFact,
//       tip: tip ?? this.tip,
//       conclusion: conclusion ?? this.conclusion,
//     );
//   }
// }

// /// Lesson Section Model
// class LessonSection {
//   final String heading;
//   final String? content;
//   final List<String>? bulletPoints;
//   final List<String>? orderedList;
//   final String? note;

//   LessonSection({
//     required this.heading,
//     this.content,
//     this.bulletPoints,
//     this.orderedList,
//     this.note,
//   });

//   factory LessonSection.fromJson(Map<String, dynamic> json) {
//     return LessonSection(
//       heading: json['heading'] as String,
//       content: json['content'] as String?,
//       bulletPoints: (json['bulletPoints'] as List?)?.cast<String>(),
//       orderedList: (json['orderedList'] as List?)?.cast<String>(),
//       note: json['note'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'heading': heading,
//       if (content != null) 'content': content,
//       if (bulletPoints != null) 'bulletPoints': bulletPoints,
//       if (orderedList != null) 'orderedList': orderedList,
//       if (note != null) 'note': note,
//     };
//   }

//   LessonSection copyWith({
//     String? heading,
//     String? content,
//     List<String>? bulletPoints,
//     List<String>? orderedList,
//     String? note,
//   }) {
//     return LessonSection(
//       heading: heading ?? this.heading,
//       content: content ?? this.content,
//       bulletPoints: bulletPoints ?? this.bulletPoints,
//       orderedList: orderedList ?? this.orderedList,
//       note: note ?? this.note,
//     );
//   }
// }

// /// Quiz Model
// class Quiz {
//   final String focus;
//   final List<QuizQuestion> questions;

//   Quiz({
//     required this.focus,
//     required this.questions,
//   });

//   factory Quiz.fromJson(Map<String, dynamic> json) {
//     return Quiz(
//       focus: json['focus'] as String,
//       questions: (json['questions'] as List)
//           .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'focus': focus,
//       'questions': questions.map((q) => q.toJson()).toList(),
//     };
//   }

//   Quiz copyWith({
//     String? focus,
//     List<QuizQuestion>? questions,
//   }) {
//     return Quiz(
//       focus: focus ?? this.focus,
//       questions: questions ?? this.questions,
//     );
//   }
// }

// /// Quiz Question Model
// class QuizQuestion {
//   final QuizType type;
//   final String question;

//   // For multiChoice
//   final List<String>? options;
//   final int? correctAnswer;

//   // For fillInTheGap
//   final String? correctAnswerText;

//   // For match
//   final List<String>? leftOptions;
//   final List<String>? rightOptions;
//   final Map<int, int>? correctMatches;

//   // For trueFalse
//   final bool? correctBool;

//   // For dragAndDrop
//   final List<String>? items;
//   final Map<String, List<String>>? categories;

//   // For reorder
//   final List<String>? correctOrder;

//   QuizQuestion({
//     required this.type,
//     required this.question,
//     this.options,
//     this.correctAnswer,
//     this.correctAnswerText,
//     this.leftOptions,
//     this.rightOptions,
//     this.correctMatches,
//     this.correctBool,
//     this.items,
//     this.categories,
//     this.correctOrder,
//   });

//   factory QuizQuestion.fromJson(Map<String, dynamic> json) {
//     final type = QuizTypeExtension.fromJson(json['type'] as String);

//     // Parse correctMatches for match type
//     Map<int, int>? correctMatches;
//     if (type == QuizType.match && json['correctMatches'] != null) {
//       final matches = json['correctMatches'] as Map<String, dynamic>;
//       correctMatches = matches.map(
//         (key, value) => MapEntry(int.parse(key), value as int),
//       );
//     }

//     // Parse categories for dragAndDrop type
//     Map<String, List<String>>? categories;
//     if (json['categories'] != null) {
//       final cats = json['categories'] as Map<String, dynamic>;
//       categories = cats.map(
//         (key, value) => MapEntry(key, (value as List).cast<String>()),
//       );
//     }

//     return QuizQuestion(
//       type: type,
//       question: json['question'] as String,
//       options: (json['options'] as List?)?.cast<String>(),
//       correctAnswer: json['correctAnswer'] is int ? json['correctAnswer'] as int : null,
//       correctAnswerText: json['correctAnswer'] is String ? json['correctAnswer'] as String : null,
//       leftOptions: (json['leftOptions'] as List?)?.cast<String>(),
//       rightOptions: (json['rightOptions'] as List?)?.cast<String>(),
//       correctMatches: correctMatches,
//       correctBool: json['correctAnswer'] is bool ? json['correctAnswer'] as bool : null,
//       items: (json['items'] as List?)?.cast<String>(),
//       categories: categories,
//       correctOrder: (json['correctAnswer'] is List) ? (json['correctAnswer'] as List).cast<String>() : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final json = <String, dynamic>{
//       'type': type.toJson(),
//       'question': question,
//     };

//     if (options != null) json['options'] = options;
//     if (leftOptions != null) json['leftOptions'] = leftOptions;
//     if (rightOptions != null) json['rightOptions'] = rightOptions;
//     if (items != null) json['items'] = items;

//     // Add correct answer based on type
//     switch (type) {
//       case QuizType.multiChoice:
//         if (correctAnswer != null) json['correctAnswer'] = correctAnswer;
//         break;
//       case QuizType.fillInTheGap:
//         if (correctAnswerText != null) json['correctAnswer'] = correctAnswerText;
//         break;
//       case QuizType.trueFalse:
//         if (correctBool != null) json['correctAnswer'] = correctBool;
//         break;
//       case QuizType.match:
//         if (correctMatches != null) {
//           json['correctMatches'] = correctMatches?.map(
//             (key, value) => MapEntry(key.toString(), value),
//           );
//         }
//         break;
//       case QuizType.reorder:
//         if (correctOrder != null) json['correctAnswer'] = correctOrder;
//         break;
//       case QuizType.dragAndDrop:
//         if (categories != null) json['categories'] = categories;
//         break;
//     }

//     return json;
//   }

//   QuizQuestion copyWith({
//     QuizType? type,
//     String? question,
//     List<String>? options,
//     int? correctAnswer,
//     String? correctAnswerText,
//     List<String>? leftOptions,
//     List<String>? rightOptions,
//     Map<int, int>? correctMatches,
//     bool? correctBool,
//     List<String>? items,
//     Map<String, List<String>>? categories,
//     List<String>? correctOrder,
//   }) {
//     return QuizQuestion(
//       type: type ?? this.type,
//       question: question ?? this.question,
//       options: options ?? this.options,
//       correctAnswer: correctAnswer ?? this.correctAnswer,
//       correctAnswerText: correctAnswerText ?? this.correctAnswerText,
//       leftOptions: leftOptions ?? this.leftOptions,
//       rightOptions: rightOptions ?? this.rightOptions,
//       correctMatches: correctMatches ?? this.correctMatches,
//       correctBool: correctBool ?? this.correctBool,
//       items: items ?? this.items,
//       categories: categories ?? this.categories,
//       correctOrder: correctOrder ?? this.correctOrder,
//     );
//   }

//   /// Check if the answer is correct
//   bool isAnswerCorrect(dynamic userAnswer) {
//     switch (type) {
//       case QuizType.multiChoice:
//         return userAnswer == correctAnswer;

//       case QuizType.fillInTheGap:
//         final answer = (userAnswer as String).trim().toLowerCase();
//         final correct = correctAnswerText?.trim().toLowerCase();
        
//         // Check for multiple acceptable answers (comma-separated)
//         if (correct?.contains(',') ?? false) {
//           return correct!.split(',').map((s) => s.trim()).contains(answer);
//         }
        
//         return answer == correct;

//       case QuizType.trueFalse:
//         return userAnswer == correctBool;

//       case QuizType.match:
//         if (userAnswer is! Map<int, int>) return false;
//         return correctMatches?.entries.every(
//               (entry) => userAnswer[entry.key] == entry.value,
//             ) ??
//             false;

//       case QuizType.reorder:
//         if (userAnswer is! List<String>) return false;
//         return _listEquals(userAnswer, correctOrder ?? []);

//       case QuizType.dragAndDrop:
//         if (userAnswer is! Map<String, List<String>>) return false;
//         return categories?.entries.every((entry) {
//               final userCategory = userAnswer[entry.key];
//               return userCategory != null &&
//                   _listEquals(userCategory, entry.value);
//             }) ??
//             false;
//     }
//   }

//   bool _listEquals(List<String> a, List<String> b) {
//     if (a.length != b.length) return false;
//     for (int i = 0; i < a.length; i++) {
//       if (a[i] != b[i]) return false;
//     }
//     return true;
//   }
// }

// /// Extension methods for QuizLevel
// extension QuizLevelExtensions on QuizLevel {
//   /// Get total number of modules
//   int get totalModules => modules.length;

//   /// Get a specific module by number
//   QuizModule? getModule(int moduleNumber) {
//     try {
//       return modules.firstWhere((m) => m.moduleNumber == moduleNumber);
//     } catch (e) {
//       return null;
//     }
//   }

//   /// Get total questions across all modules
//   int get totalQuestions {
//     return modules.fold(0, (sum, module) => sum + module.quiz.questions.length);
//   }
// }

// /// Extension methods for QuizModule
// extension QuizModuleExtensions on QuizModule {
//   /// Get total number of questions
//   int get totalQuestions => quiz.questions.length;

//   /// Get maximum possible score
//   int get maxScore => totalQuestions * 20;

//   /// Check if module has lesson content
//   bool get hasLessonContent => lesson.introduction.isNotEmpty;
// }