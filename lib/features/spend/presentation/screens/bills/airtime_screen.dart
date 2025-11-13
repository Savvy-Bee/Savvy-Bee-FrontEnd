import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

class AirtimeScreen extends ConsumerStatefulWidget {
  static String path = '/airtime';

  const AirtimeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends ConsumerState<AirtimeScreen> {
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airtime'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MiniButton(
              onTap: () => context.pushNamed(BillConfirmationScreen.path),
              text: 'Next',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Most recent',
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRecentItem('MTN', '08012345678'),
              _buildRecentItem('Airtel', '08112345678'),
              _buildRecentItem('9Mobile', '08212345678'),
              _buildRecentItem('9Mobile', '08212345678'),
            ],
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
            children: [
              _buildRechargeAmountItem(
                NumberFormatter.formatCurrency(200, decimalDigits: 0),
              ),
              _buildRechargeAmountItem(
                NumberFormatter.formatCurrency(500, decimalDigits: 0),
              ),
              _buildRechargeAmountItem(
                NumberFormatter.formatCurrency(1000, decimalDigits: 0),
              ),
            ],
          ),
          const Gap(8),
          Row(
            spacing: 8,
            children: [
              _buildRechargeAmountItem(
                NumberFormatter.formatCurrency(2000, decimalDigits: 0),
              ),
              _buildRechargeAmountItem(
                NumberFormatter.formatCurrency(3000, decimalDigits: 0),
              ),
              _buildRechargeAmountItem(
                NumberFormatter.formatCurrency(5000, decimalDigits: 0),
              ),
            ],
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Amount',
            endLabel: 'Balance: ₦11,638.16',
            hint: '550',
            isRounded: true,
            controller: _amountController,
          ),
          const Gap(16),
          Text(
            'Most recent',
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              4,
              (index) => _buildNetworkItem(
                ['MTN', '9Mobile', 'Airtel', 'GLO'][index],
                Icon(Icons.phone, size: 24),
                () {},
              ),
            ),
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Phone number',
            endLabel: 'Choose contact',
            hint: '08111111111',
            isRounded: true,
            controller: _amountController,
            onEndLabelPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(String label, Widget icon, VoidCallback onTap) {
    return CustomCard(
      borderColor: AppColors.borderDark,
      onTap: onTap,
      borderRadius: 8,
      width: 90.dg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeAmountItem(String amount) {
    return Expanded(
      child: CustomCard(
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

  Widget _buildRecentItem(String network, String phoneNumber) {
    var textStyle = TextStyle(
      height: 1.1,
      fontSize: 10,
      fontFamily: Constants.neulisNeueFontFamily,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.ac_unit_rounded),
        const Gap(8),
        Text(network, style: textStyle),
        Text(phoneNumber, style: textStyle),
      ],
    );
  }
}
