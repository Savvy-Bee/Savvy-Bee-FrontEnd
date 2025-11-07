import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

class EditBudgetBottomSheet extends ConsumerStatefulWidget {
  const EditBudgetBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditBudgetBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const EditBudgetBottomSheet(),
    );
  }
}

class _EditBudgetBottomSheetState extends ConsumerState<EditBudgetBottomSheet> {
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
                'Budget by category',
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
        const Gap(24),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle),
                  const Gap(8),
                  Text(
                    'Auto & Transport',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                ],
              ),
              const Gap(24),
              InsightCard(
                iconPath: AppIcons.zapIcon,
                text:
                    "You've spent 15% more on transport this month. Try adjusting your allocation.",
                color: AppColors.bgBlue,
              ),
              const Gap(24),
              CustomTextFormField(
                label: 'Budget for November',
                hint: '\$800,000',
                isRounded: true,
              ),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textLight,
                    size: 16,
                  ),
                  const Gap(3),
                  Text(
                    '\$400,000 available',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const Gap(24),
              OutlinedCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Spent last month',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          NumberFormatter.formatCurrency(0),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Monthly average',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          NumberFormatter.formatCurrency(0),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Text('Chart goes here'),
              const Gap(24),
              CustomElevatedButton(
                text: 'Save',
                buttonColor: CustomButtonColor.black,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
