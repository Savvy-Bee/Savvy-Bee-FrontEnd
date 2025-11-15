import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/dot.dart';

import '../../../../../core/utils/constants.dart';

class BillBottomSheet extends ConsumerStatefulWidget {
  const BillBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BillBottomSheetState();

  static show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BillBottomSheet(),
    );
  }
}

class _BillBottomSheetState extends ConsumerState<BillBottomSheet> {
  late final TextEditingController _billNameController;
  late final TextEditingController _billAmountController;
  late final TextEditingController _billDueDateController;

  final _formKey = GlobalKey<FormState>();

  String? frequency;

  final Color _billColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
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
                      'Bill details',
                      style: TextStyle(
                        fontFamily: Constants.neulisNeueFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // if (hasSuggestedGoal)
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
              children: [
                CustomTextFormField(
                  controller: _billNameController,
                  labelType: LabelType.embedded,
                  label: 'Name',
                  hint: 'Name of bill',
                  suffix: Dot(size: 20, color: _billColor),
                ),
                const Gap(16),
                CustomTextFormField(
                  controller: _billAmountController,
                  labelType: LabelType.embedded,
                  label: 'Amount',
                  hint: 'Amount of bill',
                  suffix: Dot(size: 20),
                ),
                const Gap(16),
                CustomTextFormField(
                  controller: _billDueDateController,
                  labelType: LabelType.embedded,
                  label: 'Due date',
                  hint: 'Due date of bill',
                  readOnly: true,
                  suffix: Dot(size: 20),
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    ).then((value) {
                      if (value != null) {
                        _billDueDateController.text =
                            '${value.day}/${value.month}/${value.year}';
                      }
                    });
                  },
                ),
                const Gap(16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
