import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

import '../utils/string_extensions.dart';

class PasswordRequirementItem extends StatelessWidget {
  final String label;
  final bool isValid;
  final String password;

  const PasswordRequirementItem({
    super.key,
    required this.label,
    this.isValid = false,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (password.isEmpty)
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: const Text('●', style: TextStyle(fontSize: 8)),
            ),
          if (isValid)
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
          if (password.isNotEmpty && !isValid)
            Icon(Icons.cancel, color: AppColors.error, size: 20),
          const Gap(10.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.0,
              color: isValid
                  ? AppColors.success
                  : password.isNotEmpty && !isValid
                  ? AppColors.error
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordRequirementWidget extends StatelessWidget {
  final String password;

  const PasswordRequirementWidget({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        PasswordRequirementItem(
          label: '1 Uppercase letter',
          isValid: password.hasUppercase,
          password: password,
        ),
        PasswordRequirementItem(
          label: '1 Lowercase letter',
          isValid: password.hasLowercase,
          password: password,
        ),
        PasswordRequirementItem(
          label: '1 Number',
          isValid: password.hasNumber,
          password: password,
        ),
        PasswordRequirementItem(
          label: '1 Special character',
          isValid: password.hasSpecialCharacter,
          password: password,
        ),
        PasswordRequirementItem(
          label: '8 to 64 characters',
          isValid: password.isAtLeastEightChars,
          password: password,
        ),
      ],
    );
  }
}
