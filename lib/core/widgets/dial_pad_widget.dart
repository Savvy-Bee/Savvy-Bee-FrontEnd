import 'package:flutter/material.dart';

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
            fontFamily: Constants.neulisNeueFontFamily,
            height: 0.5,
          ),
        ),
      ),
    );
  }
}
