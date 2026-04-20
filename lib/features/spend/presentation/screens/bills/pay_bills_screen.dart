import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/airtime_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/cable_bill_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/internet_bill_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/electricity_bill_screen.dart';

class PayBillsScreen extends StatefulWidget {
  static const String path = '/pay-bills';

  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pay Bills',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick payments',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
            const Gap(20),

            // Quick Payments Grid (2x2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildQuickCard(
                  icon: Icons.phone_iphone,
                  iconColor: const Color(0xFF2196F3),
                  label: 'Airtime',
                  onTap: () => context.pushNamed(AirtimeScreen.path),
                ),
                _buildQuickCard(
                  icon: Icons.wifi,
                  iconColor: const Color(0xFF9C27B0),
                  label: 'Data',
                  onTap: () => context.pushNamed(InternetBillScreen.path),
                ),
                _buildQuickCard(
                  icon: Icons.bolt,
                  iconColor: const Color(0xFFFFC107),
                  label: 'Electricity',
                  onTap: () => context.pushNamed(ElectricityBillScreen.path),
                ),
                _buildQuickCard(
                  icon: Icons.tv,
                  iconColor: const Color(0xFF00BCD4),
                  label: 'TV',
                  onTap: () => context.pushNamed(CableBillScreen.path),
                ),
              ],
            ),

            const Gap(32),

            // Recent Bills Section
            const Text(
              'Recent Bills',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Gap(16),

            _buildRecentBill(
              title: 'MTN Data',
              subtitle: '081234567890',
              amount: '₦2,000',
            ),
            const Gap(12),
            _buildRecentBill(
              title: 'EKEDC',
              subtitle: 'Meter 123456789',
              amount: '₦5,000',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const Gap(12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBill({
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/airtime_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/cable_bill_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/internet_bill_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/electricity_bill_screen.dart';

// class PayBillsScreen extends ConsumerStatefulWidget {
//   static const String path = '/pay-bills';

//   const PayBillsScreen({super.key});

//   @override
//   ConsumerState<PayBillsScreen> createState() => _PayBillsScreenState();
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
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => context.pop(),
//         ),
//         title: const Text(
//           'Pay bills',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'GeneralSans',
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search Bar
//             Container(
//               height: 48,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search bills',
//                   hintStyle: TextStyle(
//                     fontSize: 16,
//                     fontFamily: 'GeneralSans',
//                     color: Colors.grey.shade400,
//                   ),
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: Colors.grey.shade400,
//                     size: 24,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//             ),
//             const Gap(32),

//             // ESSENTIALS Header
//             const Text(
//               'ESSENTIALS',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'GeneralSans',
//                 color: Color(0xFF757575),
//                 letterSpacing: 0.5,
//               ),
//             ),
//             const Gap(16),

//             // Bills List
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildBillItem(
//                     icon: Icons.phone,
//                     iconColor: const Color(0xFFFF9800),
//                     label: 'Airtime',
//                     onTap: () => context.pushNamed(AirtimeScreen.path),
//                   ),
//                   const Gap(12),
//                   _buildBillItem(
//                     icon: Icons.wifi,
//                     iconColor: const Color(0xFFFF5722),
//                     label: 'Internet',
//                     onTap: () => context.pushNamed(InternetBillScreen.path),
//                   ),
//                   const Gap(12),
//                   _buildBillItem(
//                     icon: Icons.tv,
//                     iconColor: const Color(0xFF8BC34A),
//                     label: 'TV',
//                     onTap: () => context.pushNamed(CableBillScreen.path),
//                   ),
//                   const Gap(12),
//                   _buildBillItem(
//                     icon: Icons.bolt,
//                     iconColor: const Color(0xFFFFC107),
//                     label: 'Electricity',
//                     onTap: () => context.pushNamed(ElectricityBillScreen.path),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBillItem({
//     required IconData icon,
//     required Color iconColor,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Row(
//           children: [
//             // Icon
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: iconColor,
//                 size: 24,
//               ),
//             ),
//             const Gap(16),

//             // Label
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.black,
//               ),
//             ),

//             const Spacer(),

//             // Chevron
//             Icon(
//               Icons.chevron_right,
//               color: Colors.grey.shade400,
//               size: 24,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }