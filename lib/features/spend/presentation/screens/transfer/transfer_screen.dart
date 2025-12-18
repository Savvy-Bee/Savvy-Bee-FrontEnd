import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/clipboard_utils.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_dropdown_button.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../domain/models/bank.dart';
import '../../providers/transfer_provider.dart';
import 'send_money_screen.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_input_field.dart';
import '../../widgets/copy_text_icon_button.dart';
import '../../widgets/mini_button.dart';

class TransferScreen extends ConsumerStatefulWidget {
  static String path = '/transfer';

  const TransferScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _accNumberController = TextEditingController();
  final _bankController = TextEditingController();

  Bank? _selectedBank;
  bool _isVerifying = false;

  Timer? _debounceTimer;

  @override
  void dispose() {
    // ref.read(transferNotifierProvider.notifier).reset();

    _bankController.dispose();
    _accNumberController.dispose();

    super.dispose();
  }

  Future<void> _verifyAccount() async {
    if (_accNumberController.text.length != 10 || _selectedBank == null) {
      CustomSnackbar.show(
        context,
        'Please enter a valid 10-digit account number and select a bank',
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await ref
          .read(transferNotifierProvider.notifier)
          .verifyAccount(
            accountNumber: _accNumberController.text,
            bankName: _selectedBank!.name,
          );

      final verifiedAccount = ref
          .read(transferNotifierProvider)
          .verifiedAccount;

      if (verifiedAccount != null && mounted) {
        _AccountConfirmationBottomSheet.show(
          context,
          accountName: verifiedAccount.accountName,
          accountNumber: _accNumberController.text,
          bankName: _selectedBank!.name,
          bankCode: _selectedBank!.code,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to verify account. Please try again',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _checkAccountVerification() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (_accNumberController.text.length == 10 && _selectedBank != null) {
      // Wait 500ms before verifying
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _verifyAccount();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(banksProvider);
    final transferState = ref.watch(transferNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send to any bank'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MiniButton(
              text: 'Next',
              onTap: transferState.verifiedAccount != null && !_isVerifying
                  ? _verifyAccount
                  : null,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Recent transfers',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Gap(8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 24,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    8,
                    (index) => _buildRecentItem('Aegon Targaryen'),
                  ),
                ),
              ),
              const Gap(16),
              CustomTextFormField(
                label: 'Account Number',
                isRounded: true,
                controller: _accNumberController,
                onChanged: (value) {
                  if (value.length == 10 && _selectedBank != null) {
                    _checkAccountVerification();
                  }
                },
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CopyTextIconButton(
                    label: 'Paste',
                    onPressed: () {
                      ClipboardUtils.pasteAccountNumber(
                        _accNumberController,
                        onSuccess: _checkAccountVerification,
                      );
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
              if (transferState.verifiedAccount != null &&
                  !transferState.isLoading)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        transferState.verifiedAccount!.accountName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.neulisNeueFontFamily,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else if (_isVerifying)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const Gap(4),
                    Text(
                      'Verifying account...',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: Constants.neulisNeueFontFamily,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              const Gap(16),
              banksAsync.when(
                data: (banks) {
                  // Filter banks for Nigeria (assuming this is for Nigerian banks)
                  final nigerianBanks = banks
                      .where((bank) => bank.isNigerianBank)
                      .toList();

                  // Sort banks alphabetically by name
                  nigerianBanks.sort((a, b) => a.name.compareTo(b.name));

                  return CustomDropdownButton(
                    items: nigerianBanks.map((bank) => bank.name).toList(),
                    value: _selectedBank?.name,
                    enabled: true,
                    enableSearch: true,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    onChanged: (bank) {
                      setState(() {
                        _selectedBank = nigerianBanks.firstWhere(
                          (e) => e.name == bank,
                        );
                        // Clear verified account when bank changes
                        ref
                            .read(transferNotifierProvider.notifier)
                            .clearVerifiedAccount();
                      });
                      if (_accNumberController.text.length == 10) {
                        _checkAccountVerification();
                      }
                    },
                    hint: 'Select bank',
                    label: 'Bank',
                    leadingIcon: Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                    ),
                  );
                },
                loading: () => CustomDropdownButton(
                  items: const [],
                  hint: 'Loading banks...',
                  label: 'Bank',
                  enabled: false,
                  leadingIcon: Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.grey,
                  ),
                ),
                error: (error, stack) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdownButton(
                      items: const [],
                      hint: 'Failed to load banks',
                      label: 'Bank',
                      leadingIcon: Icon(
                        Icons.account_balance_rounded,
                        color: AppColors.error,
                      ),
                    ),
                    const Gap(4),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(banksProvider),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'Retry',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String name) {
    var textStyle = TextStyle(
      height: 1.1,
      fontSize: 10,
      fontFamily: Constants.neulisNeueFontFamily,
    );
    return InkWell(
      onTap: () {
        // TODO: Implement recent transfer selection
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.ac_unit_rounded, color: AppColors.success),
          ),
          const Gap(8),
          Text(
            name.split(' ').join('\n'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}

class _AccountConfirmationBottomSheet extends ConsumerWidget {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String bankCode;

  const _AccountConfirmationBottomSheet({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(8),
          Container(
            width: 40,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Gap(24),
          SvgPicture.asset(Assets.bankSvg),
          const Gap(24),
          Text(
            accountName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'You are sending to ',
              children: [
                TextSpan(
                  text: '$accountName ($bankName)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '. Is this correct?'),
              ],
              style: TextStyle(
                fontSize: 12,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
          ),
          const Gap(24),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: CustomOutlinedButton(
                  text: 'Cancel',
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Confirm',
                  buttonColor: CustomButtonColor.black,
                  onPressed: () {
                    context.pop();
                    context.pushNamed(
                      SendMoneyScreen.path,
                      extra: RecipientAccountInfo(
                        accountName: accountName,
                        accountNumber: accountNumber,
                        bankName: bankName,
                        bankCode: bankCode,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String accountName,
    required String accountNumber,
    required String bankName,
    required String bankCode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AccountConfirmationBottomSheet(
        accountName: accountName,
        accountNumber: accountNumber,
        bankName: bankName,
        bankCode: bankCode,
      ),
    );
  }
}
