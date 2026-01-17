import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/financial_architype_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/referrer_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/select_priority_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/signup_connect_bank_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/signup_notifications_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/games/game_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/hive_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/leaderboard/league_promotion_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/leaderboard/league_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/leaderboard/weekly_position_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/lesson/lesson_unlocked_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/lesson/lesson_home_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/level/quest_reward_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/level/quest_update_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/quiz/quiz_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/streak/new_streak_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/streak/streak_dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:savvy_bee_mobile/features/premium/presentation/screens/premium_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/account_info_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/achievements_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/change_app_icon_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/choose_avatar_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/complete_profile_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/contact_us_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/financial_health_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/library_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/manage_subscription_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/next_of_kin_screen.dart';
import 'package:savvy_bee_mobile/features/action_completed_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/security/change_password_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/security/change_pin_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/security/security_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/settings_screen.dart';
import 'package:savvy_bee_mobile/features/referral/presentation/screens/referral_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/airtime_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_completion_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/internet_bill_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/pay_bills_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/fund/fund_with_card_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/fund/new_card_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/fund/fund_by_transfer_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spend_dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/account_statement_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_history_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/send_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/add_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/bvn_verification_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/create_wallet_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/live_photo_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/nin_verification_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/password_reset/password_reset_complete.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/password_reset/password_reset_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/wallet_creation_complete_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/edit_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_income_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_repayment_details_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/tools_screen.dart';
import '../../features/hive/presentation/screens/lesson/lesson_room_screen.dart';
import '../../features/hive/presentation/screens/level/level_complete_screen.dart';
import '../../features/hive/presentation/screens/levels_screen.dart';
import '../../features/spend/presentation/screens/bills/cable_bill_screen.dart';
import '../../features/spend/presentation/screens/bills/electricity_bill_screen.dart';
import '../../features/spend/presentation/screens/fund/username_screen.dart';
import '../../features/spend/presentation/screens/transactions/statement_sent_screen.dart';
import '../../features/spend/presentation/screens/transfer/transfer_screen.dart';
import '../../features/spend/presentation/screens/wallet/photo_verification_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/post_signup/signup_complete_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/taxation/calculate_tax_screen.dart';
import '../../features/taxation/taxation_dashboard_screen.dart';
import '../../features/tools/presentation/screens/debt/add_debt_screen.dart';
import '../../features/tools/presentation/screens/debt/debt_screen.dart';
import '../../features/tools/presentation/screens/goals/goals_screen.dart';
import '../widgets/main_wrapper.dart';

// Keys for navigating to specific tabs within MainWrapper
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: CalculateTaxScreen.path,
  routes: [
    GoRoute(
      path: SplashScreen.path,
      name: SplashScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: OnboardingScreen.path,
      name: OnboardingScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: LoginScreen.path,
      name: LoginScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: PasswordResetScreen.path,
      name: PasswordResetScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const PasswordResetScreen();
      },
    ),
    GoRoute(
      path: PasswordResetComplete.path,
      name: PasswordResetComplete.path,
      builder: (BuildContext context, GoRouterState state) {
        return const PasswordResetComplete();
      },
    ),
    GoRoute(
      path: SignupScreen.path,
      name: SignupScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return SignupScreen(
          incompleteSignUpData: state.extra as IncompleteSignUpData?,
        );
      },
    ),
    GoRoute(
      path: SignupCompleteScreen.path,
      name: SignupCompleteScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return SignupCompleteScreen(
          type:
              state.extra as SignupCompleteScreenType? ??
              SignupCompleteScreenType.signup,
        );
      },
    ),
    GoRoute(
      path: ReferrerScreen.path,
      name: ReferrerScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const ReferrerScreen();
      },
    ),
    GoRoute(
      path: SignupNotificationsScreen.path,
      name: SignupNotificationsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const SignupNotificationsScreen();
      },
    ),
    GoRoute(
      path: SignupConnectBankScreen.path,
      name: SignupConnectBankScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const SignupConnectBankScreen();
      },
    ),
    GoRoute(
      path: SelectPriorityScreen.path,
      name: SelectPriorityScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const SelectPriorityScreen();
      },
    ),
    GoRoute(
      path: ChatScreen.path,
      name: ChatScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const ChatScreen();
      },
    ),
    GoRoute(
      path: FinancialArchitypeScreen.path,
      name: FinancialArchitypeScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return FinancialArchitypeScreen(priority: state.extra as String?);
      },
    ),
    GoRoute(
      path: ChoosePersonalityScreen.path,
      name: ChoosePersonalityScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ChoosePersonalityScreen(
          isFromSignup: state.extra as bool? ?? false,
        );
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainWrapper(child: child);
      },
      routes: [
        GoRoute(
          path: HomeScreen.path,
          name: HomeScreen.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: Duration(milliseconds: 100),
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          },
        ),
        GoRoute(
          path: DashboardScreen.path,
          name: DashboardScreen.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: Duration(milliseconds: 100),
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          },
        ),
        GoRoute(
          path: SpendScreen.path,
          name: SpendScreen.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: Duration(milliseconds: 100),
              child: const SpendScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          },
        ),
        GoRoute(
          path: ToolsScreen.path,
          name: ToolsScreen.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: Duration(milliseconds: 100),
              child: ToolsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          },
        ),
        GoRoute(
          path: HiveScreen.path,
          name: HiveScreen.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: Duration(milliseconds: 100),
              child: HiveScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          },
        ),
      ],
    ),

    // Wallet Routes
    GoRoute(
      path: CreateWalletScreen.path,
      name: CreateWalletScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const CreateWalletScreen();
      },
    ),
    GoRoute(
      path: NinVerificationScreen.path,
      name: NinVerificationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const NinVerificationScreen();
      },
    ),
    GoRoute(
      path: BvnVerificationScreen.path,
      name: BvnVerificationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return BvnVerificationScreen(data: state.extra as Map<String, dynamic>);
      },
    ),
    GoRoute(
      path: PhotoVerificationScreen.path,
      name: PhotoVerificationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const PhotoVerificationScreen();
      },
    ),
    GoRoute(
      path: LivePhotoScreen.path,
      name: LivePhotoScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LivePhotoScreen(data: state.extra as Map<String, dynamic>);
      },
    ),
    // GoRoute(
    //   path: WalletCreationCompletionScreen.path,
    //   name: WalletCreationCompletionScreen.path,
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const WalletCreationCompletionScreen();
    //   },
    // ),

    // Fund Wallet Routes
    GoRoute(
      path: AddMoneyScreen.path,
      name: AddMoneyScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const AddMoneyScreen();
      },
    ),
    GoRoute(
      path: UsernameScreen.path,
      name: UsernameScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const UsernameScreen();
      },
    ),
    GoRoute(
      path: FundByTransferScreen.path,
      name: FundByTransferScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const FundByTransferScreen();
      },
    ),
    GoRoute(
      path: FundWithCardScreen.path,
      name: FundWithCardScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const FundWithCardScreen();
      },
    ),
    GoRoute(
      path: NewCardScreen.path,
      name: NewCardScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const NewCardScreen();
      },
    ),
    GoRoute(
      path: PayBillsScreen.path,
      name: PayBillsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const PayBillsScreen();
      },
    ),
    GoRoute(
      path: AirtimeScreen.path,
      name: AirtimeScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const AirtimeScreen();
      },
    ),
    GoRoute(
      path: InternetBillScreen.path,
      name: InternetBillScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const InternetBillScreen();
      },
    ),
    GoRoute(
      path: CableBillScreen.path,
      name: CableBillScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const CableBillScreen();
      },
    ),
    GoRoute(
      path: ElectricityBillScreen.path,
      name: ElectricityBillScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const ElectricityBillScreen();
      },
    ),
    GoRoute(
      path: BillConfirmationScreen.path,
      name: BillConfirmationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return BillConfirmationScreen(
          confirmationData: state.extra as BillConfirmationData,
        );
      },
    ),
    GoRoute(
      path: BillCompletionScreen.path,
      name: BillCompletionScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const BillCompletionScreen();
      },
    ),

    // Transfer Routes
    GoRoute(
      path: TransferScreen.path,
      name: TransferScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const TransferScreen();
      },
    ),
    GoRoute(
      path: SendMoneyScreen.path,
      name: SendMoneyScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return SendMoneyScreen(
          recipientAccountInfo: state.extra as RecipientAccountInfo,
        );
      },
    ),
    GoRoute(
      path: TransactionHistoryScreen.path,
      name: TransactionHistoryScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return TransactionHistoryScreen();
      },
    ),
    GoRoute(
      path: AccountStatementScreen.path,
      name: AccountStatementScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return AccountStatementScreen();
      },
    ),
    // GoRoute(
    //   path: StatementSentScreen.path,
    //   name: StatementSentScreen.path,
    //   builder: (BuildContext context, GoRouterState state) {
    //     return StatementSentScreen();
    //   },
    // ),

    // Tools Routes
    GoRoute(
      path: BudgetScreen.path,
      name: BudgetScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return BudgetScreen();
      },
    ),
    GoRoute(
      path: EditBudgetScreen.path,
      name: EditBudgetScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return EditBudgetScreen();
      },
    ),
    GoRoute(
      path: SetIncomeScreen.path,
      name: SetIncomeScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return SetIncomeScreen();
      },
    ),
    GoRoute(
      path: SetBudgetScreen.path,
      name: SetBudgetScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return SetBudgetScreen();
      },
    ),
    GoRoute(
      path: GoalsScreen.path,
      name: GoalsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return GoalsScreen();
      },
    ),
    GoRoute(
      path: CreateGoalScreen.path,
      name: CreateGoalScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return CreateGoalScreen();
      },
    ),
    GoRoute(
      path: DebtScreen.path,
      name: DebtScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return DebtScreen();
      },
    ),
    GoRoute(
      path: AddDebtScreen.path,
      name: AddDebtScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return AddDebtScreen();
      },
    ),
    GoRoute(
      path: DebtRepaymentDetailsScreen.path,
      name: DebtRepaymentDetailsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return DebtRepaymentDetailsScreen(debtId: state.extra as String);
      },
    ),

    // Taxation Routes
    GoRoute(
      path: TaxationDashboardScreen.path,
      name: TaxationDashboardScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const TaxationDashboardScreen();
      },
    ),
    GoRoute(
      path: CalculateTaxScreen.path,
      name: CalculateTaxScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const CalculateTaxScreen();
      },
    ),

    // Hive Routes
    GoRoute(
      path: LessonHomeScreen.path,
      name: LessonHomeScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LessonHomeScreen(course: state.extra as Course);
      },
    ),
    GoRoute(
      path: LevelsScreen.path,
      name: LevelsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LevelsScreen(lesson: state.extra as Lesson);
      },
    ),
    GoRoute(
      path: LessonRoomScreen.path,
      name: LessonRoomScreen.path,
      builder: (context, state) {
        final args = state.extra as LessonRoomArgs;

        return LessonRoomScreen(args: args);
      },
    ),
    GoRoute(
      path: QuizScreen.path,
      name: QuizScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return QuizScreen(quizData: state.extra as QuizData);
      },
    ),
    GoRoute(
      path: LevelCompleteScreen.path,
      name: LevelCompleteScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LevelCompleteScreen(args: state.extra as LevelCompleteArgs);
      },
    ),

    GoRoute(
      path: LessonUnlockedScreen.path,
      name: LessonUnlockedScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const LessonUnlockedScreen();
      },
    ),
    GoRoute(
      path: QuestRewardScreen.path,
      name: QuestRewardScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const QuestRewardScreen();
      },
    ),
    GoRoute(
      path: QuestUpdateScreen.path,
      name: QuestUpdateScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const QuestUpdateScreen();
      },
    ),

    // Streak Routes
    GoRoute(
      path: StreakDashboardScreen.path,
      name: StreakDashboardScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return StreakDashboardScreen();
      },
    ),
    GoRoute(
      path: NewStreakScreen.path,
      name: NewStreakScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return NewStreakScreen();
      },
    ),

    // Leaderboard Routes
    GoRoute(
      path: LeaderboardScreen.path,
      name: LeaderboardScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LeaderboardScreen();
      },
    ),
    GoRoute(
      path: LeagueScreen.path,
      name: LeagueScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LeagueScreen();
      },
    ),
    GoRoute(
      path: WeeklyPositionScreen.path,
      name: WeeklyPositionScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return WeeklyPositionScreen();
      },
    ),
    GoRoute(
      path: LeaguePromotionScreen.path,
      name: LeaguePromotionScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LeaguePromotionScreen();
      },
    ),

    // Premium Routes
    GoRoute(
      path: PremiumScreen.path,
      name: PremiumScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return PremiumScreen(isFromSignup: state.extra as bool? ?? false);
      },
    ),
    GoRoute(
      path: ReferralScreen.path,
      name: ReferralScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ReferralScreen();
      },
    ),

    // Profile Routes
    GoRoute(
      path: ProfileScreen.path,
      name: ProfileScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ProfileScreen();
      },
    ),
    GoRoute(
      path: ChooseAvatarScreen.path,
      name: ChooseAvatarScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ChooseAvatarScreen();
      },
    ),
    GoRoute(
      path: AchievementsScreen.path,
      name: AchievementsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return AchievementsScreen();
      },
    ),
    GoRoute(
      path: CompleteProfileScreen.path,
      name: CompleteProfileScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return CompleteProfileScreen();
      },
    ),
    GoRoute(
      path: FinancialHealthScreen.path,
      name: FinancialHealthScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return FinancialHealthScreen();
      },
    ),
    GoRoute(
      path: NextOfKinScreen.path,
      name: NextOfKinScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return NextOfKinScreen();
      },
    ),
    GoRoute(
      path: ActionCompletedScreen.path,
      name: ActionCompletedScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ActionCompletedScreen(actionInfo: state.extra as ActionInfo);
      },
    ),
    GoRoute(
      path: LibraryScreen.path,
      name: LibraryScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LibraryScreen();
      },
    ),
    GoRoute(
      path: ChangeAppIconScreen.path,
      name: ChangeAppIconScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ChangeAppIconScreen();
      },
    ),
    GoRoute(
      path: ContactUsScreen.path,
      name: ContactUsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ContactUsScreen();
      },
    ),
    GoRoute(
      path: AccountInfoScreen.path,
      name: AccountInfoScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return AccountInfoScreen();
      },
    ),
    GoRoute(
      path: ManageSubscriptionScreen.path,
      name: ManageSubscriptionScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ManageSubscriptionScreen();
      },
    ),

    // Security Routes
    GoRoute(
      path: SecurityScreen.path,
      name: SecurityScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return SecurityScreen();
      },
    ),
    GoRoute(
      path: ChangePinScreen.path,
      name: ChangePinScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ChangePinScreen();
      },
    ),
    GoRoute(
      path: ChangePasswordScreen.path,
      name: ChangePasswordScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return ChangePasswordScreen();
      },
    ),

    // Settings Routes
    GoRoute(
      path: SettingsScreen.path,
      name: SettingsScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return SettingsScreen();
      },
    ),

    // Game Routes
    GoRoute(
      path: GameScreen.path,
      name: GameScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return GameScreen();
      },
    ),
  ],
);
