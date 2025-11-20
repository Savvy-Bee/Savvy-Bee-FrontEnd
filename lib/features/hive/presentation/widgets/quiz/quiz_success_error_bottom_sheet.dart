import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class QuizSuccessErrorBottomSheet extends StatelessWidget {
  // Define custom colors for the two states
  static const Color accentError = Color(0xFFF05151);
  static const Color lightErrorBackground = Color(0xFFFDE8E7);
  static const Color accentSuccess = Color(0xFF51A051); // New green color
  static const Color lightSuccessBackground = Color(
    0xFFE7FDE7,
  ); // New light green background

  final bool isSuccess;
  final VoidCallback onButtonPressed;

  const QuizSuccessErrorBottomSheet({
    super.key,
    required this.isSuccess,
    required this.onButtonPressed,
  });

  // --- Static method to display the custom bottom sheet ---
  static void show({
    required BuildContext context,
    required bool isSuccess,
    required VoidCallback onButtonPressed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return QuizSuccessErrorBottomSheet(
          isSuccess: isSuccess,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors and content based on the success state
    final Color accentColor = isSuccess ? accentSuccess : accentError;
    final Color backgroundColor = isSuccess
        ? lightSuccessBackground
        : lightErrorBackground;
    final String title = isSuccess ? 'Excellent!!' : 'Ooops!';
    final String message = isSuccess
        ? 'You got it right.'
        : 'You got it wrong.';
    final String buttonText = isSuccess ? 'Continue' : 'Try again';
    final IconData icon = isSuccess
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return PopScope(
      canPop: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Positioned(
            bottom: isSuccess ? 140 : 165,
            child: Image.asset(
              isSuccess
                  ? Illustrations.quizBeeRight
                  : Illustrations.quizBeeWrong,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(top: BorderSide(color: accentColor, width: 4.0)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The status icon
                    Icon(icon, color: accentColor, size: 28),
                    const Gap(4),
                    // The main titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.neulisNeueFontFamily,
                              color: accentColor,
                              height: 1.0,
                            ),
                          ),
                          if (!isSuccess) const Gap(4),
                          if (!isSuccess)
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: Constants.neulisNeueFontFamily,
                                color: accentColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                CustomElevatedButton(
                  text: buttonText,
                  onPressed: onButtonPressed,
                  buttonColor: isSuccess
                      ? CustomButtonColor.green
                      : CustomButtonColor.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
