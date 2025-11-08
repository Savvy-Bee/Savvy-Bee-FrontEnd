import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../../core/widgets/custom_dropdown_button.dart';

enum GoalType { save, increase }

class CreateGoalScreen extends ConsumerStatefulWidget {
  static String path = '/create-goal';

  const CreateGoalScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  GoalType? _goalType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create a goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  CustomDropdownButton(
                    label: 'Goal type',
                    hint: 'Select goal type',
                    items: ['Save', 'Increase'],
                    onChanged: (value) {
                      setState(() {
                        _goalType = value == 'Save'
                            ? GoalType.save
                            : value == 'Increase'
                            ? GoalType.increase
                            : null;
                      });
                    },
                  ),
                  const Gap(8),
                  if (_goalType != null) ...[
                    InsightCard(
                      insightType: InsightType.nextBestAction,
                      text: switch (_goalType) {
                        GoalType.save =>
                          'Save ₦500,000 by March 2026 to build your emergency fund.',
                        GoalType.increase =>
                          'Increase earnings by 10% through by the end of the first quarter',
                        null => '',
                      },
                    ),
                    const Gap(16),
                    CustomTextFormField(
                      isRounded: true,
                      controller: _descriptionController,
                      hint: 'Build emergency fund',
                      label: 'Description',
                    ),
                    const Gap(16),
                    CustomTextFormField(
                      isRounded: true,
                      controller: _amountController,
                      hint: '\$500,000',
                      label: switch (_goalType) {
                        GoalType.save => 'Target amount',
                        GoalType.increase => 'Target percentage increase',
                        null => 'Target amount',
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        if (_goalType == GoalType.increase)
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^(100|[1-9]?[0-9])$'),
                          ),
                      ],
                    ),
                    const Gap(16),
                    CustomTextFormField(
                      isRounded: true,
                      controller: _dateController,
                      hint: '01/03/26',
                      label: 'Target date',
                      suffix: Icon(Icons.calendar_month),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                        );
                        if (date != null) {
                          setState(() {
                            _dateController.text =
                                '${date.month}/${date.day}/${date.year}';
                          });
                        }
                      },
                    ),
                  ],
                  const Gap(16),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Create goal',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
