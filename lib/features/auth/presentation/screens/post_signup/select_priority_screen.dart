import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/financial_architype_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';

enum Priority {
  manageSpending,
  growSavings,
  aiGuidance,
  stickToBudget,
  trackPortfolio,
  notSure;

  static String getText(Priority priority) {
    switch (priority) {
      case Priority.manageSpending:
        return 'Manage my spending';
      case Priority.growSavings:
        return 'Grow my savings';
      case Priority.aiGuidance:
        return 'Get AI-powered guidance';
      case Priority.stickToBudget:
        return 'Stick to my budget';
      case Priority.trackPortfolio:
        return 'Track my portfolio';
      case Priority.notSure:
        return "I'm not sure";
    }
  }

  static String getIcon(Priority priority) {
    switch (priority) {
      case Priority.manageSpending:
        return AppIcons.walletIcon;
      case Priority.growSavings:
        return AppIcons.goalIcon;
      case Priority.aiGuidance:
        return AppIcons.sparklesIcon;
      case Priority.stickToBudget:
        return AppIcons.pieChartIcon;
      case Priority.trackPortfolio:
        return AppIcons.lineChartIcon;
      case Priority.notSure:
        return AppIcons.lifeBuoyIcon;
    }
  }
}

class SelectPriorityScreen extends ConsumerStatefulWidget {
  static String path = '/select-priority';

  const SelectPriorityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectPriorityScreenState();
}

class _SelectPriorityScreenState extends ConsumerState<SelectPriorityScreen> {
  Priority? _priority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(Logos.logo, scale: 4.5),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconTextRowWidget(
              'Skip',
              AppIcon(AppIcons.arrowRightIcon),
              textDirection: TextDirection.rtl,
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
              onTap: () => context.pushNamed(FinancialArchitypeScreen.path),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  IntroText(title: 'Welcome to\nSavvy Bee!'),
                  const Gap(16),
                  Text(
                    'Select what matters to you most right now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.1,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(33),
                  Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(
                      Priority.values.length,
                      (index) => ToggleableListTile(
                        iconPath: Priority.getIcon(Priority.values[index]),
                        text: Priority.getText(Priority.values[index]),
                        isSelected: _priority == Priority.values[index],
                        onTap: () {
                          setState(() {
                            _priority = Priority.values[index];
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Next',
              showArrow: true,
              buttonColor: CustomButtonColor.black,
              onPressed: _priority == null
                  ? null
                  : () {
                      context.pushNamed(
                        FinancialArchitypeScreen.path,
                        extra: Priority.getText(_priority!),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
