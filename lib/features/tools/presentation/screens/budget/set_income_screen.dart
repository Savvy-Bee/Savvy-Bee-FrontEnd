import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

class SetIncomeScreen extends ConsumerStatefulWidget {
  static String path = '/set-income';

  const SetIncomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SetIncomeScreenState();
}

class _SetIncomeScreenState extends ConsumerState<SetIncomeScreen> {
  final _incomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set monthly income')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "Let's set your monthly income.",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    "Based on your accounts, Nahl estimated your take-home pay at ₦800,000.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Gap(28),
                  InsightCard(
                    insightType: InsightType.nextBestAction,
                    text:
                        'Based on your accounts, Nahl estimated your take-home pay at ₦800,000.',
                  ),
                  const Gap(28),
                  Text(
                    'Monthly income',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Gap(8),
                  CustomTextFormField(
                    hint: '\$800,000',
                    isRounded: true,
                    controller: _incomeController,
                  ),
                  const Gap(28),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Save',
              onPressed: () => context.pushNamed(SetBudgetScreen.path),
            ),
          ],
        ),
      ),
    );
  }
}
