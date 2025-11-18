import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_question.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quize_option_tile.dart';

class MatchOptions extends StatelessWidget {
  final QuizQuestion question;
  final QuizPageState state;
  final Function(int leftIndex) onLeftSelected;
  final Function(int leftIndex, int rightIndex) onMatchPair;
  final bool Function(int leftIndex, int rightIndex) isMatchCorrect;

  const MatchOptions({
    super.key,
    required this.question,
    required this.state,
    required this.onLeftSelected,
    required this.onMatchPair,
    required this.isMatchCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final leftOptions = question.leftOptions!;
    final rightOptions = question.rightOptions!;

    return Column(
      children: List.generate(leftOptions.length, (leftIndex) {
        final matchedRightIndex = state.matches![leftIndex];

        // Determine border colors for immediate feedback
        Color? leftBorderColor;
        Color? rightBorderColor;

        if (matchedRightIndex != null) {
          final isCorrect = isMatchCorrect(leftIndex, matchedRightIndex);
          leftBorderColor = isCorrect ? Colors.green : Colors.red;
          rightBorderColor = isCorrect ? Colors.green : Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            spacing: 8,
            children: [
              // Left option
              Expanded(
                child: QuizeOptionTile(
                  quizType: QuizType.match,
                  text: leftOptions[leftIndex],
                  onTap: state.isChecked && state.isCorrect
                      ? null
                      : () => onLeftSelected(leftIndex),
                  isSelected:
                      state.selectedLeftIndex == leftIndex ||
                      matchedRightIndex != null,
                  textAlign: TextAlign.center,
                  color: leftBorderColor,
                ),
              ),

              // Right option
              Expanded(
                child: QuizeOptionTile(
                  quizType: QuizType.match,
                  text: rightOptions[leftIndex],
                  onTap: state.isChecked && state.isCorrect
                      ? null
                      : () {
                          if (state.selectedLeftIndex != null) {
                            onMatchPair(state.selectedLeftIndex!, leftIndex);
                          }
                        },
                  isSelected:
                      matchedRightIndex != null &&
                      state.matches!.entries.any(
                        (e) => e.key != leftIndex && e.value == leftIndex,
                      ),
                  textAlign: TextAlign.center,
                  color: rightBorderColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
