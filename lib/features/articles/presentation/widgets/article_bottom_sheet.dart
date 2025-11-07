import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/widgets/info_card.dart';

class ArticleBottomSheet extends ConsumerStatefulWidget {
  const ArticleBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ArticleBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      builder: (context) => const ArticleBottomSheet(),
    );
  }
}

class _ArticleBottomSheetState extends ConsumerState<ArticleBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
          bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: Constants.neulisNeueFontFamily,
          ),
        ),
      ),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                iconSize: 20,
                style: Constants.collapsedButtonStyle,
                constraints: const BoxConstraints(),
                onPressed: () => context.pop(),
              ),
              const Gap(16),
              Text(
                'From Savvy Blog',
                style: TextStyle(fontSize: 10, color: AppColors.secondaryLight),
              ),
              const Gap(16),
              Text(
                'Money lessons from afrobeats',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Are you really listening to what they're saying",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'October 27, 2025',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite_outline),
                        iconSize: 20,
                        constraints: const BoxConstraints(),
                        style: Constants.collapsedButtonStyle,
                        onPressed: () => context.pop(),
                      ),
                      const Gap(8),
                      IconButton(
                        icon: Icon(Icons.share),
                        iconSize: 20,
                        constraints: const BoxConstraints(),
                        style: Constants.collapsedButtonStyle,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(16),
              //
              const Gap(16),
              InfoCard(
                title: 'Lesson',
                description:
                    'Work smart, stay consistent, diversify, and when the money comes — enjoy it, but never forget to reinvest.',
                backgroundColor: AppColors.primaryFaint,
                borderColor: AppColors.grey,
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
