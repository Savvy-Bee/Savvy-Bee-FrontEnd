import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

class FinancialArchitypePageOne extends ConsumerStatefulWidget {
  const FinancialArchitypePageOne({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypePageOneState();
}

class _FinancialArchitypePageOneState
    extends ConsumerState<FinancialArchitypePageOne> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ToggleableListTile(iconPath: AppIcons.goalIcon, text: 'The saver'),
        ToggleableListTile(iconPath: AppIcons.walletIcon, text: 'The spender'),
        ToggleableListTile(
          iconPath: AppIcons.sparklesIcon,
          text: 'The investor',
        ),
        ToggleableListTile(
          iconPath: AppIcons.pieChartIcon,
          text: 'The indifferent',
        ),
        ToggleableListTile(
          iconPath: AppIcons.lifeBuoyIcon,
          text: "I'm not sure",
        ),
      ],
    );
  }
}
