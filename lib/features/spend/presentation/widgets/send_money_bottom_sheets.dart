import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/send_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/widgets/dial_pad_widget.dart';
import '../../../../core/widgets/dot.dart';
import '../../../../features/spend/domain/models/internal_transfer.dart';
import '../providers/wallet_provider.dart';
import '../providers/transfer_provider.dart';

class EnterAmountBottomSheet extends ConsumerStatefulWidget {
  final RecipientAccountInfo recipientAccountInfo;

  const EnterAmountBottomSheet({super.key, required this.recipientAccountInfo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EnterAmountBottomSheetState();

  static void show(
    BuildContext context, {
    required RecipientAccountInfo recipientAccountInfo,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) =>
          EnterAmountBottomSheet(recipientAccountInfo: recipientAccountInfo),
    );
  }
}

class _EnterAmountBottomSheetState
    extends ConsumerState<EnterAmountBottomSheet> {
  final _narrationController = TextEditingController();
  final _amountController = TextEditingController();
  final _formatter = CurrencyInputFormatter();

  void _updateAmount(String newText) {
    final oldValue = _amountController.value;
    final newValue = oldValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    final formattedValue = _formatter.formatEditUpdate(oldValue, newValue);
    setState(() {
      _amountController.value = formattedValue;
    });
  }

  void _onNumberPressed(String number) {
    final currentText = _amountController.text;
    _updateAmount(currentText + number);
  }

  void _onDecimalPressed() {
    final currentText = _amountController.text;
    _updateAmount('$currentText.');
  }

  void _onDeletePressed() {
    final currentText = _amountController.text;
    if (currentText.isNotEmpty) {
      final newText = currentText.substring(0, currentText.length - 1);
      _updateAmount(newText);
    }
  }

  Future<void> _handleProceed() async {
    try {
      // Parse amount (remove commas and convert to double)
      // final amount = double.parse(_amountController.text.replaceAll(',', ''));

      if (!mounted) return;

      // Navigate to PIN entry
      EnterPinBottomSheet.show(
        context,
        amount: _amountController.text,
        category: _narrationController.text,
        recipientAccountInfo: widget.recipientAccountInfo,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        e.toString(),
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(24),
          if (dashboardAsync.isLoading)
            const SizedBox()
          else if (dashboardAsync.hasError)
            Text('Error: ${dashboardAsync.error}')
          else
            CustomCard(
              borderColor: AppColors.primary,
              bgColor: AppColors.primaryFaint,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Text(
                'Savvy Wallet Balance: ${dashboardAsync.value?.data?.accounts.balance.formatCurrency(decimalDigits: 0)}',
                style: TextStyle(fontSize: 12),
              ),
            ),
          const Gap(32),
          CustomTextFormField(
            controller: _amountController,
            showOutline: false,
            hint: 0.formatCurrency(decimalDigits: 0),
            readOnly: true,
            keyboardType: TextInputType.none,
            onChanged: (_) {
              setState(() {});
            },
            inputFormatters: [CurrencyInputFormatter()],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _narrationController,
                  showOutline: false,
                  hint: 'Narration',
                  prefixIcon: IconButton(
                    onPressed: () async {
                      await BudgetCategoryBottomSheet.show(context).then((
                        value,
                      ) {
                        if (value != null) {
                          _narrationController.text = value;
                        }
                      });
                      setState(() {});
                    },
                    icon: Icon(Icons.pie_chart, color: AppColors.primary),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),
              MiniButton(
                onTap:
                    _amountController.text.trim().isEmpty ||
                        _narrationController.text.trim().isEmpty
                    ? null
                    : _handleProceed,
                child: Icon(
                  Icons.send_outlined,
                  size: 16,
                  color:
                      _amountController.text.trim().isEmpty ||
                          _narrationController.text.trim().isEmpty
                      ? AppColors.buttonDisabled
                      : null,
                ),
              ),
            ],
          ),
          const Gap(32),
          DialPad(
            onNumberPressed: (number) => _onNumberPressed(number),
            onDecimalPressed: _onDecimalPressed,
            onDeletePressed: _onDeletePressed,
          ),
        ],
      ),
    );
  }
}

class EnterPinBottomSheet extends ConsumerStatefulWidget {
  final String amount;
  final String category;
  final RecipientAccountInfo recipientAccountInfo;

  const EnterPinBottomSheet({
    super.key,
    required this.amount,
    required this.category,
    required this.recipientAccountInfo,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EnterPinBottomSheetState();

  static void show(
    BuildContext context, {
    required String amount,
    required String category,
    required RecipientAccountInfo recipientAccountInfo,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (context) => EnterPinBottomSheet(
        amount: amount,
        category: category,
        recipientAccountInfo: recipientAccountInfo,
      ),
    );
  }
}

class _EnterPinBottomSheetState extends ConsumerState<EnterPinBottomSheet> {
  String pin = '';
  bool _isProcessing = false;
  // bool _isInitializing = true;

  @override
  void initState() {
    super.initState();

    // _initializeTransaction();
  }

  // Future<void> _initializeTransaction() async {
  //   try {
  //     final amount = double.parse(widget.amount.replaceAll(',', ''));
  //     // Initialize the transaction
  //     await ref.read(
  //       initializeTransferProvider((
  //         accountNumber: widget.recipientAccountInfo.accountNumber,
  //         bankCode: widget.recipientAccountInfo.bankCode,
  //         amount: amount,
  //       )).future,
  //     );
  //     if (mounted) {
  //       setState(() => _isInitializing = false);
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     CustomSnackbar.show(
  //       context,
  //       'Initialization error: ${e.toString()}',
  //       type: SnackbarType.error,
  //       position: SnackbarPosition.bottom,
  //     );
  //     context.pop();
  //   }
  // }

  void _updatePin(String newText) {
    if (newText.length <= 4) {
      setState(() => pin = newText);
    }
    if (pin.length == 4 && !_isProcessing) {
      _processTransaction();
    }
  }

  Future<void> _processTransaction() async {
    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(widget.amount.replaceAll(',', ''));

      await ref
          .read(transferNotifierProvider.notifier)
          .initiateExternalTransfer(
            accountNumber: widget.recipientAccountInfo.accountNumber,
            bankCode: widget.recipientAccountInfo.bankCode,
            amount: amount,
            pin: pin,
            transferFor: widget.category,
            narration: widget.category,
          );

      if (!mounted) return;

      final transferState = ref.read(transferNotifierProvider);

      if (transferState.transaction != null) {
        context.pop();
        context.pop();
        TransactionCompletionBottomSheet.show(
          context,
          transaction: transferState.transaction!,
          recipientName: widget.recipientAccountInfo.accountName,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        pin = '';
        _isProcessing = false;
      });
      // Capture messenger before popping so the snackbar shows on the
      // underlying screen rather than behind the bottom sheet.
      final messenger = ScaffoldMessenger.of(context);
      final errorMessage = e.toString();
      context.pop(); // close PIN sheet
      context.pop(); // close amount sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: CustomSnackbar(text: errorMessage, type: SnackbarType.error),
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 4),
            dismissDirection: DismissDirection.down,
            margin: const EdgeInsets.only(left: 10, right: 10),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  void _onNumberPressed(String number) {
    if (pin.length < 4 && !_isProcessing) {
      _updatePin(pin + number);
    }
  }

  void _onDeletePressed() {
    if (pin.isNotEmpty && !_isProcessing) {
      _updatePin(pin.substring(0, pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);
    final initAsync = ref.watch(
      initializeTransferProvider((
        accountNumber: widget.recipientAccountInfo.accountNumber,
        bankCode: widget.recipientAccountInfo.bankCode,
        amount: double.parse(widget.amount.replaceAll(',', '')),
      )),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _isProcessing ? null : () => context.pop(),
                    style: Constants.collapsedButtonStyle,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.recipientAccountInfo.accountName} (${widget.recipientAccountInfo.bankName})',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    double.parse(
                      widget.amount.split(',').join(),
                    ).formatCurrency(decimalDigits: 0),
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.category, style: TextStyle(fontSize: 16)),
                      const Gap(8),
                      Icon(Icons.pie_chart, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
              const Gap(24),
              CustomCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                borderRadius: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('From:', style: TextStyle(fontSize: 10)),
                        Text(
                          dashboardAsync.when(
                            data: (data) =>
                                data.data?.accounts.ngnAccount?.accountNumber ??
                                '',
                            loading: () => 'Loading...',
                            error: (error, stackTrace) => 'Error: $error',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction Fee:',
                          style: TextStyle(fontSize: 10),
                        ),
                        initAsync.when(
                          data: (data) {
                            final fee = data['fee'] ?? '10';
                            return Text(
                              double.parse(
                                fee.toString(),
                              ).formatCurrency(decimalDigits: 0),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                          loading: () => Text(
                            'Loading...',
                            style: TextStyle(fontSize: 10),
                          ),
                          error: (error, _) => Text(
                            10.formatCurrency(decimalDigits: 0),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                  const Gap(8),
                  Text('Transaction PIN', style: TextStyle(fontSize: 12)),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _isProcessing
                    ? [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ]
                    : List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Dot(
                            size: 16,
                            color: index < pin.length
                                ? AppColors.primary
                                : AppColors.grey,
                          ),
                        );
                      }),
              ),
              const Gap(24),
              DialPad(
                onNumberPressed: _isProcessing
                    ? (_) {}
                    : (number) => _onNumberPressed(number),
                onDecimalPressed: () {},
                onDeletePressed: _isProcessing ? () {} : _onDeletePressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionCompletionBottomSheet extends StatelessWidget {
  final dynamic transaction;
  final String recipientName;

  const TransactionCompletionBottomSheet({
    super.key,
    required this.transaction,
    required this.recipientName,
  });

  static void show(
    BuildContext context, {
    required dynamic transaction,
    required String recipientName,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TransactionCompletionBottomSheet(
        transaction: transaction,
        recipientName: recipientName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = transaction.amount;
    final fee = transaction.fee;
    final status = transaction.status;
    final reference = transaction.reference;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(6),
        Container(
          width: 40,
          padding: EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                status.toLowerCase() == 'success'
                    ? Assets.successSvg
                    : Assets.errorSvg,
              ),
              const Gap(16),
              Text(
                status.toLowerCase() == 'success' ? 'Sent' : 'Failed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Gap(4),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text:
                      '₦${double.parse(amount).formatCurrency(decimalDigits: 0)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: status.toLowerCase() == 'success'
                          ? ' is on its way to\n'
                          : ' transfer failed\n',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    if (status.toLowerCase() == 'success')
                      TextSpan(text: recipientName),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                'Reference: $reference',
                style: TextStyle(fontSize: 10, color: AppColors.grey),
              ),
              Text(
                'Fee: ₦${double.parse(fee).formatCurrency(decimalDigits: 0)}',
                style: TextStyle(fontSize: 10, color: AppColors.grey),
              ),
              const Gap(24),
              CustomElevatedButton(
                text: 'Share receipt',
                onPressed: () {},
                buttonColor: CustomButtonColor.black,
                icon: Icon(Icons.file_upload_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL TRANSFER BOTTOM SHEETS
// ─────────────────────────────────────────────────────────────────────────────

// ── Enter Amount ─────────────────────────────────────────────────────────────

class InternalEnterAmountBottomSheet extends ConsumerStatefulWidget {
  final String username;

  const InternalEnterAmountBottomSheet({super.key, required this.username});

  @override
  ConsumerState<InternalEnterAmountBottomSheet> createState() =>
      _InternalEnterAmountBottomSheetState();

  static void show(BuildContext context, {required String username}) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) =>
          InternalEnterAmountBottomSheet(username: username),
    );
  }
}

class _InternalEnterAmountBottomSheetState
    extends ConsumerState<InternalEnterAmountBottomSheet> {
  final _narrationController = TextEditingController();
  final _amountController = TextEditingController();
  final _formatter = CurrencyInputFormatter();

  @override
  void dispose() {
    _narrationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(String newText) {
    final oldValue = _amountController.value;
    final newValue = oldValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    setState(() {
      _amountController.value = _formatter.formatEditUpdate(oldValue, newValue);
    });
  }

  void _onNumberPressed(String number) =>
      _updateAmount(_amountController.text + number);

  void _onDecimalPressed() => _updateAmount('${_amountController.text}.');

  void _onDeletePressed() {
    final text = _amountController.text;
    if (text.isNotEmpty) _updateAmount(text.substring(0, text.length - 1));
  }

  void _handleProceed() {
    InternalEnterPinBottomSheet.show(
      context,
      username: widget.username,
      amount: _amountController.text,
      category: _narrationController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);
    final canProceed = _amountController.text.trim().isNotEmpty &&
        _narrationController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(24),
          Text(
            '@${widget.username}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          if (dashboardAsync.hasValue)
            CustomCard(
              borderColor: AppColors.primary,
              bgColor: AppColors.primaryFaint,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Text(
                'Savvy Wallet Balance: ${dashboardAsync.value?.data?.accounts.balance.formatCurrency(decimalDigits: 0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          const Gap(32),
          CustomTextFormField(
            controller: _amountController,
            showOutline: false,
            hint: 0.formatCurrency(decimalDigits: 0),
            readOnly: true,
            keyboardType: TextInputType.none,
            onChanged: (_) => setState(() {}),
            inputFormatters: [CurrencyInputFormatter()],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _narrationController,
                  showOutline: false,
                  hint: 'Narration',
                  prefixIcon: IconButton(
                    onPressed: () async {
                      final value =
                          await BudgetCategoryBottomSheet.show(context);
                      if (value != null) {
                        _narrationController.text = value;
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.pie_chart, color: AppColors.primary),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              MiniButton(
                onTap: canProceed ? _handleProceed : null,
                child: Icon(
                  Icons.send_outlined,
                  size: 16,
                  color: canProceed ? null : AppColors.buttonDisabled,
                ),
              ),
            ],
          ),
          const Gap(32),
          DialPad(
            onNumberPressed: _onNumberPressed,
            onDecimalPressed: _onDecimalPressed,
            onDeletePressed: _onDeletePressed,
          ),
        ],
      ),
    );
  }
}

// ── Enter PIN ─────────────────────────────────────────────────────────────────

class InternalEnterPinBottomSheet extends ConsumerStatefulWidget {
  final String username;
  final String amount;
  final String category;

  const InternalEnterPinBottomSheet({
    super.key,
    required this.username,
    required this.amount,
    required this.category,
  });

  @override
  ConsumerState<InternalEnterPinBottomSheet> createState() =>
      _InternalEnterPinBottomSheetState();

  static void show(
    BuildContext context, {
    required String username,
    required String amount,
    required String category,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (context) => InternalEnterPinBottomSheet(
        username: username,
        amount: amount,
        category: category,
      ),
    );
  }
}

class _InternalEnterPinBottomSheetState
    extends ConsumerState<InternalEnterPinBottomSheet> {
  String pin = '';
  bool _isProcessing = false;

  void _updatePin(String newPin) {
    if (newPin.length <= 4) setState(() => pin = newPin);
    if (pin.length == 4 && !_isProcessing) _processTransaction();
  }

  void _onNumberPressed(String number) {
    if (pin.length < 4 && !_isProcessing) _updatePin(pin + number);
  }

  void _onDeletePressed() {
    if (pin.isNotEmpty && !_isProcessing) {
      _updatePin(pin.substring(0, pin.length - 1));
    }
  }

  Future<void> _processTransaction() async {
    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(widget.amount.replaceAll(',', ''));

      await ref
          .read(transferNotifierProvider.notifier)
          .sendMoneyInternally(
            pin: pin,
            transferFor: widget.category,
            narration: widget.category,
            username: widget.username,
            amount: amount,
          );

      if (!mounted) return;

      final transfer = ref.read(transferNotifierProvider).internalTransfer;

      if (transfer != null) {
        context.pop(); // close PIN sheet
        context.pop(); // close amount sheet
        InternalTransferCompletionBottomSheet.show(
          context,
          transfer: transfer,
          recipientUsername: widget.username,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        pin = '';
        _isProcessing = false;
      });
      final messenger = ScaffoldMessenger.of(context);
      final errorMessage = e.toString();
      context.pop(); // close PIN sheet
      context.pop(); // close amount sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content:
                CustomSnackbar(text: errorMessage, type: SnackbarType.error),
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 4),
            dismissDirection: DismissDirection.down,
            margin: const EdgeInsets.only(left: 10, right: 10),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _isProcessing ? null : () => context.pop(),
                    style: Constants.collapsedButtonStyle,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(16),
              Text(
                '@${widget.username}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Gap(16),
              Text(
                double.parse(
                  widget.amount.split(',').join(),
                ).formatCurrency(decimalDigits: 0),
                style: const TextStyle(fontSize: 16),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                  Gap(8),
                  Text('Transaction PIN', style: TextStyle(fontSize: 12)),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _isProcessing
                    ? [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ]
                    : List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Dot(
                            size: 16,
                            color: index < pin.length
                                ? AppColors.primary
                                : AppColors.grey,
                          ),
                        );
                      }),
              ),
              const Gap(24),
              DialPad(
                onNumberPressed:
                    _isProcessing ? (_) {} : _onNumberPressed,
                onDecimalPressed: () {},
                onDeletePressed: _isProcessing ? () {} : _onDeletePressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Completion ────────────────────────────────────────────────────────────────

class InternalTransferCompletionBottomSheet extends StatelessWidget {
  final InternalTransferData transfer;
  final String recipientUsername;

  const InternalTransferCompletionBottomSheet({
    super.key,
    required this.transfer,
    required this.recipientUsername,
  });

  static void show(
    BuildContext context, {
    required InternalTransferData transfer,
    required String recipientUsername,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => InternalTransferCompletionBottomSheet(
        transfer: transfer,
        recipientUsername: recipientUsername,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = transfer.status.toLowerCase() == 'success';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(6),
        Container(
          width: 40,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                isSuccess ? Assets.successSvg : Assets.errorSvg,
              ),
              const Gap(16),
              Text(
                isSuccess ? 'Sent' : 'Failed',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: transfer.amount.formatCurrency(decimalDigits: 0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: isSuccess
                          ? ' is on its way to\n'
                          : ' transfer failed\n',
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                    if (isSuccess) TextSpan(text: '@$recipientUsername'),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                'Reference: ${transfer.id}',
                style: TextStyle(fontSize: 10, color: AppColors.grey),
              ),
              Text(
                'Charges: ${transfer.charges.formatCurrency(decimalDigits: 0)}',
                style: TextStyle(fontSize: 10, color: AppColors.grey),
              ),
              const Gap(24),
              CustomElevatedButton(
                text: 'Done',
                onPressed: () => context.pop(),
                buttonColor: CustomButtonColor.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
