import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quize_option_tile.dart';

class MatchOptions extends StatelessWidget {
  final MatchQuestion question;
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
    // Determine the number of rows based on the longer list
    final rowCount = question.leftOptions.length > question.rightOptions.length
        ? question.leftOptions.length
        : question.rightOptions.length;

    return Column(
      children: List.generate(rowCount, (index) {
        // Check if we have items at this index
        final hasLeftOption = index < question.leftOptions.length;
        final hasRightOption = index < question.rightOptions.length;

        // Left side logic
        int? leftIndex = hasLeftOption ? index : null;
        final matchedRightIndex = leftIndex != null
            ? (state.matches?[leftIndex])
            : null;
        final isLeftMatched = matchedRightIndex != null;
        final isLeftSelected =
            leftIndex != null && state.selectedLeftIndex == leftIndex;

        Color? leftColor;
        if (isLeftMatched) {
          final isCorrect = isMatchCorrect(leftIndex!, matchedRightIndex);
          leftColor = isCorrect ? Colors.green : Colors.red;
        } else if (isLeftSelected) {
          leftColor = Colors.blue;
        }

        // Right side logic
        int? rightIndex = hasRightOption ? index : null;
        // Check if ANY left option is matched to this right option
        final leftIndicesMatchedToThisRight = <int>[];
        state.matches?.forEach((leftIdx, rightIdx) {
          if (rightIdx == rightIndex) {
            leftIndicesMatchedToThisRight.add(leftIdx);
          }
        });
        final isRightMatched = leftIndicesMatchedToThisRight.isNotEmpty;

        // For color, check if the LAST match to this right option is correct
        Color? rightColor;
        if (isRightMatched && rightIndex != null) {
          // Get the most recent left index matched to this right
          final lastLeftIndex = leftIndicesMatchedToThisRight.last;
          final isCorrect = isMatchCorrect(lastLeftIndex, rightIndex);
          rightColor = isCorrect ? Colors.green : Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Left Option
              Expanded(
                child: hasLeftOption
                    ? QuizeOptionTile(
                        quizType: 'match',
                        text: question.leftOptions[leftIndex!],
                        onTap: isLeftMatched
                            ? null
                            : () => onLeftSelected(leftIndex),
                        isSelected: isLeftSelected || isLeftMatched,
                        textAlign: TextAlign.center,
                        color: leftColor,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
              // Right Option
              Expanded(
                child: hasRightOption
                    ? QuizeOptionTile(
                        quizType: 'match',
                        text: question.rightOptions[rightIndex!],
                        onTap: state.selectedLeftIndex == null
                            ? null
                            : () => onMatchPair(
                                state.selectedLeftIndex!,
                                rightIndex,
                              ),
                        isSelected: isRightMatched,
                        textAlign: TextAlign.center,
                        color: rightColor,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
