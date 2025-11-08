import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/signup_connect_bank_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/signup_notifications_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/airtime_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_completion_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_confirmation_screen.dart';
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
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_complete.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/wallet_creation_complete_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/edit_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_income_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_repayment_details_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/tools_screen.dart';
import '../../features/spend/presentation/screens/fund/username_screen.dart';
import '../../features/spend/presentation/screens/transactions/statement_sent_screen.dart';
import '../../features/spend/presentation/screens/transfer/transfer_screen.dart';
import '../../features/spend/presentation/screens/wallet/photo_verification_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup/presentation/screens/signup_complete_screen.dart';
import '../../features/auth/presentation/screens/signup/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
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
  initialLocation: DashboardScreen.path,
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
        return const SignupScreen();
      },
    ),
    GoRoute(
      path: SignupCompleteScreen.path,
      name: SignupCompleteScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const SignupCompleteScreen();
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
      path: HomeScreen.path,
      name: HomeScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
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
      path: ChoosePersonalityScreen.path,
      name: ChoosePersonalityScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const ChoosePersonalityScreen();
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainWrapper(child: child);
      },
      routes: [
        GoRoute(
          path: DashboardScreen.path,
          name: DashboardScreen.path,
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: SpendScreen.path,
          name: SpendScreen.path,
          builder: (BuildContext context, GoRouterState state) {
            return const SpendScreen();
          },
        ),
        GoRoute(
          path: ToolsScreen.path,
          name: ToolsScreen.path,
          builder: (BuildContext context, GoRouterState state) {
            return ToolsScreen();
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
        return const BvnVerificationScreen();
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
        return const LivePhotoScreen();
      },
    ),
    GoRoute(
      path: WalletCreationCompletionScreen.path,
      name: WalletCreationCompletionScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const WalletCreationCompletionScreen();
      },
    ),

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
      path: BillConfirmationScreen.path,
      name: BillConfirmationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return const BillConfirmationScreen();
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
        return SendMoneyScreen(recipientName: state.extra as String);
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
    GoRoute(
      path: StatementSentScreen.path,
      name: StatementSentScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return StatementSentScreen();
      },
    ),

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
        return DebtRepaymentDetailsScreen();
      },
    ),
  ],
);
