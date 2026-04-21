import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';

class CategoryDetailScreen extends StatelessWidget {
  static const String path = '/spending-flow/category';

  final CategoryInfo category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Back button
                const BackButtonWidget(),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: category.iconBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.label,
                          style: AppTextStyles.displayMedium,
                        ),
                        Text('This month', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Total Spent card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Spent',
                              style: AppTextStyles.labelMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.amount,
                              style: AppTextStyles.amountLarge,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 13,
                                  color: AppColors.entertainmentGreen,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '↓ 4% less than last month',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.entertainmentGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _MiniSparkline(color: category.progressColor),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Weekly Breakdown
                Text('Weekly Breakdown', style: AppTextStyles.headingMedium),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _WeekBar(
                        label: 'This week',
                        amount: '₦6,200',
                        fraction: 0.50,
                        isActive: true,
                        color: category.progressColor,
                      ),
                      const SizedBox(height: 16),
                      _WeekBar(
                        label: 'Last week',
                        amount: '₦9,600',
                        fraction: 0.77,
                        isActive: false,
                        color: category.progressColor,
                      ),
                      const SizedBox(height: 16),
                      _WeekBar(
                        label: '2 weeks ago',
                        amount: '₦12,420',
                        fraction: 1.0,
                        isActive: false,
                        color: category.progressColor,
                      ),
                      const SizedBox(height: 16),
                      _WeekBar(
                        label: '3 weeks ago',
                        amount: '₦7,500',
                        fraction: 0.60,
                        isActive: false,
                        color: category.progressColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Transactions
                Text('Transactions', style: AppTextStyles.headingMedium),
                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _TransactionRow(
                        icon: category.icon,
                        iconBgColor: category.iconBgColor,
                        merchant: 'Transaction 1',
                        date: 'Apr 8 · 2:30 PM',
                        amount: '-₦3,500',
                        showDivider: true,
                      ),
                      _TransactionRow(
                        icon: category.icon,
                        iconBgColor: category.iconBgColor,
                        merchant: 'Transaction 2',
                        date: 'Apr 8 · 1:15 PM',
                        amount: '-₦4,200',
                        showDivider: true,
                      ),
                      _TransactionRow(
                        icon: category.icon,
                        iconBgColor: category.iconBgColor,
                        merchant: 'Transaction 3',
                        date: 'Apr 8 · 6:45 PM',
                        amount: '-₦6,800',
                        showDivider: true,
                      ),
                      _TransactionRow(
                        icon: category.icon,
                        iconBgColor: category.iconBgColor,
                        merchant: 'Transaction 4',
                        date: 'Apr 7 · 12:30 PM',
                        amount: '-₦1,500',
                        showDivider: true,
                      ),
                      _TransactionRow(
                        icon: category.icon,
                        iconBgColor: category.iconBgColor,
                        merchant: 'Transaction 5',
                        date: 'Apr 6 · 7:00 PM',
                        amount: '-₦2,000',
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final Color color;
  const _MiniSparkline({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(70, 40),
      painter: _SparklinePainter(color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  const _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.2),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WeekBar extends StatelessWidget {
  final String label;
  final String amount;
  final double fraction;
  final bool isActive;
  final Color color;

  const _WeekBar({
    required this.label,
    required this.amount,
    required this.fraction,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color:
                  isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LayoutBuilder(
                builder: (ctx, constraints) => Stack(
                  children: [
                    Container(
                      height: 8,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: AppColors.progressBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: constraints.maxWidth * fraction,
                      decoration: BoxDecoration(
                        color: isActive ? color : color.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: AppTextStyles.amountSmall.copyWith(
                  fontSize: 13,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String icon;
  final Color iconBgColor;
  final String merchant;
  final String date;
  final String amount;
  final bool showDivider;

  const _TransactionRow({
    required this.icon,
    required this.iconBgColor,
    required this.merchant,
    required this.date,
    required this.amount,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(merchant, style: AppTextStyles.amountSmall),
                    const SizedBox(height: 2),
                    Text(date, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Text(
                amount,
                style: AppTextStyles.amountSmall.copyWith(
                  color: AppColors.stressRed,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70,
            endIndent: 18,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
