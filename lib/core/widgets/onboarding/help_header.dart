// lib/widgets/help_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const HelpHeader({
    super.key,
    this.title = 'Where can we help?',
    this.subtitle = 'Choose as many options as you like.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
