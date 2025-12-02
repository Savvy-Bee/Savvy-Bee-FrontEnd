import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/domain/enums/financial_archetype_enums.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/architype_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageThree extends ConsumerWidget {
  const FinancialArchitypePageThree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(financeManagementProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: FinanceManagement.values.map((management) {
        return ToggleableListTile(
          text: management.text,
          isSelected: selected == management,
          onTap: () {
            ref.read(financeManagementProvider.notifier).state = management;
          },
        );
      }).toList(),
    );
  }
}
