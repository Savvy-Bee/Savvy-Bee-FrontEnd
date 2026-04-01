import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/bill_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';

import '../../../../../core/utils/num_extensions.dart';
import '../../../domain/models/bills.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';
import '../../widgets/mini_button.dart';

class CableBillScreen extends ConsumerStatefulWidget {
  static const String path = '/cable-bill';

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

  TvProvider? _selectedProvider;
  TvPlan? _selectedPlan;
  bool _isInitializing = false;

  @override
  void dispose() {
    _serviceProviderController.dispose();
    _packageController.dispose();
    _cardNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onProviderSelected(TvProvider provider) {
    setState(() {
      _selectedProvider = provider;
      _serviceProviderController.text = provider.name;
      _selectedPlan = null;
      _packageController.clear();
      _amountController.clear();
    });
  }

  void _onPlanSelected(TvPlan plan) {
    setState(() {
      _selectedPlan = plan;
      _packageController.text = plan.name;
      _amountController.text = plan.amount;
    });
  }

  bool _canProceed() {
    return _selectedProvider != null &&
        _selectedPlan != null &&
        _cardNumberController.text.trim().isNotEmpty;
  }

  Future<void> _handleProceed() async {
    if (!_canProceed()) {
      CustomSnackbar.show(
        context,
        'Please fill in all fields before proceeding.',
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
      return;
    }

    setState(() => _isInitializing = true);

    try {
      final success = await ref
          .read(tvProvider.notifier)
          .initializeTv(
            phoneNo: _cardNumberController.text.trim(),
            provider: _selectedProvider!.shortName,
            code: _selectedPlan!.code,
          );

      if (!mounted) return;

      if (success) {
        context.pushNamed(
          BillConfirmationScreen.path,
          extra: BillConfirmationData(
            type: BillType.tv,
            network: _selectedProvider!.name,
            phoneNumber: _cardNumberController.text.trim(),
            amount: double.tryParse(_selectedPlan!.amount) ?? 0,
            provider: _selectedProvider!.shortName,
            planCode: _selectedPlan!.code,
            planName: _selectedPlan!.name,
          ),
        );
      } else {
        CustomSnackbar.show(
          context,
          'Failed to initialize TV subscription. Please try again.',
          type: SnackbarType.error,
          position: SnackbarPosition.bottom,
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TV'),
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
                : MiniButton(onTap: _handleProceed, text: 'Next'),
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
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
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
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
            readOnly: true,
            onTap: () {
              if (_selectedProvider == null) {
                CustomSnackbar.show(
                  context,
                  'Please select a service provider first.',
                  type: SnackbarType.error,
                  position: SnackbarPosition.bottom,
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
            hint: 'Enter Smart Card Number',
            controller: _cardNumberController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
          ),
          const Gap(16),
          CustomTextFormField(
            label: 'Amount',
            hint: 'Auto-filled from package',
            endLabel: dashboardAsync.whenOrNull(
              data: (data) =>
                  'Balance: ₦${data.data?.accounts.balance.formatCurrency() ?? 'N/A'}',
            ),
            controller: _amountController,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
