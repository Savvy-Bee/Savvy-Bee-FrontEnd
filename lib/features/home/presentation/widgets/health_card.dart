import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';

/// A financial health status card featuring a custom-painted background
/// with a dedicated notch for the avatar icon.
class HealthCardWidget extends StatelessWidget {
  final String statusText;
  final String descriptionText;
  final double rating;

  const HealthCardWidget({
    super.key,
    required this.statusText,
    required this.descriptionText,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final width = size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(Assets.financialHealthCanvas, width: width),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Constant Text
                const Text(
                  "Your financial health is",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Gap(10),

                // Honey Jar
                Image.asset(
                  _getHoneyJarImage(rating),
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
                const Gap(10),

                // Status Text
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),

                // Description Text
                Text(
                  descriptionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Avatar
        Positioned(
          left: 35,
          bottom: -10,
          child: Image.asset(
            _getAvatarImage(rating),
            width: 110,
            height: 110,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  String _getAvatarImage(double rating) {
    if (rating > 0 && rating <= 20) {
      return Illustrations.financialHealth1;
    } else if (rating > 20 && rating <= 40) {
      return Illustrations.financialHealth2;
    } else if (rating > 40 && rating <= 60) {
      return Illustrations.financialHealth3;
    } else if (rating > 60 && rating <= 80) {
      return Illustrations.financialHealth4;
    } else {
      return Illustrations
          .financialHealth5; // Covers 80-100 and any other cases
    }
  }

  String _getHoneyJarImage(double rating) {
    if (rating > 0 && rating <= 20) {
      return Assets.honeyJar1;
    } else if (rating > 20 && rating <= 40) {
      return Assets.honeyJar2;
    } else if (rating > 40 && rating <= 60) {
      return Assets.honeyJar3;
    } else if (rating > 60 && rating <= 80) {
      return Assets.honeyJar4;
    } else {
      return Assets.honeyJar5; // Covers 80-100 and any other cases
    }
  }
}
