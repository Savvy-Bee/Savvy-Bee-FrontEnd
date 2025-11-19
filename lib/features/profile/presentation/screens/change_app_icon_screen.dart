import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

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
            spacing: 16,
            runSpacing: 16,
            children: List.generate(Logos.appIcons.length, (index) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double itemWidth = (screenWidth - (16 * 2) - (16 * 2)) / 3;
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
