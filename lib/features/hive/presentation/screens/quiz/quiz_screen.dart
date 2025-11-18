import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_page_state.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/quiz_question.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/match_options.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/multi_choice_options.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quiz_header.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/quiz_success_error_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/widgets/quiz/reorder_options.dart';

class QuizScreen extends ConsumerStatefulWidget {
  static String path = '/quiz';

  const QuizScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  int _score = 0;

  // Track state for each page
  final Map<int, QuizPageState> _pageStates = {};

  // Quiz data - mixed types
  late final List<QuizQuestion> _quizData;

  @override
  void initState() {
    super.initState();
    _initializeQuizData();

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  void _initializeQuizData() {
    // Get mixed quiz or structured quiz
    _quizData = QuizData.getStructuredQuiz(); // or getMixedQuiz()

    // Initialize page states based on each question's type
    for (int i = 0; i < _quizData.length; i++) {
      final question = _quizData[i];
      _pageStates[i] = QuizPageState(
        reorderedOptions: question.type == QuizType.reorder
            ? List.from(question.options)
            : null,
        matches: question.type == QuizType.match ? {} : null,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Check if a specific match is correct
  bool _isMatchCorrect(int leftIndex, int rightIndex) {
    final question = _quizData[_currentPage];
    final correctMatches = question.correctMatches!;
    return correctMatches[leftIndex] == rightIndex;
  }

  // Auto-check match and provide immediate feedback
  void _checkMatchPair(int leftIndex, int rightIndex) {
    final state = _pageStates[_currentPage]!;
    final question = _quizData[_currentPage];

    setState(() {
      final newMatches = Map<int, int>.from(state.matches!);

      // Remove any existing match for this right option
      newMatches.removeWhere((key, value) => value == rightIndex);

      // Add new match
      newMatches[leftIndex] = rightIndex;

      _pageStates[_currentPage] = state.copyWith(
        matches: newMatches,
        selectedLeftIndex: null,
        errorMessage: null,
      );

      // Check if all matches are complete and correct
      if (newMatches.length == question.leftOptions!.length) {
        final allCorrect = newMatches.entries.every(
          (entry) => _isMatchCorrect(entry.key, entry.value),
        );

        if (allCorrect) {
          _pageStates[_currentPage] = _pageStates[_currentPage]!.copyWith(
            isChecked: true,
            isCorrect: true,
          );
          _score += 20;

          // Show success for match type
          QuizSuccessErrorBottomSheet.show(
            context: context,
            isSuccess: true,
            onButtonPressed: _goToNextPage,
          );
        }
      }
    });
  }

  void _checkAnswer() {
    final state = _pageStates[_currentPage]!;
    final question = _quizData[_currentPage];
    bool isCorrect = false;

    switch (question.type) {
      case QuizType.multiChoice:
        isCorrect = state.selectedOption == question.correctAnswer;
        break;

      case QuizType.reorder:
        final correctOrder = question.correctAnswer as List<String>;
        isCorrect = _listEquals(state.reorderedOptions!, correctOrder);
        break;

      case QuizType.match:
        final correctMatches = question.correctMatches!;
        isCorrect = state.matches!.length == correctMatches.length &&
            state.matches!.entries.every(
              (entry) => correctMatches[entry.key] == entry.value,
            );
        break;
    }

    setState(() {
      _pageStates[_currentPage] = state.copyWith(
        isChecked: true,
        isCorrect: isCorrect,
        errorMessage: isCorrect ? null : 'Incorrect! Please try again.',
      );

      if (isCorrect) {
        _score += 20; // Award points for correct answer
      }

      // Show wrong/right message
      QuizSuccessErrorBottomSheet.show(
        context: context,
        isSuccess: isCorrect,
        onButtonPressed: () {
          if (isCorrect) {
            _goToNextPage();
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
    if (_currentPage < _quizData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Quiz completed - show results
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz Complete!'),
        content: Text('Your score: $_score/${_quizData.length * 20}'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  physics: NeverScrollableScrollPhysics(), // Prevent manual swiping
                  itemCount: _quizData.length,
                  itemBuilder: (context, pageIndex) {
                    return _buildQuizPage(pageIndex);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomElevatedButton(
                  text: 'Check',
                  onPressed: _canCheckAnswer(_pageStates[_currentPage]!)
                      ? _checkAnswer
                      : null,
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
        
        // Dynamically render based on question type
        _buildQuestionContent(question, state, pageIndex),
      ],
    );
  }

  Widget _buildQuestionContent(
    QuizQuestion question,
    QuizPageState state,
    int pageIndex,
  ) {
    switch (question.type) {
      case QuizType.multiChoice:
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

      case QuizType.reorder:
        return ReorderOptions(
          question: question,
          state: state,
          onReorder: (oldIndex, newIndex) {
            final options = state.reorderedOptions!;
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

      case QuizType.match:
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
    }
  }

  bool _canCheckAnswer(QuizPageState state) {
    final question = _quizData[_currentPage];
    
    switch (question.type) {
      case QuizType.multiChoice:
        return state.selectedOption != null && !state.isChecked;
      case QuizType.reorder:
        return !state.isChecked; // Can always check reorder
      case QuizType.match:
        return false; // Match type doesn't need check button (auto-checks)
    }
  }

  String _getInstructionText(QuizType type) {
    switch (type) {
      case QuizType.multiChoice:
        return 'SELECT ONE';
      case QuizType.reorder:
        return 'REORDER';
      case QuizType.match:
        return 'MATCH';
    }
  }
}

// QuizData class
class QuizData {
  // Mixed quiz containing all three types
  static List<QuizQuestion> getMixedQuiz() {
    final allQuestions = [
      ..._multiChoiceQuestions,
      ..._reorderQuestions,
      ..._matchQuestions,
    ];
    
    // Shuffle for variety
    allQuestions.shuffle();
    
    return allQuestions;
  }

  // Or get a structured quiz (alternating types for better UX)
  static List<QuizQuestion> getStructuredQuiz() {
    return [
      _multiChoiceQuestions[0],
      _matchQuestions[0],
      _reorderQuestions[0],
      _multiChoiceQuestions[1],
      _matchQuestions[1],
      _reorderQuestions[1],
      _multiChoiceQuestions[2],
    ];
  }

  static final List<QuizQuestion> _multiChoiceQuestions = [
    QuizQuestion(
      type: QuizType.multiChoice,
      question: 'What is a smart way to keep your savings safe?',
      options: [
        'Hiding cash under your bed',
        'Keeping it in a bank account',
        'Giving it to friends',
        'Spending it all immediately',
      ],
      correctAnswer: 1,
    ),
    QuizQuestion(
      type: QuizType.multiChoice,
      question: 'What should you do before making a big purchase?',
      options: [
        'Buy it immediately',
        'Check your budget',
        'Borrow money',
        'Ignore the price',
      ],
      correctAnswer: 1,
    ),
    QuizQuestion(
      type: QuizType.multiChoice,
      question: 'What is the best way to track your spending?',
      options: [
        'Don\'t track it',
        'Use a budgeting app',
        'Guess how much you spent',
        'Ask others to track for you',
      ],
      correctAnswer: 1,
    ),
  ];

  static final List<QuizQuestion> _reorderQuestions = [
    QuizQuestion(
      type: QuizType.reorder,
      question: 'Order these steps for creating a budget:',
      options: [
        'Track your spending',
        'Calculate your income',
        'Set financial goals',
        'Review and adjust',
      ]..shuffle(),
      correctAnswer: [
        'Calculate your income',
        'Set financial goals',
        'Track your spending',
        'Review and adjust',
      ],
    ),
    QuizQuestion(
      type: QuizType.reorder,
      question: 'Order these savings priorities:',
      options: [
        'Long-term investments',
        'Emergency fund',
        'Retirement savings',
        'Short-term goals',
      ]..shuffle(),
      correctAnswer: [
        'Emergency fund',
        'Short-term goals',
        'Retirement savings',
        'Long-term investments',
      ],
    ),
  ];

  static final List<QuizQuestion> _matchQuestions = [
    QuizQuestion(
      type: QuizType.match,
      question: 'Match the financial terms with their meanings:',
      leftOptions: ['Income', 'Expense', 'Budget', 'Savings'],
      rightOptions: [
        'Money going out',
        'Financial plan',
        'Money coming in',
        'Money set aside',
      ]..shuffle(),
      correctMatches: {
        0: 2, // Income -> Money coming in
        1: 0, // Expense -> Money going out
        2: 1, // Budget -> Financial plan
        3: 3, // Savings -> Money set aside
      },
    ),
    QuizQuestion(
      type: QuizType.match,
      question: 'Match the account types with their purposes:',
      leftOptions: [
        'Savings Account',
        'Checking Account',
        'Investment Account',
      ],
      rightOptions: ['Daily transactions', 'Long-term growth', 'Emergency fund']
        ..shuffle(),
      correctMatches: {
        0: 2, // Savings -> Emergency fund
        1: 0, // Checking -> Daily transactions
        2: 1, // Investment -> Long-term growth
      },
    ),
  ];
}