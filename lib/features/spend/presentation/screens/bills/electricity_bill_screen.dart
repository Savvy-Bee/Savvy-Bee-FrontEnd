import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/bill_provider.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/num_extensions.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../domain/models/bills.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';
import '../../widgets/mini_button.dart';
import 'bill_confirmation_screen.dart';

class ElectricityBillScreen extends ConsumerStatefulWidget {
  static String path = '/electricity-bill';

  const ElectricityBillScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ElectricityBillScreenState();
}

class _ElectricityBillScreenState extends ConsumerState<ElectricityBillScreen> {
  final _serviceProviderController = TextEditingController();
  final _packageController = TextEditingController();
  final _meterNumberController = TextEditingController();
  final _amountController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Quick amount options
  final List<int> _quickAmounts = [1000, 2000, 3000, 5000, 7000, 10000];

  ElectricityProvider? _selectedProvider;
  String? _selectedPlan;

  bool _isInitializing = false;

  void _selectAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  /// Handle provider selection
  void _onProviderSelected(ElectricityProvider provider) {
    setState(() {
      _selectedProvider = provider;
      _serviceProviderController.text = provider.disco;

      // Reset package selection when provider changes
      _selectedPlan = null;
      _packageController.clear();
      _amountController.clear();
    });
  }

  bool _canProceed() {
    double amount = double.tryParse(_amountController.text.trim()) ?? 0;

    final canProceed =
        _formKey.currentState!.validate() &&
        _packageController.text.trim().isNotEmpty &&
        amount >= 1000;

    return canProceed;
  }

  void _handleNext() async {
    if (!_canProceed()) return;

    try {
      setState(() => _isInitializing = true);

      final success = await ref
          .read(electricityProvider.notifier)
          .initializeElectricity(
            provider: _selectedProvider?.shortName ?? '',
            amount: _amountController.text.trim(),
            meterType: _packageController.text,
            meterNumber: _meterNumberController.text.trim(),
          );

      if (success && mounted) {
        final billResponse = ref.read(electricityProvider).value;
        final customer = ElectricityCustomer.fromJson(billResponse?.data);

        if (billResponse != null) {
          CustomerDetailsConfirmationBottomSheet.show(
            context,
            customerName: customer.name,
            cardNumber: _meterNumberController.text.trim(),
            providerName: _selectedProvider?.disco ?? '',
            packageName: _packageController.text,
            onConfirm: () {
              context.pop(); // Close bottom sheet

              // Navigate to confirmation screen
              context.pushNamed(
                BillConfirmationScreen.path,
                extra: BillConfirmationData(
                  type: BillType.electricity,
                  network: _selectedProvider?.disco ?? '',
                  phoneNumber: _meterNumberController.text.trim(),
                  amount: double.tryParse(_amountController.text.trim()) ?? 0,
                  provider: _selectedProvider?.disco ?? '',
                  meterType: _packageController.text,
                  meterNumber: _meterNumberController.text.trim(),
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      setState(() => _isInitializing = false);
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to initialize electricity payment: ${e.toString()}',
          type: SnackbarType.error,
          position: SnackbarPosition.bottom,
        );
      }
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _serviceProviderController.dispose();
    _packageController.dispose();
    _meterNumberController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _isInitializing
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : MiniButton(onTap: _handleNext, text: 'Next'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextFormField(
              label: 'Service Provider',
              hint: 'Choose a Provider',
              controller: _serviceProviderController,
              prefixIcon: _selectedProvider != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0).copyWith(left: 16),
                      child: SizedBox.square(
                        dimension: 32,
                        child: CachedNetworkImage(
                          imageUrl: _selectedProvider?.logo ?? '',
                        ),
                      ),
                    )
                  : Icon(Icons.circle_outlined, color: AppColors.primary),
              suffixIcon: Icon(Icons.keyboard_arrow_down),
              readOnly: true,
              onTap: () {
                ServiceProviderBottomSheet.show(
                  context,
                  billType: BillType.electricity,
                  onElectricitySelect: _onProviderSelected,
                );
              },
              validator: (value) =>
                  InputValidator.validateRequired(value, 'Service provider'),
            ),
            const Gap(16),
            CustomDropdownButton(
              label: 'Package',
              hint: 'Choose a Package',
              controller: _packageController,
              items: ['Prepaid', 'Postpaid'],
              onChanged: (value) {
                _packageController.text = value ?? '';
              },
            ),
            const Gap(16),
            CustomTextFormField(
              label: 'Meter Number',
              hint: 'Meter Number',
              controller: _meterNumberController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) =>
                  InputValidator.validateRequired(value, 'Meter number'),
            ),
            const Gap(16),
            Text(
              'Choose an amount',
              style: TextStyle(
                fontSize: 12,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
            const Gap(8),
            Row(
              spacing: 8,
              children: _quickAmounts.sublist(0, 3).map((amount) {
                return _buildRechargeAmountItem(
                  amount.formatCurrency(decimalDigits: 0),
                  () => _selectAmount(amount),
                );
              }).toList(),
            ),
            const Gap(8),
            Row(
              spacing: 8,
              children: _quickAmounts.sublist(3, 6).map((amount) {
                return _buildRechargeAmountItem(
                  amount.formatCurrency(decimalDigits: 0),
                  () => _selectAmount(amount),
                );
              }).toList(),
            ),
            const Gap(16),
            CustomTextFormField(
              label: 'Amount',
              hint: 'Enter amount',
              endLabel: 'Balance: ₦11,638.16',
              controller: _amountController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  InputValidator.validateAmount(value, 'Amount', 1000),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeAmountItem(String amount, VoidCallback onTap) {
    return Expanded(
      child: CustomCard(
        onTap: onTap,
        borderColor: AppColors.borderDark,
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: 8,
        child: Center(
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
