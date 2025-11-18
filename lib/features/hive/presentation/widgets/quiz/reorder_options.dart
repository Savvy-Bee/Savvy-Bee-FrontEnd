import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_question.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quize_option_tile.dart';

class ReorderOptions extends StatelessWidget {
  final QuizQuestion question;
  final QuizPageState state;
  final Function(int oldIndex, int newIndex) onReorder;

  const ReorderOptions({
    super.key,
    required this.question,
    required this.state,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final options = state.reorderedOptions!;
    final correctOrder = question.correctAnswer as List<String>;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: options.length,
      onReorder: state.isChecked && state.isCorrect
          ? (_, __) {} // Disable after correct answer
          : onReorder,
      itemBuilder: (context, index) {
        // Determine border color based on check status
        Color? borderColor;
        if (state.isChecked) {
          final isCorrectPosition = options[index] == correctOrder[index];
          borderColor = isCorrectPosition ? Colors.green : Colors.red;
        }

        return Padding(
          key: ValueKey(options[index]),
          padding: const EdgeInsets.only(bottom: 8),
          child: ReorderableDragStartListener(
            index: index,
            enabled: !(state.isChecked && state.isCorrect),
            child: QuizeOptionTile(
              quizType: QuizType.reorder,
              text: options[index],
              isSelected: false,
              color: borderColor,
            ),
          ),
        );
      },
    );
  }
}
