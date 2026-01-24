import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/copy_text_icon_button.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

enum DebtRepaymentMethod { bankTransfer, card }

class DebtRepaymentDetailsScreen extends ConsumerStatefulWidget {
  static const String path = '/debt-repayment-details';

  // Pass the ID created in Step 1
  final String debtId;

  const DebtRepaymentDetailsScreen({super.key, required this.debtId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DebtRepaymentDetailsScreenState();
}

class _DebtRepaymentDetailsScreenState
    extends ConsumerState<DebtRepaymentDetailsScreen> {
  final _accNumberController = TextEditingController();
  DebtRepaymentMethod _repaymentMethod = DebtRepaymentMethod.bankTransfer;
  bool _hasAgreedToTerms = false;
  bool _isLoading = false;

  // Placeholder for bank selection
  String? _selectedBankCode;

  // TODO: You usually fetch this list from a BankProvider
  final List<Map<String, String>> _dummyBanks = [
    {'name': 'First Bank', 'code': '100033'},
    {'name': 'GTBank', 'code': '100033'},
    {'name': 'Zenith Bank', 'code': '100033'},
  ];

  Future<void> _submitStep2() async {
    if (_selectedBankCode == null &&
        _repaymentMethod == DebtRepaymentMethod.bankTransfer) {
      CustomSnackbar.show(context, 'Please select a bank');
      return;
    }
    if (_accNumberController.text.length < 10) {
      CustomSnackbar.show(context, 'Invalid Account Number');
      return;
    }
    if (!_hasAgreedToTerms) {
      CustomSnackbar.show(context, 'Please agree to the terms');
      return;
    }

    setState(() => _isLoading = true);

    final reqBody = DebtCreationStep2Request(
      debtId: widget.debtId,
      bankCode: _selectedBankCode ?? '000',
      accNumber: _accNumberController.text.trim(),
    );

    try {
      await ref
          .read(debtListNotifierProvider.notifier)
          .createDebtStep2(reqBody: reqBody);

      if (mounted) {
        // Success - Go back to debt home
        context.pop(); // Pop this screen
        context.pop(); // Pop add screen (Simple approach)
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debt repayment details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'How would you like to pay this debt?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: _buildPaymentOptionButton(
                          'Bank transfer',
                          isSelected:
                              _repaymentMethod ==
                              DebtRepaymentMethod.bankTransfer,
                          onTap: () {
                            setState(() {
                              _repaymentMethod =
                                  DebtRepaymentMethod.bankTransfer;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildPaymentOptionButton(
                          'Card',
                          isSelected:
                              _repaymentMethod == DebtRepaymentMethod.card,
                          onTap: () {
                            setState(() {
                              _repaymentMethod = DebtRepaymentMethod.card;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    label: 'Account Number',
                    isRounded: true,
                    controller: _accNumberController,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CopyTextIconButton(
                        label: 'Paste',
                        onPressed: () async {
                          final data = await Clipboard.getData(
                            Clipboard.kTextPlain,
                          );
                          if (data?.text != null) {
                            _accNumberController.text = data!.text!;
                          }
                        },
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const Gap(4),
                  // Account Name Resolution (Placeholder logic)
                  if (_accNumberController.text.length == 10)
                    IconTextRowWidget(
                      'Aegon Targaryen',
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      textStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,

                        color: AppColors.primary,
                      ),
                    ),
                  const Gap(16),
                  CustomDropdownButton(
                    items: _dummyBanks.map((e) => e['name']!).toList(),
                    hint: 'Bank name',
                    label: 'Bank',
                    leadingIcon: const Icon(Icons.account_balance_rounded),
                    onChanged: (val) {
                      final bank = _dummyBanks.firstWhere(
                        (element) => element['name'] == val,
                      );
                      setState(() {
                        _selectedBankCode = bank['code'];
                      });
                    },
                  ),
                  const Gap(16),
                  const InsightCard(
                    text:
                        'We will send you a reminder when each repayment is due',
                    insightType: InsightType.nextBestAction,
                  ),
                  const Gap(16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _hasAgreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _hasAgreedToTerms = !_hasAgreedToTerms;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Gap(12),
                      const Expanded(
                        child: Text.rich(
                          style: TextStyle(fontSize: 12),
                          TextSpan(
                            text:
                                'I hereby agree to Nahl automatically repaying this debt from my Savvy Wallet to ',
                            children: [
                              TextSpan(
                                text: 'Aegon Targaryen (First Bank) ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'on the '),
                              TextSpan(
                                text: 'first day of every month ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'until the debt has been fully repaid',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Add repayment details',
              isLoading: _isLoading,
              onPressed: _hasAgreedToTerms ? _submitStep2 : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionButton(
    String text, {
    isSelected = false,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      borderWidth: isSelected ? 2 : null,
      borderRadius: 8,
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : null,
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
