import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/level/level_complete_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/drag_and_drop_option.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/match_options.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/multi_choice_options.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quiz_header.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quiz_success_error_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/reorder_options.dart';

class QuizScreen extends ConsumerStatefulWidget {
  static String path = '/quiz';

  final List<QuizQuestion> quizData;
  const QuizScreen({super.key, required this.quizData});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late final PageController _pageController;
  final TextEditingController _fillInGapTextController =
      TextEditingController();

  int _currentPage = 0;
  int _score = 0;

  final Map<int, QuizPageState> _pageStates = {};

  late final List<QuizQuestion> _quizData;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _quizData = widget.quizData;

    for (int i = 0; i < _quizData.length; i++) {
      final q = _quizData[i];
      List<String>? initialReorderOptions;

      if (q is ReorderQuestion) {
        initialReorderOptions = List.from(q.options);
      }

      _pageStates[i] = QuizPageState(
        reorderedOptions: initialReorderOptions,
        matches: q is MatchQuestion ? {} : null,
      );
    }

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() => _currentPage = newPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isMatchCorrect(int leftIndex, int rightIndex) {
    final question = _quizData[_currentPage];
    if (question is! MatchQuestion) return false;

    final leftOption = question.leftOptions[leftIndex];
    final correctRightIndex = question.correctMatches[leftOption];
    return correctRightIndex == rightIndex;
  }

  void _checkMatchPair(int leftIndex, int rightIndex) {
    final question = _quizData[_currentPage];
    if (question is! MatchQuestion) return;

    final state = _pageStates[_currentPage]!;

    setState(() {
      final newMatches = Map<int, int>.from(state.matches ?? {});

      // Remove any previous match where this right option was used
      newMatches.removeWhere((key, value) => value == rightIndex);

      // Remove any previous match for this left option
      newMatches.remove(leftIndex);

      // Add the new match
      newMatches[leftIndex] = rightIndex;

      _pageStates[_currentPage] = state.copyWith(
        matches: newMatches,
        selectedLeftIndex: null, // Deselect after matching
        errorMessage: null,
      );

      // Check if all matches are made
      if (newMatches.length == question.leftOptions.length) {
        // Check if all matches are correct
        final allCorrect = newMatches.entries.every((entry) {
          return _isMatchCorrect(entry.key, entry.value);
        });

        _pageStates[_currentPage] = _pageStates[_currentPage]!.copyWith(
          isChecked: true,
          isCorrect: allCorrect,
        );

        if (allCorrect) {
          _score += 20;
        }

        // Show result bottom sheet
        QuizSuccessErrorBottomSheet.show(
          context: context,
          isSuccess: allCorrect,
          onButtonPressed: _goToNextPage,
        );
      }
    });
  }

  bool _isAnswerCorrect(QuizQuestion question, QuizPageState state) {
    if (question is MultiChoiceQuestion) {
      return state.selectedOption == question.correctAnswer;
    } else if (question is ReorderQuestion) {
      return _listEquals(state.reorderedOptions!, question.correctAnswer);
    } else if (question is MatchQuestion) {
      if (state.matches == null ||
          state.matches!.length != question.correctMatches.length) {
        return false;
      }
      return state.matches!.entries.every((entry) {
        final leftOption = question.leftOptions[entry.key];
        final correctRightIndex = question.correctMatches[leftOption];
        return correctRightIndex == entry.value;
      });
    } else if (question is DragAndDropQuestion) {
      return _isDragAndDropCorrect(question, state);
    } else if (question is FillInTheGapQuestion) {
      return _isFillInTheGapCorrect(question, state);
    } else if (question is TrueFalseQuestion) {
      return state.selectedBool == question.correctAnswer;
    }
    return false;
  }

  bool _isFillInTheGapCorrect(
    FillInTheGapQuestion question,
    QuizPageState state,
  ) {
    final answer = state.filledGap!.trim().toLowerCase();

    final lowercasedCorrect = question.correctAnswer
        .map((s) => s.toLowerCase())
        .toSet();
    return lowercasedCorrect.contains(answer);
  }

  bool _isDragAndDropCorrect(
    DragAndDropQuestion question,
    QuizPageState state,
  ) {
    final droppedItems = state.droppedItems;
    if (droppedItems == null) return false;
    // 1. Check if all items have been dropped.
    int totalDroppedCount = 0;
    for (var list in droppedItems.values) {
      totalDroppedCount += list.length;
    }
    if (totalDroppedCount != question.items.length) {
      return false; // Not all items are placed.
    }
    // 2. Check if each item is in the correct group.
    for (var groupEntry in droppedItems.entries) {
      final String groupName = groupEntry.key;
      final List<int> itemIndices = groupEntry.value;

      // Get the list of correct item indices for this group from the question data.
      final correctIndicesForGroup = question.groups[groupName] ?? [];

      // Check if the dropped items match the correct items for this group.
      // We can convert to sets to ignore order.
      if (Set<int>.from(itemIndices).length !=
              Set<int>.from(correctIndicesForGroup).length ||
          !Set<int>.from(itemIndices).containsAll(correctIndicesForGroup)) {
        return false;
      }
    }
    return true;
  }

  bool _isTrueFalseCorrect(TrueFalseQuestion question, QuizPageState state) {
    return state.selectedBool == question.correctAnswer;
  }

  void _checkAnswer() {
    FocusScope.of(context).unfocus();

    final state = _pageStates[_currentPage]!;
    final question = _quizData[_currentPage];

    if (question.type == 'match') return;

    bool isCorrect;
    if (question is FillInTheGapQuestion) {
      isCorrect = _isFillInTheGapCorrect(question, state);
    } else if (question is TrueFalseQuestion) {
      isCorrect = _isTrueFalseCorrect(question, state);
    } else if (question is DragAndDropQuestion) {
      isCorrect = _isDragAndDropCorrect(question, state);
    } else {
      isCorrect = _isAnswerCorrect(question, state);
    }

    setState(() {
      _pageStates[_currentPage] = state.copyWith(
        isChecked: true,
        isCorrect: isCorrect,
        errorMessage: isCorrect ? null : 'Incorrect! Please try again.',
      );

      if (isCorrect) {
        _score += 20;
      }

      QuizSuccessErrorBottomSheet.show(
        context: context,
        isSuccess: isCorrect,
        onButtonPressed: () {
          // _goToNextPage();

          if (isCorrect) {
            _goToNextPage();
          } else {
            context.pop();
          }
        },
      );
    });
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _goToNextPage() {
    context.pop();

    if (_currentPage < _quizData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showResults();
    }
  }

  bool _canCheckAnswer(QuizPageState state) {
    final question = _quizData[_currentPage];

    if (state.isChecked) return false;

    if (question is MultiChoiceQuestion) {
      return state.selectedOption != null;
    } else if (question is ReorderQuestion) {
      return true;
    } else if (question is FillInTheGapQuestion) {
      return state.filledGap != null && state.filledGap!.isNotEmpty;
    } else if (question is TrueFalseQuestion) {
      return state.selectedBool != null;
    } else if (question is DragAndDropQuestion) {
      // Enable check only when all items have been dropped into a group.
      final totalDropped =
          state.droppedItems?.values.fold<int>(
            0,
            (prev, list) => prev + list.length,
          ) ??
          0;
      return totalDropped == question.items.length;
    } else if (question is MatchQuestion) {
      return false;
    }
    return false;
  }

  String _getInstructionText(String type) {
    switch (type) {
      case 'multiChoice':
        return 'SELECT ONE';
      case 'reorder':
        return 'REORDER';
      case 'match':
        return 'MATCH THE PAIRS';
      case 'dragAndDrop':
        return 'GROUP THE ITEMS';
      default:
        return 'ANSWER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _pageStates[_currentPage]!;
    final bool isCheckEnabled = _canCheckAnswer(state);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternYellow),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: QuizHeader(
                  pageController: _pageController,
                  quizCount: _quizData.length,
                  score: _score,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _quizData.length,
                  itemBuilder: (context, pageIndex) {
                    return _buildQuizPage(pageIndex);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomElevatedButton(
                  text: state.isChecked
                      ? (state.isCorrect ? 'Correct!' : 'Incorrect')
                      : 'Check Answer',
                  onPressed: isCheckEnabled ? _checkAnswer : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizPage(int pageIndex) {
    final question = _quizData[pageIndex];
    final state = _pageStates[pageIndex]!;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Gap(24),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${pageIndex + 1}/${_quizData.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ),
          ],
        ),
        const Gap(24),
        Text(
          _getInstructionText(question.type),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: Constants.neulisNeueFontFamily,
          ),
        ),
        const Gap(8),
        Text(
          question.question,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: Constants.neulisNeueFontFamily,
            height: 1.2,
          ),
        ),
        const Gap(24),
        _buildQuestionContent(question, state, pageIndex),
        const Gap(16),
      ],
    );
  }

  Widget _buildQuestionContent(
    QuizQuestion question,
    QuizPageState state,
    int pageIndex,
  ) {
    if (question is MultiChoiceQuestion) {
      return MultiChoiceOptions(
        question: question,
        state: state,
        onOptionSelected: (index) {
          setState(() {
            _pageStates[pageIndex] = state.copyWith(
              selectedOption: index,
              errorMessage: null,
              isChecked: false,
            );
          });
        },
      );
    } else if (question is ReorderQuestion) {
      return ReorderOptions(
        question: question,
        state: state,
        onReorder: (oldIndex, newIndex) {
          final options = List<String>.from(state.reorderedOptions!);
          if (newIndex > oldIndex) newIndex--;
          final item = options.removeAt(oldIndex);
          options.insert(newIndex, item);

          setState(() {
            _pageStates[pageIndex] = state.copyWith(
              reorderedOptions: options,
              errorMessage: null,
              isChecked: false,
            );
          });
        },
      );
    } else if (question is MatchQuestion) {
      return MatchOptions(
        question: question,
        state: state,
        onLeftSelected: (leftIndex) {
          setState(() {
            _pageStates[pageIndex] = state.copyWith(
              selectedLeftIndex: leftIndex,
              errorMessage: null,
            );
          });
        },
        onMatchPair: _checkMatchPair,
        isMatchCorrect: _isMatchCorrect,
      );
    } else if (question is FillInTheGapQuestion) {
      return CustomTextFormField(
        controller: _fillInGapTextController,
        onChanged: (value) {
          setState(() {
            _pageStates[pageIndex] = state.copyWith(
              filledGap: value.toLowerCase().trim(),
              errorMessage: null,
              isChecked: false,
            );
          });
        },
      );
    } else if (question is TrueFalseQuestion) {
      return TrueFalseOptions(
        question: question,
        selectedOption: state.selectedBool,
        onOptionSelected: (bool value) {
          setState(() {
            _pageStates[pageIndex] = state.copyWith(
              selectedBool: value,
              errorMessage: null,
              isChecked: false,
            );
          });
        },
        state: state,
      );
    } else if (question is DragAndDropQuestion) {
      return DragAndDropOptions(
        question: question,
        droppedItems: state.droppedItems ?? {},
        onItemDropped: (String group, int itemIndex) {
          // Create a deep copy of the current map
          final newDroppedItems = Map<String, List<int>>.from(
            (state.droppedItems ?? {}).map(
              (k, v) => MapEntry(k, List<int>.from(v)),
            ),
          );

          // 1. Remove item from any previous group it might be in
          for (var list in newDroppedItems.values) {
            list.remove(itemIndex);
          }

          // 2. Add item to the new group
          if (!newDroppedItems.containsKey(group)) {
            newDroppedItems[group] = [];
          }
          newDroppedItems[group]!.add(itemIndex);
          setState(() {
            _pageStates[pageIndex] = state.copyWith(
              droppedItems: newDroppedItems,
              errorMessage: null,
              isChecked: false,
            );
          });
        },

        isItemCorrect: (itemIndex) {
          if (!state.isChecked)
            return null; // Don't show correctness before check

          // Find which group the user dropped this item into.
          String? userGroup;
          for (var entry in state.droppedItems!.entries) {
            if (entry.value.contains(itemIndex)) {
              userGroup = entry.key;
              break;
            }
          }

          // Find the correct group for this item from the question data.
          for (var entry in question.groups.entries) {
            if (entry.value.contains(itemIndex)) {
              return entry.key ==
                  userGroup; // Compare user's group with correct group.
            }
          }
          return false; // Item was not found in any correct group definition.
        },
        state: state,
      );
    }
    return const SizedBox.shrink();
  }

  void _showResults() {
    context.pushReplacementNamed(
      LevelCompleteScreen.path,
      extra: LevelCompleteArgs(
        score: _score.toDouble(),
        newFlowers: _currentPage + 1,
      ),
    );
  }
}

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
