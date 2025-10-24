import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/signup_connect_bank_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/signup_notifications_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_complete.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup/presentation/screens/signup_complete_screen.dart';
import '../../features/auth/presentation/screens/signup/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: SplashScreen.path,
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
  ],
);
