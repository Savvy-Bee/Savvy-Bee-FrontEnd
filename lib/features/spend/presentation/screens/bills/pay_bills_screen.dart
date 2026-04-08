import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/airtime_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/cable_bill_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/internet_bill_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/electricity_bill_screen.dart';

class PayBillsScreen extends ConsumerStatefulWidget {
  static const String path = '/pay-bills';

  const PayBillsScreen({super.key});

  @override
  ConsumerState<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends ConsumerState<PayBillsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pay bills',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'GeneralSans',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search bills',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'GeneralSans',
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const Gap(32),

            // ESSENTIALS Header
            const Text(
              'ESSENTIALS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Color(0xFF757575),
                letterSpacing: 0.5,
              ),
            ),
            const Gap(16),

            // Bills List
            Expanded(
              child: ListView(
                children: [
                  _buildBillItem(
                    icon: Icons.phone,
                    iconColor: const Color(0xFFFF9800),
                    label: 'Airtime',
                    onTap: () => context.pushNamed(AirtimeScreen.path),
                  ),
                  const Gap(12),
                  _buildBillItem(
                    icon: Icons.wifi,
                    iconColor: const Color(0xFFFF5722),
                    label: 'Internet',
                    onTap: () => context.pushNamed(InternetBillScreen.path),
                  ),
                  const Gap(12),
                  _buildBillItem(
                    icon: Icons.tv,
                    iconColor: const Color(0xFF8BC34A),
                    label: 'TV',
                    onTap: () => context.pushNamed(CableBillScreen.path),
                  ),
                  const Gap(12),
                  _buildBillItem(
                    icon: Icons.bolt,
                    iconColor: const Color(0xFFFFC107),
                    label: 'Electricity',
                    onTap: () => context.pushNamed(ElectricityBillScreen.path),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const Gap(16),

            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),

            const Spacer(),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/airtime_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/cable_bill_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/internet_bill_screen.dart';

// import '../../../../../core/widgets/custom_input_field.dart';
// import 'electricity_bill_screen.dart';

// class PayBillsScreen extends ConsumerStatefulWidget {
//   static const String path = '/pay-bills';

//   const PayBillsScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _PayBillsScreenState();
// }

// class _PayBillsScreenState extends ConsumerState<PayBillsScreen> {
//   final _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pay bills')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomTextFormField(
//               hint: 'Search bills',
//               controller: _searchController,
//               isRounded: true,
//               prefixIcon: const Padding(
//                 padding: EdgeInsets.only(left: 12.0),
//                 child: Icon(Icons.search, size: 20),
//               ),
//             ),
//             const Gap(16),
//             Expanded(
//               child: ListView(
//                 children: [
//                   const Text(
//                     'Essentials',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const Gap(16),
//                   GridView.count(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisCount: 4,
//                     mainAxisSpacing: 16,
//                     crossAxisSpacing: 14,
//                     children: [
//                       _buildBillItem(
//                         'Airtime',
//                         const Icon(Icons.phone, size: 20),
//                         () => context.pushNamed(AirtimeScreen.path),
//                       ),
//                       _buildBillItem(
//                         'Data',
//                         const Icon(Icons.wifi, size: 20),
//                         () => context.pushNamed(InternetBillScreen.path),
//                       ),
//                       _buildBillItem(
//                         'Cable TV',
//                         const Icon(Icons.tv, size: 20),
//                         () => context.pushNamed(CableBillScreen.path),
//                       ),
//                       _buildBillItem(
//                         'Electricity',
//                         const Icon(Icons.bolt, size: 20),
//                         () => context.pushNamed(ElectricityBillScreen.path),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBillItem(String label, Widget icon, VoidCallback onTap) {
//     return CustomCard(
//       onTap: onTap,
//       borderRadius: 8,
//       padding: const EdgeInsets.all(5),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           icon,
//           const Gap(4),
//           Text(
//             label,
//             style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }
