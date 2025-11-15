import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageTwo extends ConsumerStatefulWidget {
  const FinancialArchitypePageTwo({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypePageTwoState();
}

class _FinancialArchitypePageTwoState
    extends ConsumerState<FinancialArchitypePageTwo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ToggleableListTile(iconPath: AppIcons.goalIcon, text: 'Build an emergency fund'),
        ToggleableListTile(iconPath: AppIcons.walletIcon, text: 'Saving for a major purchase'),
        ToggleableListTile(
          iconPath: AppIcons.sparklesIcon,
          text: 'Paying off debt',
        ),
        ToggleableListTile(
          iconPath: AppIcons.pieChartIcon,
          text: 'Investing for the future',
        ),
        ToggleableListTile(
          iconPath: AppIcons.lifeBuoyIcon,
          text: "Retirement Planning",
        ),
        ToggleableListTile(
          iconPath: AppIcons.lifeBuoyIcon,
          text: "Other",
        ),
      ],
    );
  }
}
