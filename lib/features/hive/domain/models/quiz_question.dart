// // enum QuizType { multiChoice, fillInTheGap, match, trueFalse, dragAndDrop, reorder }
// enum QuizType { multiChoice, reorder, match }

// class QuizQuestion {
//   final QuizType type; // Add type to each question
//   final String question;
//   final List<String> options;
//   final dynamic correctAnswer; // Can be int, List<String>, or Map<int, int>

//   // For match type
//   final List<String>? leftOptions;
//   final List<String>? rightOptions;
//   final Map<int, int>? correctMatches;

//   QuizQuestion({
//     required this.type,
//     required this.question,
//     this.options = const [],
//     this.correctAnswer,
//     this.leftOptions,
//     this.rightOptions,
//     this.correctMatches,
//   });
// }
