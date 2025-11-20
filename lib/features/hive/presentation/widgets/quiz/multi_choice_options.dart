import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quize_option_tile.dart';

class MultiChoiceOptions extends StatelessWidget {
  final MultiChoiceQuestion question;
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
    final optionsList = question.options;
    final bool disableSelection = state.isChecked;

    return Column(
      children: optionsList.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = state.selectedOption == index;

        Color? borderColor;
        if (state.isChecked && isSelected) {
          borderColor = state.isCorrect ? Colors.green : Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: QuizeOptionTile(
            quizType: question.type,
            text: option,
            onTap: () => onOptionSelected(index),
            isSelected: isSelected,
            color: borderColor,
          ),
        );
      }).toList(),
    );
  }
}
