import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/auth/domain/enums/financial_archetype_enums.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/architype_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageFour extends ConsumerWidget {
  const FinancialArchitypePageFour({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(confusingTopicsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: ConfusingTopic.values.map((topic) {
        final isSelected = selected.contains(topic);
        return ToggleableListTile(
          text: topic.text,
          isSelected: isSelected,
          leading: _CheckboxIndicator(isSelected: isSelected),
          onTap: () {
            final current = ref.read(confusingTopicsProvider);
            ref.read(confusingTopicsProvider.notifier).state = isSelected
                ? current.where((e) => e != topic).toList()
                : [...current, topic];
          },
        );
      }).toList(),
    );
  }
}

class _CheckboxIndicator extends StatelessWidget {
  final bool isSelected;
  const _CheckboxIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFBBBBBB),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}
