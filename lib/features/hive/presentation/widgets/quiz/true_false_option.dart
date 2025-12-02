import 'package:flutter/material.dart';

import '../../../../auth/presentation/widgets/toggleable_list_tile.dart';
import '../../../domain/models/course.dart';
import '../../../domain/models/quiz_page_state.dart';

class TrueFalseOptions extends StatelessWidget {
  final TrueFalseQuestion question;
  final bool? selectedOption;
  final ValueChanged<bool> onOptionSelected;
  // Pass the whole state if you want to show correct/incorrect styling
  final QuizPageState state;

  const TrueFalseOptions({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToggleableListTile(
          text: "True",
          isSelected: selectedOption == true,
          onTap: () => onOptionSelected(true),
        ),
        const SizedBox(height: 12),
        ToggleableListTile(
          text: "False",
          isSelected: selectedOption == false,
          onTap: () => onOptionSelected(false),
        ),
      ],
    );
  }
}
