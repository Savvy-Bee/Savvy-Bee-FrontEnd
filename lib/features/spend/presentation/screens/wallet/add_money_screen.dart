import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/fund/fund_with_card_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/fund/fund_by_transfer_screen.dart';

import '../fund/username_screen.dart';

class AddMoneyScreen extends ConsumerStatefulWidget {
  static const String path = '/add-money';

  const AddMoneyScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Money')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildActionTile(
            title: 'Share your @username',
            subtitle:
                'Receive money from other Savvy Bee users with your unique username',
            icon: Image.asset(Illustrations.susuAvatar),
            onTap: () => context.pushNamed(UsernameScreen.path),
          ),
          const Gap(8),
          _buildActionTile(
            title: 'Bank transfer',
            subtitle: 'From bank app or internet banking',
            icon: Icon(Icons.send),
            onTap: () => context.pushNamed(FundByTransferScreen.path),
          ),
          const Gap(8),
          _buildActionTile(
            title: 'Card',
            subtitle: 'Add money with a debit card',
            icon: Icon(Icons.credit_card),
            onTap: () => context.pushNamed(FundWithCardScreen.path),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    return OutlinedCard(
      borderRadius: 32,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox.square(dimension: 40, child: icon),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(subtitle, style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.navigate_next),
        ],
      ),
    );
  }
}
