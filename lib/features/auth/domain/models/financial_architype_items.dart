class FinancialArchitypeItems {
  final String title;
  final String description;

  const FinancialArchitypeItems({
    required this.title,
    required this.description,
  }) : assert(
         description != null || description != null,
         'Either description or staticDescription must be provided',
       );

  static List<FinancialArchitypeItems> items = [
    const FinancialArchitypeItems(
      title: 'What personal finance\narchetype(s) best align\nwith you?',
      description:
          'Purpose: Tailor content and features (e.g., saving tips for savers, investing modules for investors).',
    ),
    const FinancialArchitypeItems(
      title: "What are your top financial\npriorities?",
      description:
          "Purpose: Helps in suggesting modules, challenges, and expert advice.",
    ),
    const FinancialArchitypeItems(
      title: 'How do you currently\nmanage your\nfinances?',
      description:
          "Purpose: Provides insight into current behaviours\nto recommend habit-forming strategies",
    ),
    const FinancialArchitypeItems(
      title: 'Which topics do you find\nconfusing or\nneed more help with?',
      description:
          'Purpose: Allows personalized content curation and\npriority suggestions.',
    ),
    const FinancialArchitypeItems(
      title:
          'Which habits or challenges\nresonate most with you?\n(Select all that apply)',
      description:
          'Purpose: Identifies psychological barriers to improve engagement with habit-building features.',
    ),
    const FinancialArchitypeItems(
      title: 'What motivates you to\nlearn about and improve\nyour finances?',
      description:
          'Purpose: Helps in crafting motivational nudges and gamification incentives.',
    ),
  ];
}
