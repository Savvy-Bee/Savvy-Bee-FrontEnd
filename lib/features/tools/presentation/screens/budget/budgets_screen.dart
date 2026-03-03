import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/budget_category_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/edit_budget_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/spending_screen.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_income_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/tools_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Walkthrough step for the Budgets screen
// ─────────────────────────────────────────────────────────────────────────────
enum _BudgetWalkthroughStep {
  /// Arrow pointing at Monthly Income row
  income,

  /// Arrow pointing at Monthly Budget row
  budget,

  /// Walkthrough complete – nothing shown
  done,
}

// Persistent key so the guidance never re-appears once dismissed
const _kBudgetWalkthroughKey = 'budget_walkthrough_completed';

// ─────────────────────────────────────────────────────────────────────────────
// BudgetsScreen
// ─────────────────────────────────────────────────────────────────────────────

class BudgetsScreen extends ConsumerStatefulWidget {
  static const String path = '/budgets';

  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  // ── Month selector ────────────────────────────────────────────────────────
  int _selectedMonthIndex = DateTime.now().month - 1;

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _getCategoryIconPath(String categoryName) {
    final name = categoryName.trim().toLowerCase();

    switch (name) {
      case 'auto & transport':
        return 'assets/images/icons/budget categories/Auto & Transport.png';
      case 'childcare & education':
        return 'assets/images/icons/budget categories/Childcare & Education.png';
      case 'drinks & dining':
        return 'assets/images/icons/budget categories/Drinks & Dining.png';
      case 'entertainment':
        return 'assets/images/icons/budget categories/Entertainment.png';
      case 'financial':
        return 'assets/images/icons/budget categories/Financial.png';
      case 'groceries':
        return 'assets/images/icons/budget categories/Groceries.png';
      case 'healthcare':
        return 'assets/images/icons/budget categories/Healthcare.png';
      case 'household':
        return 'assets/images/icons/budget categories/Household.png';
      case 'other':
        return 'assets/images/icons/budget categories/Other.png';
      case 'personal care':
        return 'assets/images/icons/budget categories/Personal Care.png';
      case 'shopping':
        return 'assets/images/icons/budget categories/Shopping.png';

      // You can keep some fallbacks for categories that might still exist
      case 'electricity':
        return 'assets/images/icons/budget categories/Household.png'; // or make a real one
      default:
        return 'assets/images/icons/budget_category.png'; // generic fallback
    }
  }

  // ── Walkthrough state ─────────────────────────────────────────────────────

  /// Current step; starts as [done] until the async check resolves.
  _BudgetWalkthroughStep _step = _BudgetWalkthroughStep.done;

  /// Whether the async SharedPreferences check has finished.
  bool _walkthroughChecked = false;

  // GlobalKeys to measure the exact position of each target row.
  final GlobalKey _incomeRowKey = GlobalKey();
  final GlobalKey _budgetRowKey = GlobalKey();

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Run the walkthrough check after the first frame so GlobalKeys are
    // attached and layout measurements are available.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initWalkthrough());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Walkthrough helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_kBudgetWalkthroughKey) ?? false;

    if (completed || !mounted) {
      setState(() => _walkthroughChecked = true);
      return;
    }

    // Read the live data to decide which step(s) are needed.
    final budgetState = ref.read(budgetHomeNotifierProvider);
    final data = budgetState.valueOrNull;

    if (data == null) {
      // Data not yet loaded – watch for it and re-run once available.
      setState(() => _walkthroughChecked = true);
      return;
    }

    final income = data.totalEarnings ?? 0;
    final totalBudget = data.budgets.fold<num>(
      0,
      (prev, b) => prev + (b.targetAmountMonthly ?? 0),
    );

    _BudgetWalkthroughStep initialStep;

    if (income == 0) {
      // Income must be set first – start there.
      initialStep = _BudgetWalkthroughStep.income;
    } else if (totalBudget == 0) {
      // Income is set but budget is zero – go straight to budget.
      initialStep = _BudgetWalkthroughStep.budget;
    } else {
      // Both are set – nothing to show.
      initialStep = _BudgetWalkthroughStep.done;
      await prefs.setBool(_kBudgetWalkthroughKey, true);
    }

    if (mounted) {
      setState(() {
        _step = initialStep;
        _walkthroughChecked = true;
      });
    }
  }

  /// Called when the user taps the arrow (or the overlay).
  Future<void> _advanceWalkthrough() async {
    switch (_step) {
      case _BudgetWalkthroughStep.income:
        // Check whether budget also needs guidance.
        final data = ref.read(budgetHomeNotifierProvider).valueOrNull;
        final totalBudget =
            data?.budgets.fold<num>(
              0,
              (prev, b) => prev + (b.targetAmountMonthly ?? 0),
            ) ??
            0;

        if (totalBudget == 0) {
          // Move arrow to budget row.
          setState(() => _step = _BudgetWalkthroughStep.budget);
        } else {
          await _completeWalkthrough();
        }
        break;

      case _BudgetWalkthroughStep.budget:
        await _completeWalkthrough();
        break;

      case _BudgetWalkthroughStep.done:
        break;
    }
  }

  Future<void> _completeWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBudgetWalkthroughKey, true);
    if (mounted) setState(() => _step = _BudgetWalkthroughStep.done);
  }

  bool get _isWalkthroughActive => _step != _BudgetWalkthroughStep.done;

  /// Returns the [Rect] of a widget identified by [key] in global coordinates.
  /// Returns null if the key is not yet attached.
  Rect? _getGlobalRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size; // Offset & Size → Rect
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Category helpers (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'auto & transport':
        return Icons.directions_car;
      case 'electricity':
        return Icons.bolt;
      case 'other':
        return Icons.category;
      default:
        return Icons.circle;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return const Color(0xFFFF006E);
      case 'auto & transport':
        return const Color(0xFFFF6B35);
      case 'electricity':
        return const Color(0xFFFFBE0B);
      case 'other':
        return const Color(0xFF06D6A0);
      default:
        return AppColors.primary;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetHomeNotifierProvider);

    // Re-evaluate walkthrough whenever data loads (covers the case where
    // _initWalkthrough ran before data was available).
    if (_walkthroughChecked && !_isWalkthroughActive && budgetState.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initWalkthrough());
    }

    return Stack(
      children: [
        // ── Main Scaffold ─────────────────────────────────────────────────
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Budgets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go('/tools'),
            ),
          ),
          body: budgetState.when(
            loading: () =>
                const CustomLoadingWidget(text: 'Loading your budgets...'),
            error: (error, stack) => CustomErrorWidget(
              icon: Icons.savings_outlined,
              title: 'Unable to Load Budgets',
              subtitle:
                  'We couldn\'t fetch your budgets. Please check your connection and try again.',
              actionButtonText: 'Retry',
              onActionPressed: () => ref.invalidate(budgetHomeNotifierProvider),
            ),
            data: (data) {
              final totalBudget = data.budgets.fold<num>(
                0,
                (prev, b) => prev + (b.targetAmountMonthly ?? 0),
              );
              final totalSpent = data.budgets.fold<num>(
                0,
                (prev, b) => prev + (b.balance ?? 0),
              );
              final totalEarnings = data.totalEarnings ?? 0;
              final monthlySavings = totalEarnings - totalBudget;
              final safeToSpend = totalBudget - totalSpent;

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(budgetHomeNotifierProvider),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMonthSelector(),
                    const Gap(16),
                    _buildSpendingCard(safeToSpend, totalSpent, totalBudget),
                    const Gap(32),
                    const Text(
                      'BUDGET BASICS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Color(0xFF757575),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(12),
                    // Pass both keys into the basics card so they attach
                    // to the exact rows we need to measure.
                    _buildBudgetBasics(
                      totalEarnings,
                      totalBudget,
                      monthlySavings,
                    ),
                    const Gap(32),
                    const Text(
                      'BREAKDOWN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Color(0xFF757575),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(12),
                    _buildCategoryBreakdown(data.budgets),
                    const Gap(24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            BudgetCategoryBottomSheet.show(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // const Gap(16),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(
                    //           content: Text('Budget saved successfully!'),
                    //           backgroundColor: Colors.green,
                    //         ),
                    //       );
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: AppColors.yellow,
                    //       foregroundColor: Colors.black,
                    //       padding: const EdgeInsets.symmetric(vertical: 16),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       elevation: 0,
                    //     ),
                    //     child: const Text(
                    //       'Save',
                    //       style: TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.w600,
                    //         fontFamily: 'GeneralSans',
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            },
          ),
        ),

        // ── Walkthrough overlay (above entire Scaffold) ───────────────────
        if (_walkthroughChecked && _isWalkthroughActive)
          _BudgetWalkthroughOverlay(
            step: _step,
            highlightRect: _step == _BudgetWalkthroughStep.income
                ? _getGlobalRect(_incomeRowKey)
                : _getGlobalRect(_budgetRowKey),
            onTap: _advanceWalkthrough,
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Month selector (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMonthSelector() {
    return Row(
      children: List.generate(3, (index) {
        final monthIndex = (_selectedMonthIndex - 1 + index) % 12;
        final isSelected = monthIndex == _selectedMonthIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(26, 255, 196, 0)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFC300)
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _months[monthIndex],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Spending card (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSpendingCard(num safeToSpend, num totalSpent, num totalBudget) {
    final progress = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => context.pushNamed(SpendingScreen.path),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/Calculator.png',
                      width: 20,
                      height: 20,
                      color: Colors.black,
                    ),
                    const Gap(8),
                    const Text(
                      'Spending',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.black),
            ],
          ),
          const Gap(12),
          Text(
            'Safe To Spend',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'GeneralSans',
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(4),
          Text(
            safeToSpend.toDouble().formatCurrency(decimalDigits: 0),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'GeneralSans',
            ),
          ),
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? Colors.red : AppColors.success,
              ),
              minHeight: 8,
            ),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalSpent.toDouble().formatCurrency(decimalDigits: 0)} spent',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'GeneralSans',
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${totalBudget.toDouble().formatCurrency(decimalDigits: 0)} budgeted',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'GeneralSans',
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Budget basics – GlobalKeys are attached here to the target rows
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBudgetBasics(num income, num budget, num savings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // ── Monthly Income row – keyed ──────────────────────────────────
          _buildBasicItem(
            key: _incomeRowKey,
            icon: Icons.account_balance_wallet_outlined,
            label: 'Monthly Income',
            amount: income,
            onTap: () => context.pushNamed(SetIncomeScreen.path),
          ),
          const Divider(height: 32),
          // ── Monthly Budget row – keyed ──────────────────────────────────
          _buildBasicItem(
            key: _budgetRowKey,
            icon: Icons.calculate_outlined,
            label: 'Monthly Budget',
            amount: budget,
            onTap: () => context.pushNamed(SetBudgetScreen.path),
          ),
          const Divider(height: 32),
          _buildBasicItem(
            icon: Icons.savings_outlined,
            label: 'Monthly Savings',
            amount: savings,
            showInfo: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicItem({
    Key? key, // ← accepts optional GlobalKey
    required IconData icon,
    required String label,
    required num amount,
    VoidCallback? onTap,
    bool showInfo = false,
  }) {
    return KeyedSubtree(
      key: key, // ← wraps the row so the key attaches to a real widget
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700),
            const Gap(12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
              ),
            ),
            const Spacer(),
            Text(
              amount.toDouble().formatCurrency(decimalDigits: 2),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
              ),
            ),
            const Gap(8),
            Icon(
              showInfo ? Icons.info_outline : Icons.chevron_right,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Category breakdown (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryBreakdown(List<Budget> budgets) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: budgets.asMap().entries.map((entry) {
          final index = entry.key;
          final budget = entry.value;
          final isLast = index == budgets.length - 1;
          return Column(
            children: [
              _buildCategoryItem(budget),
              if (!isLast) const Divider(height: 32),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(Budget budget) {
    final categoryName = budget.budgetName;
    final color = _getCategoryColor(
      categoryName,
    ); // keep this for background tint

    return InkWell(
      onTap: () => EditBudgetBottomSheet.show(context, budget: budget),
      child: Row(
        children: [
          // ── Changed: using real PNG instead of Icon ───────────────────────
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(8), // smaller padding than before
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), // softer tint
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              _getCategoryIconPath(categoryName),
              width: 28,
              height: 28,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image is missing or path is wrong
                return Icon(Icons.category_outlined, color: color, size: 24);
              },
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(8),
          Text(
            budget.targetAmountMonthly.toDouble().formatCurrency(
              decimalDigits: 0,
            ),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'GeneralSans',
            ),
          ),
          const Gap(8),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // Widget _buildCategoryItem(Budget budget) {
  //   return InkWell(
  //     onTap: () => EditBudgetBottomSheet.show(context, budget: budget),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //             color: _getCategoryColor(budget.budgetName).withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(
  //             _getCategoryIcon(budget.budgetName),
  //             color: _getCategoryColor(budget.budgetName),
  //             size: 20,
  //           ),
  //         ),
  //         const Gap(12),
  //         Text(
  //           budget.budgetName,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             fontFamily: 'GeneralSans',
  //           ),
  //         ),
  //         const Spacer(),
  //         Text(
  //           budget.targetAmountMonthly.toDouble().formatCurrency(
  //             decimalDigits: 0,
  //           ),
  //           style: const TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w600,
  //             fontFamily: 'GeneralSans',
  //           ),
  //         ),
  //         const Gap(8),
  //         Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
  //       ],
  //     ),
  //   );
  // }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BudgetWalkthroughOverlay
//
// Renders:
//   1. A full-screen dark backdrop with a rectangular cut-out over the
//      highlighted row (via CustomPainter).
//   2. A white card behind the highlighted row so it reads as "lit up".
//   3. The arrow image just below the highlighted row.
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetWalkthroughOverlay extends StatelessWidget {
  const _BudgetWalkthroughOverlay({
    required this.step,
    required this.highlightRect,
    required this.onTap,
  });

  final _BudgetWalkthroughStep step;

  /// The bounding box of the row to highlight, in global (screen) coordinates.
  /// If null the overlay still renders but without a cut-out.
  final Rect? highlightRect;

  final VoidCallback onTap;

  // Padding added around the highlighted row so it doesn't feel cramped.
  static const double _hPad = 16.0;
  static const double _vPad = 10.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Inflate the rect slightly so the white background peeks out a bit.
    final Rect? paddedRect = highlightRect == null
        ? null
        : Rect.fromLTRB(
            highlightRect!.left - _hPad,
            highlightRect!.top - _vPad,
            highlightRect!.right + _hPad,
            highlightRect!.bottom + _vPad,
          );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // ── Cut-out backdrop ──────────────────────────────────────────
          CustomPaint(
            size: size,
            painter: _CutOutOverlayPainter(cutOut: paddedRect),
          ),

          // ── White highlight card behind the target row ─────────────────
          if (paddedRect != null)
            Positioned(
              left: paddedRect.left,
              top: paddedRect.top,
              width: paddedRect.width,
              height: paddedRect.height,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // ── Arrow image below the highlighted row ──────────────────────
          if (paddedRect != null)
            Positioned(
              left: paddedRect.left + 8,
              top: paddedRect.bottom - 16,
              child: GestureDetector(
                onTap: onTap,
                child: Image.asset(
                  'assets/images/walk_through/home_arrow.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CutOutOverlayPainter
//
// Fills the entire canvas with a semi-transparent dark colour, then punches
// a rounded-rectangle hole wherever [cutOut] is specified, making that
// region fully transparent (i.e. the widget beneath shows through clearly).
// ─────────────────────────────────────────────────────────────────────────────

class _CutOutOverlayPainter extends CustomPainter {
  const _CutOutOverlayPainter({this.cutOut});

  final Rect? cutOut;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (cutOut == null) {
      // No cut-out – just paint a solid dark overlay.
      canvas.drawRect(
        fullRect,
        Paint()..color = Colors.black.withOpacity(0.55),
      );
      return;
    }

    // Use a Path with the even-odd fill rule so the intersection of the
    // full-screen rect and the cut-out rect becomes transparent.
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutOut!, const Radius.circular(12)));

    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.55));
  }

  @override
  bool shouldRepaint(_CutOutOverlayPainter old) => old.cutOut != cutOut;
}
