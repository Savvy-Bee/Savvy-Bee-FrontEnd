import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

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
            icon: SizedBox.square(
              dimension: 40,
              child: Image.asset(Illustrations.susuAvatar),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required Widget icon,
  }) {
    return OutlinedCard(
      borderRadius: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                widget,
                const Gap(16),
                Column(
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
              ],
            ),
          ),
          const Icon(Icons.navigate_next),
        ],
      ),
    );
  }
}
