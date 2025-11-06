import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';

import '../../../../core/theme/app_colors.dart';

class CopyTextIconButton extends StatelessWidget {
  final String textToCopy;
  const CopyTextIconButton({super.key, required this.textToCopy});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ClipboardData(text: textToCopy);
        CustomSnackbar.show(
          context,
          'Copied to clipboard',
          type: SnackbarType.success,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'COPY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const Gap(5.0),
          Icon(Icons.copy, size: 14, weight: 2, color: AppColors.primary),
        ],
      ),
    );
  }
}
