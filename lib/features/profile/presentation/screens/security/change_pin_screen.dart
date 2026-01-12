import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

import '../../../../../core/widgets/dial_pad_widget.dart';
import '../../../../action_completed_screen.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  static const String path = '/change-pin';

  const ChangePinScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  String pin = '';

  bool canProceed = false;

  int pinLength = 6;

  void _updatePin(String newText) {
    if (newText.length <= pinLength) {
      setState(() => pin = newText);
    }
    if (pin.length == pinLength) {
      //
    }
  }

  void _onNumberPressed(String number) {
    if (pin.length < pinLength) _updatePin(pin + number);
  }

  void _onDeletePressed() {
    if (pin.isNotEmpty) _updatePin(pin.substring(0, pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change PIN'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: MiniButton(
              text: 'Next',
              onTap: pin.isEmpty
                  ? null
                  : () => context.pushNamed(
                      ActionCompletedScreen.path,
                      extra: ActionInfo(
                        title: 'Updated!',
                        message:
                            'Your 6-Digit App PIN has been updated successfully.',
                        actionText: 'Okay',
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Change Your PIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Gap(8),
                Text(
                  'Create a PIN for your Savvy Bee app',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                const Gap(24),
                if (canProceed)
                  CustomCard(
                    borderColor: AppColors.grey,
                    borderRadius: 30,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 32,
                    ),
                    child: Row(
                      spacing: 20,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        pinLength,
                        (index) => Icon(
                          Icons.circle,
                          size: 10,
                          color: index < pin.length
                              ? AppColors.black
                              : AppColors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (canProceed)
              DialPad(
                onNumberPressed: (number) => _onNumberPressed(number),
                onDecimalPressed: () {},
                onDeletePressed: _onDeletePressed,
              ),
            if (!canProceed)
              CustomElevatedButton(
                text: 'Create 6-digit PIN',
                onPressed: () {
                  setState(() {
                    canProceed = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
