import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay bills')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              hint: 'Search bills',
              controller: _searchController,
              isRounded: true,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Icon(Icons.search, size: 20),
              ),
            ),
            const Gap(16),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Essentials',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 14,
                    children: [
                      _buildBillItem(
                        'Airtime',
                        const Icon(Icons.phone, size: 20),
                        () => context.pushNamed(AirtimeScreen.path),
                      ),
                      _buildBillItem(
                        'Data',
                        const Icon(Icons.wifi, size: 20),
                        () {},
                      ),
                      _buildBillItem(
                        'Cable TV',
                        const Icon(Icons.tv, size: 20),
                        () {},
                      ),
                      _buildBillItem(
                        'Electricity',
                        const Icon(Icons.bolt, size: 20),
                        () {},
                      ),
                    ],
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
    return CustomCard(
      onTap: onTap,
      borderRadius: 8,
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
