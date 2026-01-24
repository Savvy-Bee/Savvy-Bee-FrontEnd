import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

import '../utils/constants.dart';

class DialPad extends StatelessWidget {
  const DialPad({
    super.key,
    required this.onNumberPressed,
    required this.onDecimalPressed,
    required this.onDeletePressed,
  });

  final ValueSetter<String> onNumberPressed;
  final VoidCallback onDecimalPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DialPadButton(number: '1', onTap: () => onNumberPressed('1')),
            _DialPadButton(number: '2', onTap: () => onNumberPressed('2')),
            _DialPadButton(number: '3', onTap: () => onNumberPressed('3')),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DialPadButton(number: '4', onTap: () => onNumberPressed('4')),
            _DialPadButton(number: '5', onTap: () => onNumberPressed('5')),
            _DialPadButton(number: '6', onTap: () => onNumberPressed('6')),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DialPadButton(number: '7', onTap: () => onNumberPressed('7')),
            _DialPadButton(number: '8', onTap: () => onNumberPressed('8')),
            _DialPadButton(number: '9', onTap: () => onNumberPressed('9')),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DialPadButton(number: '•', onTap: onDecimalPressed),
            _DialPadButton(number: '0', onTap: () => onNumberPressed('0')),
            TextButton(
              onPressed: onDeletePressed,
              style: Constants.collapsedButtonStyle,
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DialPadButton extends StatelessWidget {
  const _DialPadButton({required this.number, required this.onTap});

  final String number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,

            height: 0.5,
          ),
        ),
      ),
    );
  }
}

class EnterPinBottomSheet extends StatefulWidget {
  final void Function(String) callback;
  const EnterPinBottomSheet({super.key, required this.callback});

  @override
  State<EnterPinBottomSheet> createState() => _EnterPinBottomSheetState();

  static void show(BuildContext context, void Function(String) callback) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => EnterPinBottomSheet(callback: callback),
    );
  }
}

class _EnterPinBottomSheetState extends State<EnterPinBottomSheet> {
  String _pin = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        spacing: 24,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.close),
                style: Constants.collapsedButtonStyle,
              ),
            ],
          ),
          Row(
            spacing: 6,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary, size: 16),
              const Text('Transaction PIN', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _pin.length > index
                      ? AppColors.primary
                      : AppColors.greyMid,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          DialPad(
            onNumberPressed: (number) {
              setState(() => _pin += number);

              if (_pin.length == 4) {
                widget.callback.call(_pin);
                return;
              }
            },
            onDecimalPressed: () {},
            onDeletePressed: () =>
                setState(() => _pin = _pin.substring(0, _pin.length - 1)),
          ),
        ],
      ),
    );
  }
}
