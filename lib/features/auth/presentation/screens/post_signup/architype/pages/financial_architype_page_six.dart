import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/domain/enums/financial_archetype_enums.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/architype_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageSix extends ConsumerWidget {
  const FinancialArchitypePageSix({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(financialMotivationProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: FinancialMotivation.values.map((motivation) {
        return ToggleableListTile(
          text: motivation.text,
          isSelected: selected == motivation,
          onTap: () {
            ref.read(financialMotivationProvider.notifier).state = motivation;
          },
        );
      }).toList(),
    );
  }
}
