import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

enum SnackbarType { error, success, neutral }

enum SnackbarPosition { top, bottom }

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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(
              switch (type) {
                SnackbarType.error => Icons.error_outline,
                SnackbarType.success => Icons.check_circle_outline,
                SnackbarType.neutral => Icons.info_outline,
              },
              color: switch (type) {
                SnackbarType.error => AppColors.error,
                SnackbarType.success => AppColors.success,
                SnackbarType.neutral => AppColors.warning,
              },
              size: 20,
            ),
          ),
          const Gap(8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (type) {
                    SnackbarType.error => 'An error occurred',
                    SnackbarType.success => 'Operation success',
                    SnackbarType.neutral => text,
                  },
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(fontSize: 12, color: AppColors.black),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            style: Constants.collapsedButtonStyle,
            icon: Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context,
    String text, {
    SnackbarType type = SnackbarType.neutral,
    SnackbarPosition position = SnackbarPosition.top,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Get the total screen height
    final double screenHeight = MediaQuery.sizeOf(context).height;
    // Get the status bar height (top padding)
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    // Estimate the height of your CustomSnackbar (You might need to tweak this)
    const double snackBarHeight = 80.0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackbar(text: text, type: type),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
        dismissDirection: switch (position) {
          SnackbarPosition.top => DismissDirection.up,
          SnackbarPosition.bottom => DismissDirection.down,
        },
        margin: EdgeInsets.only(
          bottom: switch (position) {
            SnackbarPosition.top =>
              (screenHeight / 1.1) - (statusBarHeight + snackBarHeight),
            SnackbarPosition.bottom => 0,
          },
          left: 10,
          right: 10,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
