import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/assets/assets.dart';
import '../../../../core/widgets/custom_button.dart';

class NextOfKinUpdatedScreen extends ConsumerStatefulWidget {
  static String path = '/nok-updated';

  const NextOfKinUpdatedScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NextOfKinUpdatedScreenState();
}

class _NextOfKinUpdatedScreenState
    extends ConsumerState<NextOfKinUpdatedScreen> {
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
