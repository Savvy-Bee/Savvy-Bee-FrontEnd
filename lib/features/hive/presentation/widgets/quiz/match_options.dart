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
    return Column(
      children: List.generate(question.leftOptions.length, (index) {
        final leftIndex = index;
        final rightIndex = index;

        // Check if this left option has been matched
        final matchedRightIndex = state.matches?[leftIndex];
        final isLeftMatched = matchedRightIndex != null;

        // Check if this right option has been matched to any left option
        final leftIndexMatchedToThisRight = state.matches?.entries
            .firstWhere(
              (entry) => entry.value == rightIndex,
              orElse: () => const MapEntry(-1, -1),
            )
            .key;
        final isRightMatched =
            leftIndexMatchedToThisRight != null &&
            leftIndexMatchedToThisRight != -1;

        // Determine colors
        Color? leftColor;
        Color? rightColor;

        if (isLeftMatched) {
          // This left item is matched, check if it's correct
          final isCorrect = isMatchCorrect(leftIndex, matchedRightIndex);
          leftColor = isCorrect ? Colors.green : Colors.red;
        }

        if (isRightMatched) {
          // This right item is matched, check if it's correct
          final isCorrect = isMatchCorrect(
            leftIndexMatchedToThisRight,
            rightIndex,
          );
          rightColor = isCorrect ? Colors.green : Colors.red;
        }

        final isLeftSelected = state.selectedLeftIndex == leftIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Left Option
              Expanded(
                child: QuizeOptionTile(
                  quizType: 'match',
                  text: question.leftOptions[leftIndex],
                  onTap: isLeftMatched ? null : () => onLeftSelected(leftIndex),
                  isSelected: isLeftSelected || isLeftMatched,
                  textAlign: TextAlign.center,
                  color: leftColor ?? (isLeftSelected ? Colors.blue : null),
                ),
              ),
              const SizedBox(width: 8),
              // Right Option
              Expanded(
                child: QuizeOptionTile(
                  quizType: 'match',
                  text: question.rightOptions[rightIndex],
                  onTap: isRightMatched || state.selectedLeftIndex == null
                      ? null
                      : () => onMatchPair(state.selectedLeftIndex!, rightIndex),
                  isSelected: isRightMatched,
                  textAlign: TextAlign.center,
                  color: rightColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
