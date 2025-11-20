import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quize_option_tile.dart';

class ReorderOptions extends StatelessWidget {
  final ReorderQuestion question;
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
    final options = state.reorderedOptions ?? question.options;
    final correctOrder = question.correctAnswer;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: options.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        Color? borderColor;
        if (state.isChecked) {
          final isCorrectPosition = options[index] == correctOrder[index];
          borderColor = isCorrectPosition ? AppColors.success : AppColors.error;
        }

        return Padding(
          key: ValueKey(options[index]),
          padding: const EdgeInsets.only(bottom: 8),
          child: ReorderableDragStartListener(
            index: index,
            child: QuizeOptionTile(
              quizType: question.type,
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
