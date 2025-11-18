import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_question.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quize_option_tile.dart';

class MultiChoiceOptions extends StatelessWidget {
  final QuizQuestion question;
  final QuizPageState state;
  final Function(int) onOptionSelected;

  const MultiChoiceOptions({
    super.key,
    required this.question,
    required this.state,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = state.selectedOption == index;

        // Determine border color based on check status
        Color? borderColor;
        if (state.isChecked && isSelected) {
          borderColor = state.isCorrect ? Colors.green : Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: QuizeOptionTile(
            quizType: QuizType.multiChoice,
            text: option,
            onTap: state.isChecked && state.isCorrect
                ? null // Disable after correct answer
                : () => onOptionSelected(index),
            isSelected: isSelected,
            color: borderColor,
          ),
        );
      }).toList(),
    );
  }
}
