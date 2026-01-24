import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

import '../../../../core/widgets/custom_card.dart';

class LessonCard extends StatelessWidget {
  final String superscript; // The text above all other content
  final String? title;
  final List<String> enumeratedItems;
  final String? bodyText;
  final String? image;
  final bool isHighlight;

  const LessonCard({
    super.key,
    required this.superscript,
    this.title,
    this.enumeratedItems = const [],
    this.bodyText,
    this.image,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: Offset(0, 4),
                  color: AppColors.black.withValues(alpha: 0.15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSuperscript(),
                const Gap(16),
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                      height: 1.1,
                    ),
                  ),
                  const Gap(16),
                ],
                if (bodyText != null && bodyText!.isNotEmpty) ...[
                  Text(
                    bodyText!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Gap(16),
                ],
                if (enumeratedItems.isNotEmpty) ...[
                  Column(
                    spacing: 16,
                    children: List.generate(
                      enumeratedItems.length,
                      (index) => _buildEnumeratedItem(
                        index + 1,
                        enumeratedItems[index],
                      ),
                    ),
                  ),
                  const Gap(16),
                ],
                if (image != null && image!.isNotEmpty)
                  SizedBox(
                    height: 200,
                    width: double.maxFinite,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(image!, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildEnumeratedItem(int index, String text) {
    return Row(
      spacing: 16,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(index.toString()),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              // fontSize: 16,
              fontWeight: FontWeight.w500,

              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuperscript() {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      bgColor: isHighlight ? AppColors.primaryFaint : AppColors.primary,
      borderRadius: 16,
      borderWidth: isHighlight ? null : 0,
      borderColor: isHighlight ? AppColors.primary : Colors.transparent,
      child: Text(
        superscript,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
