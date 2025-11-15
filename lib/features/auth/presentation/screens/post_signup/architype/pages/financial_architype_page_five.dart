import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageFive extends ConsumerStatefulWidget {
  const FinancialArchitypePageFive({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypePageFiveState();
}

class _FinancialArchitypePageFiveState
    extends ConsumerState<FinancialArchitypePageFive> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ToggleableListTile(text: 'Impulse spending'),
        ToggleableListTile(text: 'Procrastination in saving'),
        ToggleableListTile(text: 'Fear or anxiety around money decisions'),
        ToggleableListTile(
          text: 'Overwhelmed by too much financial information',
        ),
        ToggleableListTile(
          text: "Difficulty staying consistent with financial goals",
        ),
        ToggleableListTile(text: "None of these"),
      ],
    );
  }
}
