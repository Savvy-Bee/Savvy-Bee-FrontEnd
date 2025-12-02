import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';

enum UserArchetype {
  saver,
  spender,
  investor,
  indifferent,
  notSure;

  String get text {
    switch (this) {
      case UserArchetype.saver:
        return 'The saver';
      case UserArchetype.spender:
        return 'The spender';
      case UserArchetype.investor:
        return 'The investor';
      case UserArchetype.indifferent:
        return 'The indifferent';
      case UserArchetype.notSure:
        return "I'm not sure";
    }
  }

  String get icon {
    switch (this) {
      case UserArchetype.saver:
        return AppIcons.goalIcon;
      case UserArchetype.spender:
        return AppIcons.walletIcon;
      case UserArchetype.investor:
        return AppIcons.sparklesIcon;
      case UserArchetype.indifferent:
        return AppIcons.pieChartIcon;
      case UserArchetype.notSure:
        return AppIcons.lifeBuoyIcon;
    }
  }
}

enum FinancialPriority {
  emergencyFund,
  majorPurchase,
  payOffDebt,
  investing,
  retirement,
  other;

  String get text {
    switch (this) {
      case FinancialPriority.emergencyFund:
        return 'Build an emergency fund';
      case FinancialPriority.majorPurchase:
        return 'Saving for a major purchase';
      case FinancialPriority.payOffDebt:
        return 'Paying off debt';
      case FinancialPriority.investing:
        return 'Investing for the future';
      case FinancialPriority.retirement:
        return 'Retirement Planning';
      case FinancialPriority.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case FinancialPriority.emergencyFund:
        return AppIcons.goalIcon;
      case FinancialPriority.majorPurchase:
        return AppIcons.walletIcon;
      case FinancialPriority.payOffDebt:
        return AppIcons.sparklesIcon;
      case FinancialPriority.investing:
        return AppIcons.pieChartIcon;
      case FinancialPriority.retirement:
        return AppIcons.lifeBuoyIcon;
      case FinancialPriority.other:
        return AppIcons.lifeBuoyIcon;
    }
  }
}

enum FinanceManagement {
  budgetConsistently,
  saveWhenPossible,
  paycheckToPaycheck,
  useAutomation,
  other;

  String get text {
    switch (this) {
      case FinanceManagement.budgetConsistently:
        return 'I budget and track expenses consistently.';
      case FinanceManagement.saveWhenPossible:
        return "I save when I can but don't have a system.";
      case FinanceManagement.paycheckToPaycheck:
        return 'I live paycheck to paycheck.';
      case FinanceManagement.useAutomation:
        return 'I use tools to automate savings and investments.';
      case FinanceManagement.other:
        return 'Other';
    }
  }
}

enum ConfusingTopic {
  budgetingAndSavings,
  debtManagement,
  investing,
  earlyStageInvestments,
  homeownership,
  other;

  String get text {
    switch (this) {
      case ConfusingTopic.budgetingAndSavings:
        return 'Budgeting and Savings';
      case ConfusingTopic.debtManagement:
        return 'Debt Management';
      case ConfusingTopic.investing:
        return 'Investing';
      case ConfusingTopic.earlyStageInvestments:
        return 'Early-Stage Investments';
      case ConfusingTopic.homeownership:
        return 'Homeownership';
      case ConfusingTopic.other:
        return 'Other';
    }
  }
}

enum FinancialChallenge {
  impulseSpending,
  procrastination,
  fearAndAnxiety,
  overwhelmed,
  lackOfConsistency,
  none;

  String get text {
    switch (this) {
      case FinancialChallenge.impulseSpending:
        return 'Impulse spending';
      case FinancialChallenge.procrastination:
        return 'Procrastination in saving';
      case FinancialChallenge.fearAndAnxiety:
        return 'Fear or anxiety around money decisions';
      case FinancialChallenge.overwhelmed:
        return 'Overwhelmed by too much financial information';
      case FinancialChallenge.lackOfConsistency:
        return 'Difficulty staying consistent with financial goals';
      case FinancialChallenge.none:
        return 'None of these';
    }
  }
}

enum FinancialMotivation {
  financialIndependence,
  buildWealth,
  gainConfidence,
  reduceStress,
  none;

  String get text {
    switch (this) {
      case FinancialMotivation.financialIndependence:
        return 'Achieving financial independence';
      case FinancialMotivation.buildWealth:
        return 'Building wealth for family/future generations';
      case FinancialMotivation.gainConfidence:
        return 'Gaining confidence in financial decisions';
      case FinancialMotivation.reduceStress:
        return 'Reducing financial stress and anxiety';
      case FinancialMotivation.none:
        return 'None of these';
    }
  }
}
