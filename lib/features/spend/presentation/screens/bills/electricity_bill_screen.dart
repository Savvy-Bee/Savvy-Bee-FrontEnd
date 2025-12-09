import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/num_extensions.dart';
import '../../widgets/mini_button.dart';

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

  // Quick amount options
  final List<int> _quickAmounts = [200, 500, 1000, 2000, 3000, 5000];

  void _selectAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MiniButton(onTap: () {}, text: 'Next'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomTextFormField(
            label: 'Service Provider',
            hint: 'Choose a Provider',
            controller: _serviceProviderController,
            prefix: Icon(Icons.circle_outlined, color: AppColors.primary),
            suffix: Icon(Icons.keyboard_arrow_down),
            readOnly: true,
            onTap: () => ServiceProviderBottomSheet.show(context),
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Package',
            hint: 'Choose a Package',
            controller: _packageController,
            suffix: Icon(Icons.keyboard_arrow_down),
            readOnly: true,
            onTap: () => DataPackageBottomSheet.show(context),
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
}

class DataPackageBottomSheet extends StatefulWidget {
  const DataPackageBottomSheet({super.key});

  @override
  State<DataPackageBottomSheet> createState() => _DataPackageBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DataPackageBottomSheet(),
    );
  }
}

class _DataPackageBottomSheetState extends State<DataPackageBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose a Package',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(16),
        Text('Categories', style: TextStyle(fontSize: 12)),
        const Gap(16),
        Row(
          spacing: 8,
          children: [
            _buildCategoryTile('Daily', true, () {}),
            _buildCategoryTile('Weekly', false, () {}),
            _buildCategoryTile('Monthly', false, () {}),
            _buildCategoryTile('Yearly', false, () {}),
          ],
        ),
        const Gap(16),
        Text('Packages', style: TextStyle(fontSize: 12)),
        const Gap(16),
        _buildPackageTile('45MB for 1 Day - ₦50'),
        const Divider(height: 20),
        _buildPackageTile('15MB Social Bundle for 3 Nights - ₦150'),
        const Divider(height: 20),
        _buildPackageTile('15MB Social Bundle for 3 Nights - ₦50'),
        const Divider(height: 20),
        _buildPackageTile('15MB Social Bundle for 3 Nights - ₦50'),
        const Divider(height: 20),
        _buildPackageTile('15MB Social Bundle for 3 Nights - ₦50'),
        const Divider(height: 20),
        _buildPackageTile('15MB Social Bundle for 3 Nights - ₦50'),
        const Divider(height: 20),
        _buildPackageTile('15MB Social Bundle for 3 Nights - ₦50'),
        const Gap(24),
      ],
    );
  }

  Widget _buildCategoryTile(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: CustomCard(
        onTap: onTap,
        borderRadius: 8,
        borderColor: isSelected ? AppColors.primary : null,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildPackageTile(String name) {
    return Row(
      spacing: 16,
      children: [
        CircleAvatar(),
        Text(name, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class ServiceProviderBottomSheet extends StatelessWidget {
  const ServiceProviderBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose a Provider',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          _buildServiceProviderTile('MTN-NG DATA'),
          const Divider(height: 20),
          _buildServiceProviderTile('AIRTEL NG DATA'),
          const Divider(height: 20),
          _buildServiceProviderTile('GLO NG DATA'),
          const Divider(height: 20),
          _buildServiceProviderTile('9MOBILE NG DATA'),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildServiceProviderTile(String name) {
    return Row(
      spacing: 16,
      children: [
        CircleAvatar(),
        Text(name, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => ServiceProviderBottomSheet(),
    );
  }
}
