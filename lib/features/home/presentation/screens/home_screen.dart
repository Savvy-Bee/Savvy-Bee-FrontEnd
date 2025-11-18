import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/dot.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';

import '../../../dashboard/presentation/widgets/info_card.dart';
import '../widgets/health_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static String path = '/home';

  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return homeData.when(
      data: (value) {
        final data = value.data;

        return Scaffold(
          appBar: _buildAppBar(data.firstName),
          body: ListView(
            children: [
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HealthCardWidget(
                  statusText: data.aiData.status,
                  descriptionText: data.aiData.message,
                  rating: data.aiData.ratings.toDouble(),
                  // honeyJarWidget: Image.asset(
                  //   Assets.honeyJar,
                  //   fit: BoxFit.cover,
                  // ),
                  // avatarWidget: Image.asset(
                  //   Illustrations.susuAvatar,
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
              const Gap(24),
              _buildSectionTitle(
                title: 'To-dos',
                actionText: 'Hide',
                actionColor: AppColors.error,
                onactionTap: () {},
              ),
              const Gap(16),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!data.kyc.nin || !data.kyc.bvn)
                      _buildTodoItem(
                        title: 'Verify your identity',
                        iconPath: AppIcons.scanFaceIcon,
                        ctaText: 'VERIFY',
                      ),
                    _buildTodoItem(
                      title: 'Enable FaceID/fingerprint',
                      iconPath: AppIcons.scanFaceIcon,
                      ctaText: 'ENABLE',
                    ),
                  ],
                ),
              ),

              const Gap(24),
              _buildSectionTitle(
                title: 'My tools',
                actionText: 'View all',
                actionColor: AppColors.primary,
                onactionTap: () {},
              ),
              const Gap(16),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToolCard(
                      title: 'My budgets',
                      subtitle:
                          'Create smart budgets, track spending, and get personalized insights.',
                      superscript: 'EDIT BUDGET',
                      color: AppColors.primary,
                    ),
                    _buildToolCard(
                      title: 'My budgets',
                      subtitle:
                          'Create smart budgets, track spending, and get personalized insights.',
                      superscript: 'EDIT BUDGET',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitleWidget(title: 'Explore courses'),
              ),
              const Gap(16),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCourseCard(
                      title: 'Saving 101',
                      subtitle:
                          'Create smart budgets, track spending, and get personalized insights.',
                      color: AppColors.primary,
                    ),
                    _buildCourseCard(
                      title: 'Budgeting Basics',
                      subtitle:
                          'Create smart budgets, track spending, and get personalized insights.',
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitleWidget(title: 'Explore courses'),
              ),
              const Gap(16),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ArticleCard(
                      title: 'Saving 101',
                      subtitle:
                          'Create smart budgets, track spending, and get personalized insights.',
                      backgroundColor: AppColors.primary,
                      imagePath: Illustrations.matchingAndQuizBee,
                      onTap: () {},
                    ),
                    ArticleCard(
                      title: 'Saving 101',
                      subtitle:
                          'Create smart budgets, track spending, and get personalized insights.',
                      backgroundColor: AppColors.success,
                      imagePath: Illustrations.matchingAndQuizBee,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  title: 'Smart Recommendation',
                  description:
                      'Your expenses are high, consider a budget review this week.',
                  avatar: Illustrations.interestBeeAvatar,
                  borderRadius: 32,
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(
        body: const Center(
          child: Text('Unable to load data. Please try again'),
        ),
      ),
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final width = MediaQuery.sizeOf(context).width / 1.9;

    return CustomCard(
      bgColor: color.withValues(alpha: 0.25),
      borderColor: color,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Illustrations.savingsBeePose1,
                height: 140,
                width: 140,
              ),
            ],
          ),
          // const Gap(16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(4),
          Text(subtitle, style: TextStyle(fontSize: 10)),
          const Gap(8),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String subtitle,
    required String superscript, // The little text at the top-right
    required Color color,
  }) {
    final width = MediaQuery.sizeOf(context).width / 1.9;

    return CustomCard(
      bgColor: color.withValues(alpha: 0.25),
      borderColor: color,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  superscript,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // const Gap(16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(4),
          Text(subtitle, style: TextStyle(fontSize: 10)),
          const Gap(8),
        ],
      ),
    );
  }

  Widget _buildTodoItem({
    required String title,
    required String iconPath,
    required String ctaText,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      borderColor: AppColors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          AppIcon(iconPath, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              Text(
                ctaText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String actionText,
    required Color actionColor,
    required VoidCallback onactionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionTitleWidget(
        title: title,
        actionWidget: IconTextRowWidget(
          actionText,
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: Constants.neulisNeueFontFamily,
            color: actionColor,
          ),
          spacing: 0,
          Icon(
            Icons.keyboard_arrow_right_rounded,
            color: actionColor,
            size: 20,
          ),
          textDirection: TextDirection.rtl,
          padding: EdgeInsets.zero,
          onTap: onactionTap,
        ),
      ),
    );
  }

  AppBar _buildAppBar(String firstName) {
    return AppBar(
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hello $firstName',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          Text(
            'Welcome back!',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Dot(size: 35),
        ),
      ],
    );
  }
}
