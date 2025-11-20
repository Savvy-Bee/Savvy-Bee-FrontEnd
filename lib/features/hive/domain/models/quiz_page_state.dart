class QuizPageState {
  // --- Common State ---
  final bool isChecked;
  final bool isCorrect;
  final String? errorMessage;

  // --- 1. Multi-Choice State ---
  final int? selectedOption;

  // --- 2. True/False State ---
  final bool? selectedBool;

  // --- 3. Fill in the Gap State ---
  // Stores the text entered by the user
  final String? filledGap;

  // --- 4. Reorder State ---
  // Stores the options in their current (potentially dragged) order
  final List<String>? reorderedOptions;

  // --- 5. Match State ---
  // Map of Left Index -> Right Index
  final Map<int, int>? matches;
  // Tracks which left item is currently selected/active for matching
  final int? selectedLeftIndex;

  // --- 6. Drag and Drop State ---
  // Map of Group Name -> List of Item Indices currently inside that group
  final Map<String, List<int>>? droppedItems;

  QuizPageState({
    this.isChecked = false,
    this.isCorrect = false,
    this.errorMessage,
    this.selectedOption,
    this.selectedBool,
    this.filledGap,
    this.reorderedOptions,
    this.matches,
    this.selectedLeftIndex,
    this.droppedItems,
  });

  QuizPageState copyWith({
    bool? isChecked,
    bool? isCorrect,
    String? errorMessage,
    int? selectedOption,
    bool? selectedBool,
    String? filledGap,
    List<String>? reorderedOptions,
    Map<int, int>? matches,
    int? selectedLeftIndex,
    Map<String, List<int>>? droppedItems,
  }) {
    return QuizPageState(
      isChecked: isChecked ?? this.isChecked,
      isCorrect: isCorrect ?? this.isCorrect,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedBool: selectedBool ?? this.selectedBool,
      filledGap: filledGap ?? this.filledGap,
      reorderedOptions: reorderedOptions ?? this.reorderedOptions,
      matches: matches ?? this.matches,
      selectedLeftIndex: selectedLeftIndex ?? this.selectedLeftIndex,
      droppedItems: droppedItems ?? this.droppedItems,
    );
  }

  // Optional: Helper to determine if the state is empty/untouched
  bool get isUntouched {
    return selectedOption == null &&
        selectedBool == null &&
        (filledGap == null || filledGap!.isEmpty) &&
        (matches == null || matches!.isEmpty) &&
        (droppedItems == null || droppedItems!.values.every((l) => l.isEmpty));
    // Note: reorderedOptions is usually pre-filled, so it's rarely "null"
  }
}
