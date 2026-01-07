import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

import '../../providers/bill_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';

// State model for recent airtime purchase
class RecentAirtimePurchase {
  final String network;
  final String phoneNumber;

  RecentAirtimePurchase({required this.network, required this.phoneNumber});
}

class AirtimeScreen extends ConsumerStatefulWidget {
  static String path = '/airtime';

  const AirtimeScreen({super.key});

  @override
  ConsumerState<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends ConsumerState<AirtimeScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedNetwork;
  final bool _isProcessing = false;

  // Available networks - map display names to provider codes
  final Map<String, String> _networks = {
    'MTN': 'MTN',
    'Glo': 'GLO',
    'Airtel': 'AIRTEL',
    '9Mobile': '9MOBILE',
  };

  // Quick amount options
  final List<int> _quickAmounts = [200, 500, 1000, 2000, 3000, 5000];

  // Mock recent purchases - replace with actual data from provider
  final List<RecentAirtimePurchase> _recentPurchases = [
    RecentAirtimePurchase(network: 'MTN', phoneNumber: '08012345678'),
    RecentAirtimePurchase(network: 'Airtel', phoneNumber: '08112345678'),
    RecentAirtimePurchase(network: '9Mobile', phoneNumber: '08212345678'),
    RecentAirtimePurchase(network: 'Glo', phoneNumber: '08512345678'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _selectAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  void _selectNetwork(String network) {
    setState(() {
      _selectedNetwork = network;
    });
  }

  void _selectRecentPurchase(RecentAirtimePurchase purchase) {
    setState(() {
      _selectedNetwork = purchase.network;
      _phoneController.text = purchase.phoneNumber;
    });
  }

  Future<void> _selectContact() async {
    // TODO: Implement contact picker
    CustomSnackbar.show(
      context,
      'Contact picker not yet implemented',
      position: SnackbarPosition.bottom,
    );
  }

  bool _canProceed() {
    return _amountController.text.isNotEmpty &&
        _phoneController.text.length == 11 &&
        _selectedNetwork != null &&
        !_isProcessing;
  }

  Future<void> _proceedToConfirmation() async {
    if (!_canProceed()) {
      CustomSnackbar.show(
        context,
        'Please fill all required fields',
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      CustomSnackbar.show(
        context,
        'Please enter a valid amount',
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
      return;
    }

    if (amount < 100) {
      CustomSnackbar.show(
        context,
        'Minimum airtime amount is ₦100',
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
      return;
    }

    context.pushNamed(
      BillConfirmationScreen.path,
      extra: BillConfirmationData(
        type: BillType.airtime,
        network: _selectedNetwork ?? '',
        phoneNumber: _phoneController.text,
        amount: amount,
        provider: _networks[_selectedNetwork]!,
        transactionRef: 'response.reference',
      ),
    );
  }

  @override
    Widget build(BuildContext context) {
      final dashboardAsync = ref.watch(spendDashboardDataProvider);

    // Listen to airtime provider state
    ref.listen(airtimeProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          if (mounted) {
            CustomSnackbar.show(
              context,
              error.toString(),
              type: SnackbarType.error,
              position: SnackbarPosition.bottom,
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Airtime'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _isProcessing
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : MiniButton(
                    onTap: _canProceed() ? _proceedToConfirmation : null,
                    text: 'Next',
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recent purchases section would be populated from a provider
          // For now, keeping the mock data structure
          Text(
            'Most recent',
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(16),
          // TODO: Replace with actual recent purchases from provider
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _recentPurchases.map((purchase) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildRecentItem(
                    purchase.network,
                    purchase.phoneNumber,
                    () => _selectRecentPurchase(purchase),
                  ),
                );
              }).toList(),
            ),
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
            endLabel: dashboardAsync.whenOrNull(
              data: (data) =>
                  'Balance: ${data.data?.accounts.balance.formatCurrency(decimalDigits: 0) ?? 'N/A'}',
            ),
            hint: 'Enter amount',
            isRounded: true,
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => setState(() {}),
          ),
          const Gap(16),
          Text(
            'Network',
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 14,
            childAspectRatio: 0.9,
            children: _networks.keys.map((network) {
              final isSelected = _selectedNetwork == network;
              return _buildNetworkItem(
                network,
                const Icon(Icons.phone, size: 24),
                () => _selectNetwork(network),
                isSelected: isSelected,
              );
            }).toList(),
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Phone number',
            endLabel: 'Choose contact',
            hint: '08111111111',
            isRounded: true,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            onEndLabelPressed: _selectContact,
            onChanged: (value) => setState(() {}),
          ),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(
    String label,
    Widget icon,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    return CustomCard(
      borderColor: isSelected ? AppColors.primary : AppColors.borderDark,
      borderWidth: isSelected ? 1.5 : null,
      onTap: onTap,
      borderRadius: 8,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
              color: isSelected ? AppColors.primary : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  Widget _buildRecentItem(
    String network,
    String phoneNumber,
    VoidCallback onTap,
  ) {
    final textStyle = TextStyle(
      height: 1.1,
      fontSize: 10,
      fontFamily: Constants.neulisNeueFontFamily,
    );
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone_android, color: AppColors.primary),
          ),
          const Gap(8),
          Text(network, style: textStyle),
          Text(
            phoneNumber,
            style: textStyle.copyWith(
              fontSize: 8,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
