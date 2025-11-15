import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageFour extends ConsumerStatefulWidget {
  const FinancialArchitypePageFour({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypePageFourState();
}

class _FinancialArchitypePageFourState
    extends ConsumerState<FinancialArchitypePageFour> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ToggleableListTile(text: 'Budgeting and Savings'),
        ToggleableListTile(text: "Debt Management"),
        ToggleableListTile(text: 'Investing'),
        ToggleableListTile(text: 'Early-Stage Investments'),
        ToggleableListTile(text: "Homeownership"),
        ToggleableListTile(text: "Other"),
      ],
    );
  }
}
