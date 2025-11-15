import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageThree extends ConsumerStatefulWidget {
  const FinancialArchitypePageThree({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypePageThreeState();
}

class _FinancialArchitypePageThreeState
    extends ConsumerState<FinancialArchitypePageThree> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ToggleableListTile(text: 'I budget and track expenses consistently.'),
        ToggleableListTile(text: "I save when I can but don't have a system."),
        ToggleableListTile(text: 'I live paycheck to paycheck.'),
        ToggleableListTile(
          text: 'I use tools to automate savings and investments.',
        ),
        ToggleableListTile(text: "Other"),
      ],
    );
  }
}
