import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/bills.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';
import 'airtime_screen.dart';
import 'bill_confirmation_screen.dart';

class InternetBillScreen extends ConsumerStatefulWidget {
  static const String path = '/internet-bill';
  const InternetBillScreen({super.key});

  @override
  ConsumerState<InternetBillScreen> createState() => _InternetBillScreenState();
}

class _InternetBillScreenState extends ConsumerState<InternetBillScreen> {
  NigerianNetwork? _selectedNetwork;
  DataPlan? _selectedPlan;
  final _customerIdController = TextEditingController();

  @override
  void dispose() {
    _customerIdController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _onContinue() {
    if (_selectedNetwork == null) {
      _showSnack('Please select a network');
      return;
    }
    if (_selectedPlan == null) {
      _showSnack('Please select a data plan');
      return;
    }
    if (_customerIdController.text.trim().isEmpty) {
      _showSnack('Please enter a phone number');
      return;
    }
    context.pushNamed(
      BillConfirmationScreen.path,
      extra: BillConfirmationData(
        type: BillType.data,
        network: '${_selectedNetwork!.label} Data',
        phoneNumber: _customerIdController.text.trim(),
        amount: _selectedPlan!.amount.toDouble(),
        provider: _selectedNetwork!.providerCode,
        planCode: _selectedPlan!.code,
        planName: _selectedPlan!.package,
      ),
    );
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
                      'Mobile Data',
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
                      'Choose a data plan',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Gap(28),
                    const Text(
                      'Select Network',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: NigerianNetwork.values.map((network) {
                        final isSelected = _selectedNetwork == network;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedNetwork = network;
                                _selectedPlan = null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE0C97F)
                                      : Colors.grey.shade200,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: network.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    network.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'GeneralSans',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(24),
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
                            'Data Plan',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(10),
                          GestureDetector(
                            onTap: _selectedNetwork == null
                                ? () => _showSnack('Please select a network first')
                                : () {
                                    PackageBottomSheet.show(
                                      context,
                                      billType: BillType.data,
                                      provider: _selectedNetwork!.providerCode,
                                      onDataSelect: (plan) {
                                        setState(() => _selectedPlan = plan);
                                      },
                                    );
                                  },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wifi_outlined,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                                const Gap(10),
                                Expanded(
                                  child: Text(
                                    _selectedPlan != null
                                        ? '${_selectedPlan!.package} — ₦${_selectedPlan!.amount}'
                                        : 'Choose a plan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'GeneralSans',
                                      color: _selectedPlan != null
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
                          const Gap(16),
                          Divider(color: Colors.grey.shade100, height: 1),
                          const Gap(16),
                          Text(
                            'Phone Number',
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
                                Icons.phone_outlined,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                              const Gap(10),
                              Expanded(
                                child: TextField(
                                  controller: _customerIdController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'GeneralSans',
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '080 1234 5678',
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
                        ],
                      ),
                    ),
                    const Gap(32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
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
