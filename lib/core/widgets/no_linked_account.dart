import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// No Account Linked - Empty State Screen
/// Shows when user hasn't connected their bank account
class NoAccountLinkedScreen extends StatelessWidget {
  static const String path = '/no-account-linked';
  
  // Path to your flower image asset
  final String flowerImagePath;
  final VoidCallback? onLinkBankAccountPressed;

  const NoAccountLinkedScreen({
    super.key,
    this.flowerImagePath = 'assets/images/other/sad_flower.png', // Update with actual path
    this.onLinkBankAccountPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Sad Flower Image
              Image.asset(
                flowerImagePath,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const Gap(48),

              // Title
              const Text(
                'Oops, no account linked',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                  color: Colors.black,
                ),
              ),
              const Gap(16),

              // Subtitle
              const Text(
                "We can't calculate your taxes without your transaction data. Connect your bank to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeneralSans',
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Link Bank Account Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onLinkBankAccountPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Link bank account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// REUSABLE EMPTY STATE WIDGET
// ============================================================================

/// Generic empty state widget that can be used anywhere
class EmptyStateWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Image
          Image.asset(
            imagePath,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const Gap(48),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'GeneralSans',
              color: Colors.black,
            ),
          ),
          const Gap(16),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'GeneralSans',
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          const Spacer(),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

// Example 1: No Account Linked (for taxes)
class NoAccountLinkedTaxes extends StatelessWidget {
  const NoAccountLinkedTaxes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: EmptyStateWidget(
          imagePath: 'assets/images/sad_flower.png',
          title: 'Oops, no account linked',
          subtitle: "We can't calculate your taxes without your transaction data. Connect your bank to continue.",
          buttonText: 'Link bank account',
          onButtonPressed: () {
            // Navigate to bank linking
          },
        ),
      ),
    );
  }
}

// Example 2: No Transactions
class NoTransactionsState extends StatelessWidget {
  const NoTransactionsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      imagePath: 'assets/images/sad_flower.png',
      title: 'No transactions yet',
      subtitle: "You don't have any transactions. Make a purchase or link your bank account to get started.",
      buttonText: 'Link bank account',
      onButtonPressed: () {
        // Navigate to bank linking
      },
    );
  }
}

// Example 3: No Budget Set
class NoBudgetState extends StatelessWidget {
  const NoBudgetState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      imagePath: 'assets/images/sad_flower.png',
      title: 'No budget set',
      subtitle: "Create a budget to track your spending and reach your financial goals.",
      buttonText: 'Create budget',
      onButtonPressed: () {
        // Navigate to budget creation
      },
    );
  }
}

// ============================================================================
// CONDITIONAL RENDERING HELPER
// ============================================================================

/// Helper widget that shows empty state when condition is true
class ConditionalEmptyState extends StatelessWidget {
  final bool isEmpty;
  final Widget child;
  final String emptyImagePath;
  final String emptyTitle;
  final String emptySubtitle;
  final String emptyButtonText;
  final VoidCallback onEmptyButtonPressed;

  const ConditionalEmptyState({
    super.key,
    required this.isEmpty,
    required this.child,
    required this.emptyImagePath,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyButtonText,
    required this.onEmptyButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return EmptyStateWidget(
        imagePath: emptyImagePath,
        title: emptyTitle,
        subtitle: emptySubtitle,
        buttonText: emptyButtonText,
        onButtonPressed: onEmptyButtonPressed,
      );
    }

    return child;
  }
}

// Usage:
// ConditionalEmptyState(
//   isEmpty: transactions.isEmpty,
//   emptyImagePath: 'assets/images/sad_flower.png',
//   emptyTitle: 'No transactions yet',
//   emptySubtitle: 'Connect your bank to see your transactions',
//   emptyButtonText: 'Link bank account',
//   onEmptyButtonPressed: () => context.pushNamed('/link-bank'),
//   child: TransactionsList(transactions: transactions),
// )
