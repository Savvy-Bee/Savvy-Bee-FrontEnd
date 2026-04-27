import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/bottom_sheets/bills_bottom_sheet.dart';

enum NigerianNetwork { mtn, airtel, glo, nineMobile }

extension NetworkInfo on NigerianNetwork {
  String get label {
    switch (this) {
      case NigerianNetwork.mtn:
        return 'MTN';
      case NigerianNetwork.airtel:
        return 'Airtel';
      case NigerianNetwork.glo:
        return 'Glo';
      case NigerianNetwork.nineMobile:
        return '9mobile';
    }
  }

  Color get color {
    switch (this) {
      case NigerianNetwork.mtn:
        return const Color(0xFFFFC107);
      case NigerianNetwork.airtel:
        return const Color(0xFFE53935);
      case NigerianNetwork.glo:
        return const Color(0xFF43A047);
      case NigerianNetwork.nineMobile:
        return const Color(0xFF1E88E5);
    }
  }

  String get providerCode {
    switch (this) {
      case NigerianNetwork.mtn:
        return 'MTN';
      case NigerianNetwork.airtel:
        return 'AIRTEL';
      case NigerianNetwork.glo:
        return 'GLO';
      case NigerianNetwork.nineMobile:
        return '9MOBILE';
    }
  }
}

class AirtimeScreen extends StatefulWidget {
  static const String path = '/airtime';

  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  NigerianNetwork? _selectedNetwork;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  double _amount = 0;

  static const List<int> _quickAmounts = [100, 200, 500, 1000, 2000, 5000];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _amount = amount.toDouble();
      _amountController.text = amount.toString();
    });
  }

  void _onContinue() {
    if (_selectedNetwork == null) {
      _showSnack('Please select a network');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnack('Please enter a phone number');
      return;
    }
    if (_amount <= 0) {
      _showSnack('Please enter an amount');
      return;
    }
    context.pushNamed(
      BillConfirmationScreen.path,
      extra: BillConfirmationData(
        type: BillType.airtime,
        network: _selectedNetwork!.label,
        phoneNumber: _phoneController.text.trim(),
        amount: _amount,
        provider: _selectedNetwork!.providerCode,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
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

                    // ── Back Arrow ──────────────────────────────────────
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),

                    const Gap(24),

                    // ── Title ───────────────────────────────────────────
                    const Text(
                      'Airtime',
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
                      'Quick recharge',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const Gap(28),

                    // ── Select Network ──────────────────────────────────────
                    // ── Select Network ──────────────────────────────────────
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
                            onTap: () =>
                                setState(() => _selectedNetwork = network),
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
                                      ? const Color(
                                          0xFFE0C97F,
                                        ) // warm amber border for selected
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

                    // ── Phone Number + Amount — single white card ───────────
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
                          // Phone Number label
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(8),

                          // Phone input row
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
                                  controller: _phoneController,
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

                          const Gap(16),
                          Divider(color: Colors.grey.shade100, height: 1),
                          const Gap(16),

                          // Amount label
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Gap(12),

                          // ₦ amount centered
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
                                        () =>
                                            _amount = double.tryParse(val) ?? 0,
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
                                '₦${_formatAmount(amt)}',
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

  String _formatAmount(int amount) {
    if (amount >= 1000) return '${amount ~/ 1000}000';
    return amount.toString();
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

// import '../../providers/bill_provider.dart';
// import '../../providers/wallet_provider.dart';
// import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';

// // State model for recent airtime purchase
// class RecentAirtimePurchase {
//   final String network;
//   final String phoneNumber;

//   RecentAirtimePurchase({required this.network, required this.phoneNumber});
// }

// class AirtimeScreen extends ConsumerStatefulWidget {
//   static const String path = '/airtime';

//   const AirtimeScreen({super.key});

//   @override
//   ConsumerState<AirtimeScreen> createState() => _AirtimeScreenState();
// }

// class _AirtimeScreenState extends ConsumerState<AirtimeScreen> {
//   final _amountController = TextEditingController();
//   final _phoneController = TextEditingController();
//   String? _selectedNetwork;
//   final bool _isProcessing = false;

//   // Available networks - map display names to provider codes
//   final Map<String, String> _networks = {
//     'MTN': 'MTN',
//     'Glo': 'GLO',
//     'Airtel': 'AIRTEL',
//     '9Mobile': '9MOBILE',
//   };

//   // Quick amount options
//   final List<int> _quickAmounts = [200, 500, 1000, 2000, 3000, 5000];

//   // Mock recent purchases - replace with actual data from provider
//   final List<RecentAirtimePurchase> _recentPurchases = [
//     RecentAirtimePurchase(network: 'MTN', phoneNumber: '08012345678'),
//     RecentAirtimePurchase(network: 'Airtel', phoneNumber: '08112345678'),
//     RecentAirtimePurchase(network: '9Mobile', phoneNumber: '08212345678'),
//     RecentAirtimePurchase(network: 'Glo', phoneNumber: '08512345678'),
//   ];

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _selectAmount(int amount) {
//     setState(() {
//       _amountController.text = amount.toString();
//     });
//   }

//   void _selectNetwork(String network) {
//     setState(() {
//       _selectedNetwork = network;
//     });
//   }

//   void _selectRecentPurchase(RecentAirtimePurchase purchase) {
//     setState(() {
//       _selectedNetwork = purchase.network;
//       _phoneController.text = purchase.phoneNumber;
//     });
//   }

//   Future<void> _selectContact() async {
//     // TODO: Implement contact picker
//     CustomSnackbar.show(
//       context,
//       'Contact picker not yet implemented',
//       position: SnackbarPosition.bottom,
//     );
//   }

//   bool _canProceed() {
//     return _amountController.text.isNotEmpty &&
//         _phoneController.text.length == 11 &&
//         _selectedNetwork != null &&
//         !_isProcessing;
//   }

//   Future<void> _proceedToConfirmation() async {
//     if (!_canProceed()) {
//       CustomSnackbar.show(
//         context,
//         'Please fill all required fields',
//         type: SnackbarType.error,
//         position: SnackbarPosition.bottom,
//       );
//       return;
//     }

//     final amount = double.tryParse(_amountController.text);

//     if (amount == null || amount <= 0) {
//       CustomSnackbar.show(
//         context,
//         'Please enter a valid amount',
//         type: SnackbarType.error,
//         position: SnackbarPosition.bottom,
//       );
//       return;
//     }

//     if (amount < 100) {
//       CustomSnackbar.show(
//         context,
//         'Minimum airtime amount is ₦100',
//         type: SnackbarType.error,
//         position: SnackbarPosition.bottom,
//       );
//       return;
//     }

//     context.pushNamed(
//       BillConfirmationScreen.path,
//       extra: BillConfirmationData(
//         type: BillType.airtime,
//         network: _selectedNetwork ?? '',
//         phoneNumber: _phoneController.text,
//         amount: amount,
//         provider: _networks[_selectedNetwork]!,
//         transactionRef: 'response.reference',
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dashboardAsync = ref.watch(spendDashboardDataProvider);

//     // Listen to airtime provider state
//     ref.listen(airtimeProvider, (previous, next) {
//       next.whenOrNull(
//         error: (error, stack) {
//           if (mounted) {
//             CustomSnackbar.show(
//               context,
//               error.toString(),
//               type: SnackbarType.error,
//               position: SnackbarPosition.bottom,
//             );
//           }
//         },
//       );
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Airtime'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: _isProcessing
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   )
//                 : MiniButton(
//                     onTap: _canProceed() ? _proceedToConfirmation : null,
//                     text: 'Next',
//                   ),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Recent purchases section would be populated from a provider
//           // For now, keeping the mock data structure
//           Text('Most recent', style: TextStyle(fontSize: 12)),
//           const Gap(16),
//           // TODO: Replace with actual recent purchases from provider
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: _recentPurchases.map((purchase) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 16.0),
//                   child: _buildRecentItem(
//                     purchase.network,
//                     purchase.phoneNumber,
//                     () => _selectRecentPurchase(purchase),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const Gap(16),
//           Text('Choose an amount', style: TextStyle(fontSize: 12)),
//           const Gap(8),
//           Row(
//             spacing: 8,
//             children: _quickAmounts.sublist(0, 3).map((amount) {
//               return _buildRechargeAmountItem(
//                 amount.formatCurrency(decimalDigits: 0),
//                 () => _selectAmount(amount),
//               );
//             }).toList(),
//           ),
//           const Gap(8),
//           Row(
//             spacing: 8,
//             children: _quickAmounts.sublist(3, 6).map((amount) {
//               return _buildRechargeAmountItem(
//                 amount.formatCurrency(decimalDigits: 0),
//                 () => _selectAmount(amount),
//               );
//             }).toList(),
//           ),
//           const Gap(16),
//           CustomTextFormField(
//             label: 'Amount',
//             endLabel: dashboardAsync.whenOrNull(
//               data: (data) =>
//                   'Balance: ${data.data?.accounts.balance.formatCurrency(decimalDigits: 0) ?? 'N/A'}',
//             ),
//             hint: 'Enter amount',
//             isRounded: true,
//             controller: _amountController,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             onChanged: (value) => setState(() {}),
//           ),
//           const Gap(16),
//           Text('Network', style: TextStyle(fontSize: 12)),
//           const Gap(8),
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 4,
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 14,
//             childAspectRatio: 0.9,
//             children: _networks.keys.map((network) {
//               final isSelected = _selectedNetwork == network;
//               return _buildNetworkItem(
//                 network,
//                 const Icon(Icons.phone, size: 24),
//                 () => _selectNetwork(network),
//                 isSelected: isSelected,
//               );
//             }).toList(),
//           ),
//           const Gap(16),
//           CustomTextFormField(
//             label: 'Phone number',
//             endLabel: 'Choose contact',
//             hint: '08111111111',
//             isRounded: true,
//             controller: _phoneController,
//             keyboardType: TextInputType.phone,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(11),
//             ],
//             onEndLabelPressed: _selectContact,
//             onChanged: (value) => setState(() {}),
//           ),
//           const Gap(24),
//         ],
//       ),
//     );
//   }

//   Widget _buildNetworkItem(
//     String label,
//     Widget icon,
//     VoidCallback onTap, {
//     bool isSelected = false,
//   }) {
//     return CustomCard(
//       borderColor: isSelected ? AppColors.primary : AppColors.borderDark,
//       borderWidth: isSelected ? 1.5 : null,
//       onTap: onTap,
//       borderRadius: 8,
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           icon,
//           const Gap(4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,

//               color: isSelected ? AppColors.primary : null,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRechargeAmountItem(String amount, VoidCallback onTap) {
//     return Expanded(
//       child: CustomCard(
//         onTap: onTap,
//         borderColor: AppColors.borderDark,
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         borderRadius: 8,
//         child: Center(
//           child: Text(
//             amount,
//             style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentItem(
//     String network,
//     String phoneNumber,
//     VoidCallback onTap,
//   ) {
//     final textStyle = TextStyle(height: 1.1, fontSize: 10);
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.phone_android, color: AppColors.primary),
//           ),
//           const Gap(8),
//           Text(network, style: textStyle),
//           Text(
//             phoneNumber,
//             style: textStyle.copyWith(
//               fontSize: 8,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
