import 'package:savvy_bee_mobile/core/utils/assets.dart';

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  static List<OnboardingItem> items = [
    const OnboardingItem(
      title: 'LEARN TO\nSPEND BETTER',
      description: 'With spending limits & budget tips',
      imagePath: Assets.savingsBeePose2,
    ),
    const OnboardingItem(
      title: 'SIMPLIFY\nYOUR SAVINGS',
      description: 'With automatic transfers to savings wallet',
      imagePath: Assets.savingsBeePose1,
    ),
    const OnboardingItem(
      title: 'YOUR\nAI COACH',
      description: 'Personal guide for tips, insights, and daily wins.',
      imagePath: Assets.loanBee,
    ),
    const OnboardingItem(
      title: 'JOIN\nTHE HIVE',
      description: 'Connect with other bees & climb the leaderboard.',
      imagePath: Assets.familyBee,
    ),
  ];
}
