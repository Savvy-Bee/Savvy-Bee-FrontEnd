import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/domain/enums/financial_archetype_enums.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/architype_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageOne extends ConsumerWidget {
  const FinancialArchitypePageOne({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(userArchetypeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: UserArchetype.values.map((archetype) {
        return ToggleableListTile(
          iconPath: archetype.icon,
          text: archetype.text,
          isSelected: selected == archetype,
          onTap: () {
            ref.read(userArchetypeProvider.notifier).state = archetype;
          },
        );
      }).toList(),
    );
  }
}
