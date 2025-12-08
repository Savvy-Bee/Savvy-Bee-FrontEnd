import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

import '../../utils/constants.dart';

class BudgetCategoryBottomSheet extends ConsumerStatefulWidget {
  const BudgetCategoryBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetCategoryBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const BudgetCategoryBottomSheet(),
    );
  }
}

class _BudgetCategoryBottomSheetState
    extends ConsumerState<BudgetCategoryBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add budget category',
                style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
                constraints: BoxConstraints(),
                style: Constants.collapsedButtonStyle,
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: CustomCard(
            padding: const EdgeInsets.all(16.0),
            borderColor: AppColors.grey.withValues(alpha: 0.3),
            child: Column(
              children: [
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
                const Gap(8),
                _buildCategoryListTile(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryListTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(),
            const Gap(16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto & transport',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                Text(
                  '${40000.formatCurrency(decimalDigits: 0)} last month',
                  style: TextStyle(
                    fontSize: 8.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (1 == 7)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    40000.formatCurrency(decimalDigits: 0),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    constraints: BoxConstraints(),
                    style: Constants.collapsedButtonStyle,
                  ),
                ],
              ),
            if (7 == 7)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
                iconSize: 20,
                constraints: BoxConstraints(),
                style: Constants.collapsedButtonStyle,
              ),
          ],
        ),
      ],
    );
  }
}
