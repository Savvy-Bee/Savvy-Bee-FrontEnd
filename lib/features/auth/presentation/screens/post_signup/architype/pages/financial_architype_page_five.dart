import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/domain/enums/financial_archetype_enums.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/architype_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageFive extends ConsumerWidget {
  const FinancialArchitypePageFive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(financialChallengeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: FinancialChallenge.values.map((challenge) {
        return ToggleableListTile(
          text: challenge.text,
          isSelected: selected == challenge,
          onTap: () {
            ref.read(financialChallengeProvider.notifier).state = challenge;
          },
        );
      }).toList(),
    );
  }
}
