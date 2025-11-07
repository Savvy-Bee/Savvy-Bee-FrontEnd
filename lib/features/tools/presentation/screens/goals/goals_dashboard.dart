import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

class GoalsDashboard extends ConsumerStatefulWidget {
  static String path = '/goals-dashboard';

  const GoalsDashboard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalsDashboardState();
}

class _GoalsDashboardState extends ConsumerState<GoalsDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Goals')),
      body: Column(
        children: [
          Expanded(
            child: OutlinedCard(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Define what financial success means to you.'),
                    const Gap(24),
                    CustomElevatedButton(
                      text: 'Create a goal',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
