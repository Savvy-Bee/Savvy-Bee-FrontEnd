import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class CompleteSetupCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final List<SetupItem> items;

  const CompleteSetupCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMPLETE SETUP ($completedCount/$totalCount)',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.grey.withValues(alpha: 0.3),
                width: 1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == items.length - 1;

                  return Column(
                    children: [
                      _SetupItemTile(item: item, showDivider: !isLast,),
                      if (!isLast) const Gap(16),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupItemTile extends StatelessWidget {
  final SetupItem item;
  final bool showDivider;

  const _SetupItemTile({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      item.icon,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.black,
                ),
              ],
            ),

            // DOTTED LINE (only if not last)
            if (showDivider) const Gap(4),
            if (showDivider) const DottedDivider(),
          ],
        ),
      ),
    );
  }
}

class SetupItem {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  SetupItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class DottedDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double spacing;

  const DottedDivider({
    super.key,
    this.color = Colors.grey,
    this.height = 1,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dotCount = (constraints.maxWidth / spacing).floor();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dotCount, (_) {
              return Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

