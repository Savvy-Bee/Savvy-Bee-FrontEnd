import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';

class CreateGoalBottomSheet extends ConsumerStatefulWidget {
  final GoalData? suggestedGoal;

  const CreateGoalBottomSheet({super.key, this.suggestedGoal});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGoalBottomSheetState();

  static show(BuildContext context, {GoalData? suggestedGoal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CreateGoalBottomSheet(suggestedGoal: suggestedGoal),
    );
  }
}

class _CreateGoalBottomSheetState extends ConsumerState<CreateGoalBottomSheet> {
  late final TextEditingController _goalNameController;
  late final TextEditingController _goalTargetController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with suggested goal data if available
    _goalNameController = TextEditingController(
      text: widget.suggestedGoal?.goalName ?? '',
    );
    _goalTargetController = TextEditingController(
      text: widget.suggestedGoal?.goalAmount.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _goalTargetController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement goal creation logic
      final goalName = _goalNameController.text.trim();
      final goalTarget = double.tryParse(
        _goalTargetController.text.replaceAll(',', ''),
      );

      if (goalTarget != null) {
        // Create the goal
        print('Creating goal: $goalName with target: $goalTarget');

        // Close the bottom sheet
        context.pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal "$goalName" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSuggestedGoal = widget.suggestedGoal != null;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSuggestedGoal
                          ? 'Create Suggested Goal'
                          : 'Create Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasSuggestedGoal)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI Suggested',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                  constraints: const BoxConstraints(),
                  style: Constants.collapsedButtonStyle,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormField(
                  controller: _goalNameController,
                  label: 'Goal Name',
                  borderRadius: 16,
                  labelType: LabelType.embedded,
                  autofocus: !hasSuggestedGoal,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a goal name';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                CustomTextFormField(
                  controller: _goalTargetController,
                  label: 'Target Amount',
                  borderRadius: 16,
                  labelType: LabelType.embedded,
                  keyboardType: TextInputType.number,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Text(
                      '₦',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a target amount';
                    }
                    final amount = double.tryParse(value.replaceAll(',', ''));
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                if (hasSuggestedGoal) ...[
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This goal was personalized based on your financial profile. Feel free to adjust the details!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Gap(24),
                CustomElevatedButton(
                  text: 'Save Goal',
                  buttonColor: CustomButtonColor.black,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
