import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/airtime_screen.dart';

import '../../../../../core/widgets/custom_input_field.dart';

class PayBillsScreen extends ConsumerStatefulWidget {
  static String path = '/pay-bills';

  const PayBillsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends ConsumerState<PayBillsScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay bills')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              hint: 'Search bills',
              controller: _searchController,
              isRounded: true,
              prefix: Icon(Icons.search),
            ),
            const Gap(16),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Essentials',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      4,
                      (index) => _buildBillItem(
                        'Airtime',
                        Icon(Icons.phone, size: 24),
                        () => context.pushNamed(AirtimeScreen.path),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem(String label, Widget icon, VoidCallback onTap) {
    return OutlinedCard(
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

}
