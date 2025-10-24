import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

enum SnackbarType { error, success, neutral }

class CustomSnackbar extends StatelessWidget {
  final String text;
  final SnackbarType type;
  const CustomSnackbar({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: type == SnackbarType.error
            ? Colors.red.shade50
            : type == SnackbarType.success
            ? Colors.green.shade50
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: type == SnackbarType.error
              ? Colors.red.shade200
              : type == SnackbarType.success
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            type == SnackbarType.error
                ? Icons.error_outline
                : type == SnackbarType.success
                ? Icons.check_circle_outline
                : Icons.info_outline,
            color: type == SnackbarType.error
                ? Colors.red.shade700
                : type == SnackbarType.success
                ? Colors.green.shade700
                : Colors.grey.shade700,
            size: 20,
          ),
          const Gap(8.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: type == SnackbarType.error
                    ? Colors.red.shade700
                    : type == SnackbarType.success
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context,
    String text, {
    SnackbarType type = SnackbarType.neutral,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackbar(text: text, type: type),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
