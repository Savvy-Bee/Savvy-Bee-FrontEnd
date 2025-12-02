import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/domain/enums/financial_archetype_enums.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/architype_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageTwo extends ConsumerWidget {
  const FinancialArchitypePageTwo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(financialPriorityProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: FinancialPriority.values.map((priority) {
        return ToggleableListTile(
          iconPath: priority.icon,
          text: priority.text,
          isSelected: selected == priority,
          onTap: () {
            ref.read(financialPriorityProvider.notifier).state = priority;
          },
        );
      }).toList(),
    );
  }
}