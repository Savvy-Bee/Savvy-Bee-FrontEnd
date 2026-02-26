import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/debt_detail_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/goal_stats_card.dart';
import 'add_debt_screen.dart';

const _kDebtWalkthroughKey = 'debt_walkthrough_completed';

class DebtScreen extends ConsumerStatefulWidget {
  static const String path = '/debt';

  const DebtScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DebtScreenState();
}

class _DebtScreenState extends ConsumerState<DebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Walkthrough ───────────────────────────────────────────────────────────
  bool _showWalkthrough = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    ref.read(debtListNotifierProvider.notifier).build();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkWalkthrough());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Walkthrough helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _checkWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_kDebtWalkthroughKey) ?? false;
    if (!completed && mounted) {
      setState(() => _showWalkthrough = true);
    }
  }

  Future<void> _dismissWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDebtWalkthroughKey, true);
    if (mounted) setState(() => _showWalkthrough = false);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final debtState = ref.watch(debtListNotifierProvider);

    return Stack(
      children: [
        // ── Main Scaffold ─────────────────────────────────────────────────
        Scaffold(
          appBar: AppBar(title: const Text('Debt')),
          body: RefreshIndicator(
            onRefresh: () =>
                ref.read(debtListNotifierProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        debtState.when(
                          data: (data) {
                            final activeDebts =
                                data.data.where((d) => d.isActive).toList();
                            final totalRemaining = activeDebts.fold<double>(
                              0.0, (sum, d) => sum + d.owed,
                            );
                            return _buildDebtCard(totalRemaining);
                          },
                          loading: () => _buildDebtCard(0.0, isLoading: true),
                          error: (e, st) => _buildDebtCard(
                            0.0,
                            isError: true,
                            errorMessage: 'Failed to load debts',
                          ),
                        ),
                        const Gap(16),
                        TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: const [
                            Tab(text: 'Active'),
                            Tab(text: 'Paid off'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                debtState.when(
                  loading: () => const SliverFillRemaining(
                    child: CustomLoadingWidget(text: 'Loading debt...'),
                  ),
                  error: (e, st) => SliverFillRemaining(
                    child: CustomErrorWidget.error(
                      onRetry: () =>
                          ref.read(debtListNotifierProvider.notifier).refresh(),
                    ),
                  ),
                  data: (data) {
                    final activeDebts =
                        data.data.where((d) => d.isActive).toList();
                    final paidOffDebts =
                        data.data.where((d) => !d.isActive).toList();
                    final currentList = _tabController.index == 0
                        ? activeDebts
                        : paidOffDebts;
                    return _buildDebtListSliver(
                        currentList, _tabController.index == 0);
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.pushNamed(AddDebtScreen.path),
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.add),
          ),
        ),

        // ── Walkthrough overlay (above AppBar + FAB + body) ───────────────
        if (_showWalkthrough)
          GestureDetector(
            onTap: _dismissWalkthrough,
            child: Stack(
              children: [
                // Dark backdrop
                Container(
                  color: Colors.black.withOpacity(0.55),
                ),
                // Character image — bottom-right
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    'assets/images/walk_through/debts_welcome.png',
                    width: MediaQuery.of(context).size.width * 0.65,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Original helpers (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDebtListSliver(List<Debt> debts, bool isActive) {
    if (debts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No ${isActive ? 'active' : 'paid off'} debts yet.'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      sliver: SliverList.separated(
        itemCount: debts.length,
        itemBuilder: (context, index) {
          final debt = debts[index];
          return GestureDetector(
            onTap: () => DebtDetailBottomSheet.show(context, debt),
            child: GoalStatsCard(
              title: debt.name,
              amountSaved: debt.balance,
              totalTarget: debt.owed,
              daysLeft:
                  debt.expectedPayoffDate.difference(DateTime.now()).inDays,
              isDebt: true,
            ),
          );
        },
        separatorBuilder: (context, index) => const Gap(16),
      ),
    );
  }

  Widget _buildDebtCard(
    double amountRemaining, {
    bool isLoading = false,
    bool isError = false,
    String errorMessage = '',
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL DEBTS REMAINING',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const Gap(8),
          if (isLoading)
            const SizedBox(
              height: 36,
              child: Center(child: LinearProgressIndicator()),
            )
          else if (isError)
            Text(errorMessage,
                style: const TextStyle(color: AppColors.error))
          else
            Text(
              amountRemaining.formatCurrency(),
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 36),
            ),
          const Gap(8),
          Text(
            isLoading ? 'Loading...' : 'Updated',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';
// import '../../../../../core/theme/app_colors.dart';
// import '../../widgets/goal_stats_card.dart';
// import 'add_debt_screen.dart';

// const _kDebtWalkthroughKey = 'debt_walkthrough_completed';

// class DebtScreen extends ConsumerStatefulWidget {
//   static const String path = '/debt';

//   const DebtScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _DebtScreenState();
// }

// class _DebtScreenState extends ConsumerState<DebtScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // ── Walkthrough ───────────────────────────────────────────────────────────
//   bool _showWalkthrough = false;

//   // ─────────────────────────────────────────────────────────────────────────
//   // Lifecycle
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   void initState() {
//     super.initState();
//     ref.read(debtListNotifierProvider.notifier).build();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) setState(() {});
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkWalkthrough());
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Walkthrough helpers
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _checkWalkthrough() async {
//     final prefs = await SharedPreferences.getInstance();
//     final completed = prefs.getBool(_kDebtWalkthroughKey) ?? false;
//     if (!completed && mounted) {
//       setState(() => _showWalkthrough = true);
//     }
//   }

//   Future<void> _dismissWalkthrough() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_kDebtWalkthroughKey, true);
//     if (mounted) setState(() => _showWalkthrough = false);
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Build
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final debtState = ref.watch(debtListNotifierProvider);

//     return Stack(
//       children: [
//         // ── Main Scaffold ─────────────────────────────────────────────────
//         Scaffold(
//           appBar: AppBar(title: const Text('Debt')),
//           body: RefreshIndicator(
//             onRefresh: () =>
//                 ref.read(debtListNotifierProvider.notifier).refresh(),
//             child: CustomScrollView(
//               slivers: [
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         debtState.when(
//                           data: (data) {
//                             final activeDebts =
//                                 data.data.where((d) => d.isActive).toList();
//                             final totalRemaining = activeDebts.fold<double>(
//                               0.0, (sum, d) => sum + d.owed,
//                             );
//                             return _buildDebtCard(totalRemaining);
//                           },
//                           loading: () => _buildDebtCard(0.0, isLoading: true),
//                           error: (e, st) => _buildDebtCard(
//                             0.0,
//                             isError: true,
//                             errorMessage: 'Failed to load debts',
//                           ),
//                         ),
//                         const Gap(16),
//                         TabBar(
//                           controller: _tabController,
//                           dividerColor: Colors.transparent,
//                           indicatorSize: TabBarIndicatorSize.tab,
//                           tabs: const [
//                             Tab(text: 'Active'),
//                             Tab(text: 'Paid off'),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 debtState.when(
//                   loading: () => const SliverFillRemaining(
//                     child: CustomLoadingWidget(text: 'Loading debt...'),
//                   ),
//                   error: (e, st) => SliverFillRemaining(
//                     child: CustomErrorWidget.error(
//                       onRetry: () =>
//                           ref.read(debtListNotifierProvider.notifier).refresh(),
//                     ),
//                   ),
//                   data: (data) {
//                     final activeDebts =
//                         data.data.where((d) => d.isActive).toList();
//                     final paidOffDebts =
//                         data.data.where((d) => !d.isActive).toList();
//                     final currentList = _tabController.index == 0
//                         ? activeDebts
//                         : paidOffDebts;
//                     return _buildDebtListSliver(
//                         currentList, _tabController.index == 0);
//                   },
//                 ),
//               ],
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () => context.pushNamed(AddDebtScreen.path),
//             backgroundColor: AppColors.buttonPrimary,
//             foregroundColor: AppColors.white,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(50)),
//             child: const Icon(Icons.add),
//           ),
//         ),

//         // ── Walkthrough overlay (above AppBar + FAB + body) ───────────────
//         if (_showWalkthrough)
//           GestureDetector(
//             onTap: _dismissWalkthrough,
//             child: Stack(
//               children: [
//                 // Dark backdrop
//                 Container(
//                   color: Colors.black.withOpacity(0.55),
//                 ),
//                 // Character image — bottom-right
//                 Align(
//                   alignment: Alignment.bottomRight,
//                   child: Image.asset(
//                     'assets/images/walk_through/debts_welcome.png',
//                     width: MediaQuery.of(context).size.width * 0.65,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Original helpers (unchanged)
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildDebtListSliver(List<Debt> debts, bool isActive) {
//     if (debts.isEmpty) {
//       return SliverFillRemaining(
//         hasScrollBody: false,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Text('No ${isActive ? 'active' : 'paid off'} debts yet.'),
//           ),
//         ),
//       );
//     }

//     return SliverPadding(
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
//       sliver: SliverList.separated(
//         itemCount: debts.length,
//         itemBuilder: (context, index) {
//           final debt = debts[index];
//           return GoalStatsCard(
//             title: debt.name,
//             amountSaved: debt.balance,
//             totalTarget: debt.owed,
//             daysLeft:
//                 debt.expectedPayoffDate.difference(DateTime.now()).inDays,
//             isDebt: true,
//           );
//         },
//         separatorBuilder: (context, index) => const Gap(16),
//       ),
//     );
//   }

//   Widget _buildDebtCard(
//     double amountRemaining, {
//     bool isLoading = false,
//     bool isError = false,
//     String errorMessage = '',
//   }) {
//     return CustomCard(
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'TOTAL DEBTS REMAINING',
//             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
//           ),
//           const Gap(8),
//           if (isLoading)
//             const SizedBox(
//               height: 36,
//               child: Center(child: LinearProgressIndicator()),
//             )
//           else if (isError)
//             Text(errorMessage,
//                 style: const TextStyle(color: AppColors.error))
//           else
//             Text(
//               amountRemaining.formatCurrency(),
//               style:
//                   const TextStyle(fontWeight: FontWeight.w500, fontSize: 36),
//             ),
//           const Gap(8),
//           Text(
//             isLoading ? 'Loading...' : 'Updated',
//             style: const TextStyle(fontSize: 12, color: AppColors.textLight),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';
// import '../../../../../core/theme/app_colors.dart';
// import '../../widgets/goal_stats_card.dart';
// import 'add_debt_screen.dart';

// class DebtScreen extends ConsumerStatefulWidget {
//   static const String path = '/debt';

//   const DebtScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _DebtScreenState();
// }

// class _DebtScreenState extends ConsumerState<DebtScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     ref.read(debtListNotifierProvider.notifier).build();
//     _tabController = TabController(length: 2, vsync: this);

//     // Listen to tab changes to rebuild when switching tabs
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final debtState = ref.watch(debtListNotifierProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Debt')),
//       body: RefreshIndicator(
//         onRefresh: () => ref.read(debtListNotifierProvider.notifier).refresh(),
//         child: CustomScrollView(
//           slivers: [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Debt Summary Card
//                     debtState.when(
//                       data: (data) {
//                         final activeDebts = data.data
//                             .where((item) => item.isActive)
//                             .toList();
//                         final totalRemaining = activeDebts.fold<double>(
//                           0.0,
//                           (sum, debt) => sum + debt.owed,
//                         );
//                         return _buildDebtCard(totalRemaining);
//                       },
//                       loading: () => _buildDebtCard(0.0, isLoading: true),
//                       error: (e, st) => _buildDebtCard(
//                         0.0,
//                         isError: true,
//                         errorMessage: 'Failed to load debts',
//                       ),
//                     ),
//                     const Gap(16),

//                     // Tab Bar
//                     TabBar(
//                       controller: _tabController,
//                       dividerColor: Colors.transparent,
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       tabs: const [
//                         Tab(text: 'Active'),
//                         Tab(text: 'Paid off'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Tab Content
//             debtState.when(
//               loading: () => const SliverFillRemaining(
//                 child: CustomLoadingWidget(text: 'Loading debt...'),
//               ),
//               error: (e, st) => SliverFillRemaining(
//                 child: CustomErrorWidget.error(
//                   onRetry: () =>
//                       ref.read(debtListNotifierProvider.notifier).refresh(),
//                 ),
//               ),
//               data: (data) {
//                 final activeDebts = data.data
//                     .where((item) => item.isActive)
//                     .toList();
//                 final paidOffDebts = data.data
//                     .where((item) => !item.isActive)
//                     .toList();

//                 final currentList = _tabController.index == 0
//                     ? activeDebts
//                     : paidOffDebts;
//                 final isActive = _tabController.index == 0;

//                 return _buildDebtListSliver(currentList, isActive);
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.pushNamed(AddDebtScreen.path),
//         backgroundColor: AppColors.buttonPrimary,
//         foregroundColor: AppColors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildDebtListSliver(List<Debt> debts, bool isActive) {
//     if (debts.isEmpty) {
//       return SliverFillRemaining(
//         hasScrollBody: false,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Text('No ${isActive ? 'active' : 'paid off'} debts yet.'),
//           ),
//         ),
//       );
//     }

//     return SliverPadding(
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
//       sliver: SliverList.separated(
//         itemCount: debts.length,
//         itemBuilder: (context, index) {
//           final debt = debts[index];
//           return GoalStatsCard(
//             title: debt.name,
//             amountSaved: debt.balance,
//             totalTarget: debt.owed,
//             daysLeft: debt.expectedPayoffDate.difference(DateTime.now()).inDays,
//             isDebt: true,
//           );
//         },
//         separatorBuilder: (context, index) => const Gap(16),
//       ),
//     );
//   }

//   Widget _buildDebtCard(
//     double amountRemaining, {
//     bool isLoading = false,
//     bool isError = false,
//     String errorMessage = '',
//   }) {
//     return CustomCard(
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'TOTAL DEBTS REMAINING',
//             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
//           ),
//           const Gap(8),
//           if (isLoading)
//             const SizedBox(
//               height: 36,
//               child: Center(child: LinearProgressIndicator()),
//             )
//           else if (isError)
//             Text(errorMessage, style: const TextStyle(color: AppColors.error))
//           else
//             Text(
//               amountRemaining.formatCurrency(),
//               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 36),
//             ),
//           const Gap(8),
//           Text(
//             isLoading ? 'Loading...' : 'Updated',
//             style: TextStyle(fontSize: 12, color: AppColors.textLight),
//           ),
//         ],
//       ),
//     );
//   }
// }
