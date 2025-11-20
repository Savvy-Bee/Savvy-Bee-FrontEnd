import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';

class ChangeAppIconScreen extends ConsumerStatefulWidget {
  static String path = '/app-icon';

  const ChangeAppIconScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeAppIconScreenState();
}

class _ChangeAppIconScreenState extends ConsumerState<ChangeAppIconScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Icon')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Change App Icon',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            'Tap any image below to change your Savvy Bee App icon',
            style: TextStyle(fontSize: 12),
          ),
          const Gap(24),
          Wrap(
            spacing: 5,
            runSpacing: 8,
            children: List.generate(Logos.appIcons.length, (index) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double itemWidth =
                  (screenWidth - (16 * 2) - (5 * 2)) /
                  3; // Explanation of itemWidth calculation:
              // screenWidth: Total width of the device screen.
              // (16 * 2): Accounts for the left and right padding of the ListView (16 on each side).
              // (5 * 2): Accounts for the total spacing between the three items.
              //            There are two gaps between three items, and each gap is 5 units wide.
              // / 3: Divides the remaining width by 3 to get the width for each item.
              // Calculate item width to fit 3 items per row with spacing

              return Image.asset(
                Logos.appIcons[index],
                width: itemWidth,
                height: itemWidth,
              );
            }),
          ),
        ],
      ),
    );
  }
}
