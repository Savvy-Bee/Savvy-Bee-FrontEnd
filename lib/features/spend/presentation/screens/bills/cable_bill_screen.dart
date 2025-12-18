import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';

import '../../../domain/models/bills.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';
import '../../widgets/mini_button.dart';

class CableBillScreen extends ConsumerStatefulWidget {
  static String path = '/cable-bill';

  const CableBillScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CableBillScreenState();
}

class _CableBillScreenState extends ConsumerState<CableBillScreen> {
  final _serviceProviderController = TextEditingController();
  final _packageController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _amountController = TextEditingController();

  // Selected provider and plan
  TvProvider? _selectedProvider;
  TvPlan? _selectedPlan;

  @override
  void dispose() {
    _serviceProviderController.dispose();
    _packageController.dispose();
    _cardNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Handle provider selection
  void _onProviderSelected(TvProvider provider) {
    setState(() {
      _selectedProvider = provider;
      _serviceProviderController.text = provider.name;

      // Reset package selection when provider changes
      _selectedPlan = null;
      _packageController.clear();
      _amountController.clear();
    });
  }

  /// Handle plan selection
  void _onPlanSelected(TvPlan plan) {
    setState(() {
      _selectedPlan = plan;
      _packageController.text = plan.name;
      _amountController.text = plan.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV'),
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
            onTap: () {
              ServiceProviderBottomSheet.show(
                context,
                billType: BillType.tv,
                onTvSelect: _onProviderSelected,
              );
            },
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Package',
            hint: 'Choose a Package',
            controller: _packageController,
            suffix: Icon(Icons.keyboard_arrow_down),
            readOnly: true,
            onTap: () {
              // Only allow package selection if provider is selected
              if (_selectedProvider == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a service provider first'),
                  ),
                );
                return;
              }

              PackageBottomSheet.show(
                context,
                billType: BillType.tv,
                provider: _selectedProvider!.shortName,
                onTvSelect: _onPlanSelected,
              );
            },
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Smart Card Number',
            hint: 'Smart Card Number',
            controller: _cardNumberController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
}

