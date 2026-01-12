import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../core/utils/assets/assets.dart';
import '../core/widgets/custom_button.dart';

class ActionInfo {
  final String title;
  final String message;
  final String actionText;

  ActionInfo({
    required this.title,
    required this.message,
    required this.actionText,
  });
}

class ActionCompletedScreen extends ConsumerStatefulWidget {
  static const String path = '/action-completed';

  final ActionInfo actionInfo;

  const ActionCompletedScreen({super.key, required this.actionInfo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActionCompletedScreenState();
}

class _ActionCompletedScreenState extends ConsumerState<ActionCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(Assets.successSvg),
              const Gap(16),
              Text(
                'Updated!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              Text(
                'Your next of kin information has been updated.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomElevatedButton(text: 'Okay', onPressed: () {}),
          ),
        ],
      ),
    );
  }
}
