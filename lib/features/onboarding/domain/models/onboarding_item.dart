import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';

import '../../../../core/utils/assets/assets.dart';

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
      title: 'Welcome to\nSavvy Bee',
      description:
          'With spending limits & budget tips from Nahl, hit your goals without the guilt.',
      imagePath: Assets.onboardBg01,
    ),
    const OnboardingItem(
      title: 'Spend Smarter,\nNot Harder',
      description:
          'With spending limits & budget tips from Nahl, hit your goals without the guilt.',
      imagePath: Assets.onboardBg02,
    ),
    const OnboardingItem(
      title: 'Your Savings,\non Autopilot',
      description:
          'Automate your transactions and savings then watch your wealth grow.',
      imagePath: Assets.onboardBg03,
    ),
    const OnboardingItem(
      title: 'Your 24/7 Money\nCoach',
      description:
          'Meet Nahl, your AI for pro tips, insights, and virtual high-fives for every win, powered by 7 animated bees.',
      imagePath: Assets.onboardBg04,
    ),
    const OnboardingItem(
      title: 'Your Money Squad\nAwaits',
      description:
          'Bees are already connecting! Compete for real rewards and climb the leaderboard with your hive.',
      imagePath: Assets.onboardBg05,
    ),
  ];
}
