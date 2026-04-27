import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/bills.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';
import 'bill_confirmation_screen.dart';

class ElectricityBillScreen extends ConsumerStatefulWidget {
  static const String path = '/electricity-bill';
  const ElectricityBillScreen({super.key});

  @override
  ConsumerState<ElectricityBillScreen> createState() =>
      _ElectricityBillScreenState();
}

class _ElectricityBillScreenState
    extends ConsumerState<ElectricityBillScreen> {
  ElectricityProvider? _selectedProvider;
  String? _selectedMeterType;
  final _meterNumberController = TextEditingController();
  final _amountController = TextEditingController();
  double _amount = 0;
  bool _isInitializing = false;

  static const List<int> _quickAmounts = [1000, 2000, 3000, 5000, 7000, 10000];

  @override
  void dispose() {
    _meterNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _amount = amount.toDouble();
      _amountController.text = amount.toString();
    });
  }

  Future<void> _onContinue() async {
    if (_selectedProvider == null) {
      _showSnack('Please select a provider');
      return;
    }
    if (_selectedMeterType == null) {
      _showSnack('Please select a meter type');
      return;
    }
    if (_meterNumberController.text.trim().isEmpty) {
      _showSnack('Please enter your meter number');
      return;
    }
    if (_amount < 1000) {
      _showSnack('Minimum amount is ₦1,000');
      return;
    }

    setState(() => _isInitializing = true);

    try {
      final success = await ref
          .read(electricityProvider.notifier)
          .initializeElectricity(
            provider: _selectedProvider!.shortName,
            amount: _amountController.text.trim(),
            meterType: _selectedMeterType!,
            meterNumber: _meterNumberController.text.trim(),
          );

      if (success && mounted) {
        final billResponse = ref.read(electricityProvider).value;
        final customer = ElectricityCustomer.fromJson(billResponse?.data);

        CustomerDetailsConfirmationBottomSheet.show(
          context,
          customerName: customer.name,
          cardNumber: _meterNumberController.text.trim(),
          providerName: _selectedProvider!.disco,
          packageName: _selectedMeterType!,
          onConfirm: () {
            context.pop();
            context.pushNamed(
              BillConfirmationScreen.path,
              extra: BillConfirmationData(
                type: BillType.electricity,
                network: _selectedProvider!.disco,
                phoneNumber: _meterNumberController.text.trim(),
                amount: _amount,
                provider: _selectedProvider!.shortName,
                meterType: _selectedMeterType!,
                meterNumber: _meterNumberController.text.trim(),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  String _formatQuickAmount(int amount) {
    return '${amount ~/ 1000}k';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(24),
                    const Text(
                      'Electricity',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Pay your power bill',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Gap(28),

                    // ── Service Provider ────────────────────────────────
                    const Text(
                      'Service Provider',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(14),
                    GestureDetector(
                      onTap: () {
                        ServiceProviderBottomSheet.show(
                          context,
                          billType: BillType.electricity,
                          onElectricitySelect: (provider) {
                            setState(() => _selectedProvider = provider);
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedProvider != null
                                ? const Color(0xFFE0C97F)
                                : Colors.grey.shade200,
                            width: _selectedProvider != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_selectedProvider != null &&
                                _selectedProvider!.logo.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CachedNetworkImage(
                                    imageUrl: _selectedProvider!.logo,
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.electric_bolt_outlined,
                                      size: 20,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.electric_bolt_outlined,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                _selectedProvider?.disco ?? 'Choose a provider',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'GeneralSans',
                                  color: _selectedProvider != null
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(24),

                    // ── Meter Type Toggle ───────────────────────────────
                    const Text(
                      'Meter Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(14),
                    Row(
                      children: ['Prepaid', 'Postpaid'].map((type) {
                        final isSelected = _selectedMeterType == type;
                        final isFirst = type == 'Prepaid';
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: isFirst ? 8 : 0),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedMeterType = type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'GeneralSans',
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const Gap(24),

                    // ── Meter Number + Amount card ───────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meter Number',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Icon(
                                Icons.speed_outlined,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                              const Gap(10),
                              Expanded(
                                child: TextField(
                                  controller: _meterNumberController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter meter number',
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'GeneralSans',
                                      color: Colors.grey.shade400,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Divider(color: Colors.grey.shade100, height: 1),
                          const Gap(16),
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(12),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₦',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'GeneralSans',
                                    color: _amount > 0
                                        ? Colors.black
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                const Gap(4),
                                IntrinsicWidth(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'GeneralSans',
                                      color: Colors.black,
                                      letterSpacing: -1,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'GeneralSans',
                                        color: Colors.grey.shade400,
                                        letterSpacing: -1,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(
                                        () => _amount =
                                            double.tryParse(val) ?? 0,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(24),

                    // ── Quick Amounts ───────────────────────────────────
                    const Text(
                      'Quick amounts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _quickAmounts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.8,
                          ),
                      itemBuilder: (context, index) {
                        final amt = _quickAmounts[index];
                        final isSelected = _amount == amt.toDouble();
                        return GestureDetector(
                          onTap: () => _selectQuickAmount(amt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '₦${_formatQuickAmount(amt)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'GeneralSans',
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const Gap(32),
                  ],
                ),
              ),
            ),

            // ── Continue Button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isInitializing ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isInitializing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
