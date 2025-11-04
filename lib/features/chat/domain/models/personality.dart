import '../../../../core/utils/assets/illustrations.dart';

class Personality {
  final String id;
  final String name;
  final String description;
  final String characteristics;
  final List<String> tone;
  final String dashboardBias;
  final String? image;

  const Personality({
    required this.id,
    required this.name,
    required this.description,
    required this.characteristics,
    required this.tone,
    required this.dashboardBias,
    this.image,
  });

  factory Personality.fromJson(Map<String, dynamic> json) {
    return Personality(
      id: json['ID'] as String,
      name: json['Name'] as String,
      description: json['Description'] as String,
      characteristics: json['Characteristics'] as String,
      tone: List<String>.from(json['Tone'] as List),
      dashboardBias: json['Dashboard_Bias'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'Description': description,
      'Characteristics': characteristics,
      'Tone': tone,
      'Dashboard_Bias': dashboardBias,
    };
  }
}

/// Predefined personalities
class Personalities {
  static const List<Personality> all = [
    Personality(
      id: 'Nurturing_Guide',
      name: 'Dash',
      description:
          'Your motivational buddy, helping you achieve your goals, one financial push up at a time.',
      characteristics: 'Reduce anxiety; reward micro-wins',
      tone: ['calm', 'gentle', 'supportive'],
      dashboardBias: 'soft progress waves',
      image: Illustrations.dashAvatar,
    ),
    Personality(
      id: 'Analytical_Expert',
      name: 'Susu',
      description:
          'Your money-making sidekick, helping you manage and maximize your income.',
      characteristics: 'Explain patterns precisely',
      tone: ['clear', 'numeric', 'transparent'],
      dashboardBias: 'line charts, tables',
      image: Illustrations.budgetBeeAvatar,
    ),
    Personality(
      id: 'Motivational_Coach',
      name: 'Buck',
      description:
          'Your investment guide, helping you grow your wealth strategically.',
      characteristics: 'Push streaks, challenges',
      tone: ['energetic', 'assertive'],
      dashboardBias: 'trophies, streak meters',
      image: Illustrations.interestBeeAvatar,
    ),
    Personality(
      id: 'Practical_Advisor',
      name: 'Cashie',
      description:
          'Your spending tracker, keeping you mindful of every transaction.',
      characteristics: 'Simplify, offer steps',
      tone: ['direct', 'structured'],
      dashboardBias: 'task cards, checklists',
      image: Illustrations.savingsBeeAvatar,
    ),
    Personality(
      id: 'Frugal_Minimalist',
      name: 'Savvy',
      description:
          'Your all-around money expert, balancing savings, spending, and investing.',
      characteristics: 'Remove waste, optimize',
      tone: ['witty', 'lean'],
      dashboardBias: 'efficiency meters',
      image: Illustrations.susuAvatar,
    ),
    Personality(
      id: 'Faith_Centered_Steward',
      name: 'Savvy',
      description:
          'Your all-around money expert, balancing savings, spending, and investing.',
      characteristics: 'Link purpose/values',
      tone: ['reflective', 'humble'],
      dashboardBias: 'gratitude cards',
      image: Illustrations.quizBeeAvatar,
    ),
    Personality(
      id: 'Entrepreneur_Operator',
      name: 'Savvy',
      description:
          'Your all-around money expert, balancing savings, spending, and investing.',
      characteristics: 'ROI, runway, cashflow',
      tone: ['strategic', 'confident'],
      dashboardBias: 'ROI boards, runway days',
      image: Illustrations.scammerBeeAvatar,
    ),
  ];

  /// Get personality by ID
  static Personality? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
// class Personalities {
//   static const List<Personality> all = [
//     Personality(
//       id: 'Nurturing_Guide',
//       name: 'Nurturing Guide',
//       description:
//           'A nurturing guide persona that provides empathetic and supportive responses, focusing on care and encouragement.',
//       characteristics: 'Reduce anxiety; reward micro-wins',
//       tone: ['calm', 'gentle', 'supportive'],
//       dashboardBias: 'soft progress waves',
//       image: Assets.dashAvatar,
//     ),
//     Personality(
//       id: 'Analytical_Expert',
//       name: 'Analytical Expert',
//       description:
//           'An analytical expert persona that offers detailed, data-driven insights and logical reasoning to help users make informed decisions.',
//       characteristics: 'Explain patterns precisely',
//       tone: ['clear', 'numeric', 'transparent'],
//       dashboardBias: 'line charts, tables',
//       image: Assets.budgetBeeAvatar,
//     ),
//     Personality(
//       id: 'Motivational_Coach',
//       name: 'Motivational Coach',
//       description:
//           'A motivational coach persona that inspires and encourages users to achieve their goals through positive reinforcement and actionable advice.',
//       characteristics: 'Push streaks, challenges',
//       tone: ['energetic', 'assertive'],
//       dashboardBias: 'trophies, streak meters',
//       image: Assets.interestBeeAvatar,
//     ),
//     Personality(
//       id: 'Practical_Advisor',
//       name: 'Practical Advisor',
//       description:
//           'A practical advisor persona that focuses on simplifying complex tasks and offering clear, actionable steps to achieve results.',
//       characteristics: 'Simplify, offer steps',
//       tone: ['direct', 'structured'],
//       dashboardBias: 'task cards, checklists',
//       image: Assets.savingsBeeAvatar,
//     ),
//     Personality(
//       id: 'Frugal_Minimalist',
//       name: 'Frugal Minimalist',
//       description:
//           'A frugal minimalist persona that promotes efficiency by reducing waste and optimizing resources for maximum effectiveness.',
//       characteristics: 'Remove waste, optimize',
//       tone: ['witty', 'lean'],
//       dashboardBias: 'efficiency meters',
//       image: Assets.susuAvatar,
//     ),
//     Personality(
//       id: 'Faith_Centered_Steward',
//       name: 'Faith-Centered Steward',
//       description:
//           'A faith-centered steward persona that connects purpose and values, encouraging reflection and gratitude in decision-making.',
//       characteristics: 'Link purpose/values',
//       tone: ['reflective', 'humble'],
//       dashboardBias: 'gratitude cards',
//       image: Assets.quizBeeAvatar,
//     ),
//     Personality(
//       id: 'Entrepreneur_Operator',
//       name: 'Entrepreneur Operator',
//       description:
//           'An entrepreneur operator persona that focuses on business growth, emphasizing ROI, runway, and cashflow for strategic decision-making.',
//       characteristics: 'ROI, runway, cashflow',
//       tone: ['strategic', 'confident'],
//       dashboardBias: 'ROI boards, runway days',
//       image: Assets.scammerBeeAvatar,
//     ),
//   ];

//   /// Get personality by ID
//   static Personality? getById(String id) {
//     try {
//       return all.firstWhere((p) => p.id == id);
//     } catch (e) {
//       return null;
//     }
//   }
// }

/// AI Strictness levels
enum AIStrictness {
  strict('Strict'),
  moderate('Moderate'),
  lenient('Lenient');

  final String value;
  const AIStrictness(this.value);
}
