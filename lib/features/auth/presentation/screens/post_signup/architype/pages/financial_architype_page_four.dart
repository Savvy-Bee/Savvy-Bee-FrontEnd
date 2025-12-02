import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/domain/enums/financial_archetype_enums.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/architype_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageFour extends ConsumerWidget {
  const FinancialArchitypePageFour({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(confusingTopicProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: ConfusingTopic.values.map((topic) {
        return ToggleableListTile(
          text: topic.text,
          isSelected: selected == topic,
          onTap: () {
            ref.read(confusingTopicProvider.notifier).state = topic;
          },
        );
      }).toList(),
    );
  }
}
