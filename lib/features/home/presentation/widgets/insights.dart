import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class InsightsSection extends StatelessWidget {
  final List<LearnCard> cards;

  const InsightsSection({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'INSIGHTS',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Gap(16),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 12,
            children: cards
                .map((card) => _LearnCardWidget(card: card))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _LearnCardWidget extends StatelessWidget {
  final LearnCard card;

  const _LearnCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: card.onTap,
      child: Container(
        width: 238,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(32)),
                child: Image.asset(
                  card.imagePath,
                  width: 230,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    card.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearnCard {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback? onTap;

  LearnCard({
    required this.imagePath,
    required this.title,
    required this.description,
    this.onTap,
  });
}