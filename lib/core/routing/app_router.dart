import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/signup_connect_bank_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/signup_notifications_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spend_dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/add_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/bvn_verification_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/create_wallet_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/live_photo_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/nin_verification_screen.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_complete.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/wallet_creation_complete_screen.dart';
import '../../features/spend/presentation/screens/wallet/photo_verification_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup/presentation/screens/signup_complete_screen.dart';
import '../../features/auth/presentation/screens/signup/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
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
            return DashboardScreen();
          },
        ),
        GoRoute(
          path: SpendScreen.path,
          name: SpendScreen.path,
          builder: (BuildContext context, GoRouterState state) {
            return SpendScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: CreateWalletScreen.path,
      name: CreateWalletScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return CreateWalletScreen();
      },
    ),
    GoRoute(
      path: NinVerificationScreen.path,
      name: NinVerificationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return NinVerificationScreen();
      },
    ),
    GoRoute(
      path: BvnVerificationScreen.path,
      name: BvnVerificationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return BvnVerificationScreen();
      },
    ),
    GoRoute(
      path: PhotoVerificationScreen.path,
      name: PhotoVerificationScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return PhotoVerificationScreen();
      },
    ),
    GoRoute(
      path: LivePhotoScreen.path,
      name: LivePhotoScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return LivePhotoScreen();
      },
    ),
    GoRoute(
      path: WalletCreationCompletionScreen.path,
      name: WalletCreationCompletionScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return WalletCreationCompletionScreen();
      },
    ),
    GoRoute(
      path: AddMoneyScreen.path,
      name: AddMoneyScreen.path,
      builder: (BuildContext context, GoRouterState state) {
        return AddMoneyScreen();
      },
    ),
  ],
);
