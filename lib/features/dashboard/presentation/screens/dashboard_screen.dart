import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/connect_bank_security_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/widgets/savings_target_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
import 'package:savvy_bee_mobile/features/articles/presentation/widgets/article_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import '../providers/dashboard_data_provider.dart';
import '../widgets/financial_health_widget.dart';
import '../widgets/spending_category_widget.dart';
import '../widgets/info_card.dart';
import '../widgets/networth_card.dart';

// Main Dashboard Screen
class DashboardScreen extends ConsumerStatefulWidget {
  static const String path = '/dashboard';

  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Fetch dashboard data for all banks
    final dashboardDataAsync = ref.watch(dashboardDataProvider('all'));
    final linkedAccountsAsync = ref.watch(linkedAccountsProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardDataAsync.when(
          skipLoadingOnRefresh: false,
          data: (dashboardData) {
            if (dashboardData == null) {
              return CustomErrorWidget(
                icon: Icons.link_off_rounded,
                title: 'No linked account',
                subtitle: 'Link your account to keep track of your money',
                actionButtonText: 'Link account',
                onActionPressed: () {
                  ConnectBankSecurityBottomSheet.show(context);
                },
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(20),
                    NetWorthCard(dashboardData: dashboardData),
                    const Gap(16),

                    // Smart Recommendation based on actual data
                    if (dashboardData
                        .widgets
                        .spendCategoryBreakdown
                        .alerts
                        .isNotEmpty)
                      InfoCard(
                        title: 'Smart Recommendation',
                        description:
                            dashboardData.widgets.spendCategoryBreakdown.alerts,
                        avatar: Illustrations.interestBeeAvatar,
                        borderRadius: 32,
                      ),

                    const Gap(24),
                    _buildWidgetsSection(context, dashboardData),
                    const Gap(16),

                    InfoCard(
                      title: 'Ask Nahl',
                      description:
                          'Get answers to questions on your spending, saving, budgets and cashflow!',
                      avatar: Illustrations.interestBeeAvatar,
                      borderRadius: 32,
                      onTap: () => context.pushNamed(ChatScreen.path),
                    ),

                    const Divider(height: 40),
                    const Gap(10),
                    _buildArticlesSection(),
                  ],
                ),
              ),
            );
          },
          loading: () =>
              const CustomLoadingWidget(text: 'Loading your dashboard...'),
          error: (error, stack) => CustomErrorWidget(
            icon: Icons.dashboard_outlined,
            title: 'Unable to Load Dashboard',
            subtitle:
                'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
            actionButtonText: 'Retry',
            onActionPressed: () {
              ref.invalidate(dashboardDataProvider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetsSection(
    BuildContext context,
    DashboardData dashboardData,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionTitleWidget(
          title: 'Widgets',
          actionWidget: IconButton(
            onPressed: () {},
            icon: const AppIcon(AppIcons.editIcon),
            constraints: BoxConstraints(),
            style: Constants.collapsedButtonStyle,
          ),
        ),
        const Gap(16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              SpendingCategoryWidget(
                spendingData: dashboardData.widgets.spendCategoryBreakdown,
              ),
              FinancialHealthWidget(
                healthData: dashboardData.widgets.financialHealth,
              ),
              SavingsTargetWidget(
                savingsInsight: dashboardData.widgets.savingTargetInsight,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionTitleWidget(title: 'The latest'),
        const Gap(24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 12.0,
            children: [
              ArticleCard(
                title: 'Should you save financially with your partner?',
                backgroundColor: Colors.amber,
                imagePath: Illustrations.matchingAndQuizBee,
                subtitle: "Let's get financially literate!",
                onTap: () => ArticleBottomSheet.show(context),
              ),
              ArticleCard(
                title: 'Money lessons from afrobeats',
                backgroundColor: const Color(0xFFB8E986),
                imagePath: Illustrations.loanBee,
                subtitle: 'Are you really listening to what they\'re saying?',
                onTap: () => ArticleBottomSheet.show(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
