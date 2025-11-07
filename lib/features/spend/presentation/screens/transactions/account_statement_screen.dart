import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/statement_sent_screen.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_input_field.dart';
import '../../../../../core/widgets/outlined_card.dart';

class AccountStatementScreen extends ConsumerStatefulWidget {
  static String path = '/account-statement';

  const AccountStatementScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AccountStatementScreenState();
}

class _AccountStatementScreenState
    extends ConsumerState<AccountStatementScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedFileType = '';

  void _toggleFileType(String type) {
    setState(() {
      _selectedFileType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Statement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  CustomTextFormField(
                    label: 'Start Date',
                    hint: 'DD/MM/YYYY',
                    controller: _startDateController,
                    isRounded: true,
                    readOnly: true,
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            _startDateController.text =
                                '${value.day}/${value.month}/${value.year}';
                          });
                        }
                      });
                    },
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    label: 'End Date',
                    hint: 'DD/MM/YYYY',
                    controller: _endDateController,
                    isRounded: true,
                    readOnly: true,
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            _endDateController.text =
                                '${value.day}/${value.month}/${value.year}';
                          });
                        }
                      });
                    },
                  ),
                  const Gap(16),
                  Text(
                    'Format',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(4.0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFileTypeButton(
                          'PDF',
                          isSelected: _selectedFileType == 'PDF',
                          onTap: () => _toggleFileType('PDF'),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _buildFileTypeButton(
                          'Excel',
                          isSelected: _selectedFileType == 'Excel',
                          onTap: () => _toggleFileType('Excel'),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    label: 'Additional Email Address (Optional)',
                    hint: 'Additional Email Address',
                    controller: _emailController,
                    isRounded: true,
                    readOnly: false,
                  ),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Send',
              onPressed:
                  _selectedFileType.isNotEmpty &&
                      _startDateController.text.trim().isNotEmpty &&
                      _endDateController.text.trim().isNotEmpty
                  ? () => context.pushNamed(StatementSentScreen.path)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeButton(
    String text, {
    isSelected = false,
    VoidCallback? onTap,
  }) {
    return OutlinedCard(
      borderRadius: 50,
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : null,
      padding: EdgeInsets.all(12),
      child: Center(child: Text(text)),
    );
  }
}
