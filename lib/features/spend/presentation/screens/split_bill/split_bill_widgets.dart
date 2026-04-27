import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplitBackButton extends StatelessWidget {
  const SplitBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
    );
  }
}

class SplitAvatarCircle extends StatelessWidget {
  const SplitAvatarCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_outline, size: 18, color: Colors.grey.shade400),
    );
  }
}

class SplitBottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SplitBottomButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: onTap != null
                ? const Color(0xFFFFC107)
                : Colors.grey.shade300,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'GeneralSans',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
