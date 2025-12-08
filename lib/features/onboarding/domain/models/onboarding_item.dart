import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';

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
      title: 'Spend Smarter,\nNot Harder',
      description:
          'With spending limits & budget tips from Nahl, hit your goals without the guilt.',
      imagePath: Illustrations.luna,
    ),
    const OnboardingItem(
      title: 'Your Savings,\non Autopilot',
      description:
          'Automate your transactions and savings then watch your wealth grow.',
      imagePath: Illustrations.susu,
    ),
    const OnboardingItem(
      title: 'Your 24/7\nMoney Coach',
      description:
          'Meet Nahl, your AI for pro tips, insights, and virtual high-fives for every win, powered by 7 animated bees.',
      imagePath: Illustrations.dash,
    ),
    const OnboardingItem(
      title: 'Your Money\nSquad Awaits',
      description:
          'Bees are already connecting! Compete for real rewards and climb the leaderboard with your hive.',
      imagePath: Illustrations.familyBee,
    ),
  ];
}
