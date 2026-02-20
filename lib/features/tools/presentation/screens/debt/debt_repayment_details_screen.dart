import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
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
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/provider/bank.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

enum DebtRepaymentMethod { bankTransfer, card }

class DebtRepaymentDetailsScreen extends ConsumerStatefulWidget {
  static const String path = '/debt-repayment-details';
  final String debtId;

  const DebtRepaymentDetailsScreen({super.key, required this.debtId});

  @override
  ConsumerState<DebtRepaymentDetailsScreen> createState() =>
      _DebtRepaymentDetailsScreenState();
}

class _DebtRepaymentDetailsScreenState
    extends ConsumerState<DebtRepaymentDetailsScreen> {
  final _accNumberController = TextEditingController();

  String? _selectedBankCode;
  String? _selectedBankName;
  String? _resolvedAccountName;
  bool _hasAgreedToTerms = false;
  bool _isLoading = false;
  bool _isResolvingAccount = false;
  String? _accountResolveError;

  @override
  void initState() {
    super.initState();
    MixpanelService.trackFirstFeatureUsed('Tools-Debt');
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(bankListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debt repayment details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  banksAsync.when(
                    data: (banks) => CustomDropdownButton(
                      items: banks.map((e) => e['name']!).toList(),
                      hint: 'Bank name',
                      label: 'Bank',
                      leadingIcon: const Icon(Icons.account_balance_rounded),
                      onChanged: (val) {
                        final bank = banks.firstWhere((e) => e['name'] == val);
                        setState(() {
                          _selectedBankCode = bank['code'];
                          _selectedBankName = bank['name'];
                          _resolvedAccountName = null;
                          _isResolvingAccount = false;
                          _accountResolveError = null;
                        });
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Failed to load banks'),
                  ),

                  const Gap(16),
                  CustomTextFormField(
                    label: 'Account Number',
                    isRounded: true,
                    controller: _accNumberController,
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (val) async {
                      if (val.length == 10 && _selectedBankCode != null) {
                        setState(() {
                          _isResolvingAccount = true;
                          _resolvedAccountName = null;
                          _accountResolveError = null;
                        });

                        try {
                          final name = await ref.read(
                            accountResolutionProvider((
                              bankCode: _selectedBankCode!,
                              accNumber: val,
                            )).future,
                          );

                          setState(() {
                            _resolvedAccountName = name;
                            _isResolvingAccount = false;
                          });
                        } catch (e) {
                          setState(() {
                            _isResolvingAccount = false;
                            _accountResolveError = 'Failed to resolve account';
                          });
                        }
                      }
                    },
                  ),
                  const Gap(8),

                  // if (_resolvedAccountName != null)
                  //   IconTextRowWidget(
                  //     _resolvedAccountName!,
                  //     const Icon(
                  //       Icons.check_circle,
                  //       color: AppColors.primary,
                  //       size: 16,
                  //     ),
                  //     textStyle: const TextStyle(
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.bold,
                  //       color: AppColors.primary,
                  //     ),
                  //   ),
                  if (_isResolvingAccount)
                    const Row(
                      children: [
                        SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        Gap(6),
                        Text(
                          'Resolving account...',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),

                  if (_resolvedAccountName != null)
                    IconTextRowWidget(
                      _resolvedAccountName!,
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                  if (_accountResolveError != null)
                    Text(
                      _accountResolveError!,
                      style: const TextStyle(fontSize: 10, color: Colors.red),
                    ),
 
                  const Gap(16),
                  const InsightCard(
                    text:
                        'We will send you a reminder when each repayment is due',
                    insightType: InsightType.nextBestAction,
                  ),
                  const Gap(16),

                  Row(
                    children: [
                      Checkbox(
                        value: _hasAgreedToTerms,
                        onChanged: (v) =>
                            setState(() => _hasAgreedToTerms = v!),
                      ),
                      const Expanded(
                        child: Text(
                          'I hereby agree to Nahl automatically repaying this debt from my Savvy Wallet until the debt has been fully repaid',
                          style: TextStyle(fontSize: 12),
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

  Future<void> _submitStep2() async {
    if (_selectedBankCode == null) {
      CustomSnackbar.show(context, 'Please select a bank');
      return;
    }

    if (_accNumberController.text.length != 10) {
      CustomSnackbar.show(context, 'Invalid account number');
      return;
    }

    if (_resolvedAccountName == null) {
      CustomSnackbar.show(context, 'Account not resolved');
      return;
    }

    setState(() => _isLoading = true);

    final reqBody = DebtCreationStep2Request(
      debtId: widget.debtId,
      bankCode: _selectedBankCode!,
      accNumber: _accNumberController.text.trim(),
    );

    try {
      await ref
          .read(debtListNotifierProvider.notifier)
          .createDebtStep2(reqBody: reqBody);

      if (mounted) {
        context.pop();
        context.pop();
      }
    } catch (_) {
      CustomSnackbar.show(context, 'Something went wrong');
    } finally {
      setState(() => _isLoading = false);
    }
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
