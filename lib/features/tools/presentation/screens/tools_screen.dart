import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  static const String path = '/tools';

  const ToolsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tools',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                Text(
                  'Your one stop shop for peak financial health',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Gap(8),
          OutlinedCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildToolItem(
                  'Budget',
                  'Create smart budgets, track spending, and get personalized insights.',
                ),
                const Gap(8),
                _buildToolItem(
                  'Goals',
                  'Set goals, get AI-powered suggestions, and track your progress.',
                ),
                const Gap(8),
                _buildToolItem(
                  'Debt tracker',
                  'Stay on top of your debts and plan your payoff with ease.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem(String title, String subtitle) {
    return OutlinedCard(
      child: Row(
        children: [
          SvgPicture.asset(Assets.honeyJarSvg),
          const Gap(16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                Text(subtitle, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
