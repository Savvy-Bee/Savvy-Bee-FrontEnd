import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageSix extends ConsumerStatefulWidget {
  const FinancialArchitypePageSix({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypePageSixState();
}

class _FinancialArchitypePageSixState
    extends ConsumerState<FinancialArchitypePageSix> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ToggleableListTile(text: 'Achieving financial independence'),
        ToggleableListTile(
          text: 'Building wealth for family/future generations',
        ),
        ToggleableListTile(text: 'Gaining confidence in financial decisions'),
        ToggleableListTile(text: 'Reducing financial stress and anxiety'),
        ToggleableListTile(text: "None of these"),
        ToggleableListTile(text: "None of these"),
      ],
    );
  }
}
