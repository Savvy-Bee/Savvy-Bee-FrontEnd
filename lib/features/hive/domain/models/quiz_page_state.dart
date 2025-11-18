// lib/features/hive/presentation/screens/quiz/models/quiz_page_state.dart

class QuizPageState {
  final int? selectedOption; // For multiChoice
  final List<String>? reorderedOptions; // For reorder
  final Map<int, int>? matches; // For match (leftIndex -> rightIndex)
  final int? selectedLeftIndex; // For match
  final bool isChecked;
  final bool isCorrect;
  final String? errorMessage;

  QuizPageState({
    this.selectedOption,
    this.reorderedOptions,
    this.matches,
    this.selectedLeftIndex,
    this.isChecked = false,
    this.isCorrect = false,
    this.errorMessage,
  });

  QuizPageState copyWith({
    int? selectedOption,
    List<String>? reorderedOptions,
    Map<int, int>? matches,
    int? selectedLeftIndex,
    bool? isChecked,
    bool? isCorrect,
    String? errorMessage,
  }) {
    return QuizPageState(
      selectedOption: selectedOption ?? this.selectedOption,
      reorderedOptions: reorderedOptions ?? this.reorderedOptions,
      matches: matches ?? this.matches,
      selectedLeftIndex: selectedLeftIndex ?? this.selectedLeftIndex,
      isChecked: isChecked ?? this.isChecked,
      isCorrect: isCorrect ?? this.isCorrect,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}