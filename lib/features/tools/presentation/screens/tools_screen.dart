import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/providers/chat_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budgets_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/taxation_dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local personality catalogue used to resolve API persona → image + name
// ─────────────────────────────────────────────────────────────────────────────

const List<Map<String, String>> _kLocalPersonalities = [
  {
    'id': 'loan_pro',
    'name': 'Dash',
    'imagePath': 'assets/images/icons/dash.png',
  },
  {
    'id': 'budgeting_bee',
    'name': 'Penny',
    'imagePath': 'assets/images/icons/penny.png',
  },
  {
    'id': 'saving_star',
    'name': 'Bloom',
    'imagePath': 'assets/images/icons/bloom.png',
  },
  {
    'id': 'big_dreamer',
    'name': 'Susu',
    'imagePath': 'assets/images/icons/susu.png',
  },
  {
    'id': 'matching_bee',
    'name': 'Luna',
    'imagePath': 'assets/images/icons/luna.png',
  },
  {'id': 'quiz_bee', 'name': 'Boo', 'imagePath': 'assets/images/icons/boo.png'},
  {
    'id': 'scam_spotter',
    'name': 'Loki',
    'imagePath': 'assets/images/icons/loki.png',
  },
];

/// Resolves an API [Persona] to its matching local entry.
///
/// Matching priority:
///   1. API `ID` (e.g. "Nurturing_Guide") normalised to snake_case vs local `id`
///   2. API `Name` (e.g. "Boo") case-insensitive vs local `name`
///
/// Falls back to Boo if nothing matches.
Map<String, String> _resolveLocalPersonality({
  required String apiId,
  required String apiName,
}) {
  print(apiId);
  print(apiName);
  // Normalise the API id: lowercase + replace spaces/hyphens with underscores
  final normId = apiId.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
  final normName = apiName.toLowerCase().trim();

  return _kLocalPersonalities.firstWhere(
    (p) =>
        p['id']!.toLowerCase() == normId ||
        p['name']!.toLowerCase() == normName,
    orElse: () => _kLocalPersonalities.firstWhere(
      (p) => p['name']! == 'Boo',
      orElse: () => _kLocalPersonalities.first,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Walkthrough steps
// ─────────────────────────────────────────────────────────────────────────────

enum _ToolsWalkthroughStep {
  /// "tools_welcome" image, no arrow, bottom-left
  welcome,

  /// "boo" image, no arrow, bottom-left
  boo,

  /// "home_budget" image, arrow below Budgets row, bottom-right
  budget,

  /// "goals" image, arrow below Goals row, bottom-left
  goals,

  /// "debts" image, arrow below Debt Tracker row, bottom-right
  debts,

  /// "taxes" image, arrow below Tax row, bottom-right
  taxes,

  /// Walkthrough finished — nothing rendered
  done,
}

const _kToolsWalkthroughKey = 'tools_walkthrough_completed';

// ─────────────────────────────────────────────────────────────────────────────
// ToolsScreen
// ─────────────────────────────────────────────────────────────────────────────

class ToolsScreen extends ConsumerStatefulWidget {
  static const String path = '/tools';

  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  // ── Walkthrough ───────────────────────────────────────────────────────────
  _ToolsWalkthroughStep _step = _ToolsWalkthroughStep.done;
  bool _walkthroughChecked = false;

  // GlobalKeys – one per tool-list item that needs an arrow
  final GlobalKey _budgetItemKey = GlobalKey();
  final GlobalKey _goalsItemKey = GlobalKey();
  final GlobalKey _debtsItemKey = GlobalKey();
  final GlobalKey _taxItemKey = GlobalKey();

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(homeDataProvider);

      // ── Refresh persona every time Tools screen is opened ────────────────
      ref.invalidate(myPersonaProvider);

      _checkWalkthrough();
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ref.invalidate(homeDataProvider);
  //     _checkWalkthrough();
  //   });
  // }

  // ─────────────────────────────────────────────────────────────────────────
  // Walkthrough helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _checkWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_kToolsWalkthroughKey) ?? false;
    if (mounted) {
      setState(() {
        _step = completed
            ? _ToolsWalkthroughStep.done
            : _ToolsWalkthroughStep.welcome;
        _walkthroughChecked = true;
      });
    }
  }

  Future<void> _advanceWalkthrough() async {
    switch (_step) {
      case _ToolsWalkthroughStep.welcome:
        setState(() => _step = _ToolsWalkthroughStep.boo);
        break;
      case _ToolsWalkthroughStep.boo:
        setState(() => _step = _ToolsWalkthroughStep.budget);
        break;
      case _ToolsWalkthroughStep.budget:
        setState(() => _step = _ToolsWalkthroughStep.goals);
        break;
      case _ToolsWalkthroughStep.goals:
        setState(() => _step = _ToolsWalkthroughStep.debts);
        break;
      case _ToolsWalkthroughStep.debts:
        setState(() => _step = _ToolsWalkthroughStep.taxes);
        break;
      case _ToolsWalkthroughStep.taxes:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kToolsWalkthroughKey, true);
        if (mounted) setState(() => _step = _ToolsWalkthroughStep.done);
        break;
      case _ToolsWalkthroughStep.done:
        break;
    }
  }

  bool get _isWalkthroughActive => _step != _ToolsWalkthroughStep.done;

  /// Returns the bounding [Rect] of a widget in global (screen) coordinates.
  Rect? _globalRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Which key (if any) is the current spotlight target?
  GlobalKey? get _currentHighlightKey {
    switch (_step) {
      case _ToolsWalkthroughStep.budget:
        return _budgetItemKey;
      case _ToolsWalkthroughStep.goals:
        return _goalsItemKey;
      case _ToolsWalkthroughStep.debts:
        return _debtsItemKey;
      case _ToolsWalkthroughStep.taxes:
        return _taxItemKey;
      default:
        return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Health popup helpers (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  String _getHealthImage(String status) {
    switch (status.toLowerCase().trim()) {
      case 'stabilizing':
        return 'assets/images/Financial_Health/JARS/HIVE BAR STABILISING.png';
      case 'surviving':
        return 'assets/images/Financial_Health/JARS/HIVE BAR SURVIVING.png';
      case 'flourishing':
        return 'assets/images/Financial_Health/JARS/HIVE BAR FLOURISHING.png';
      case 'thriving':
        return 'assets/images/Financial_Health/JARS/HIVE BAR THRIVING.png';
      case 'building':
        return 'assets/images/Financial_Health/JARS/HIVE BAR BUILDING.png';
      default:
        return 'assets/images/Financial_Health/JARS/HIVE BAR EMPTY.png';
    }
  }

  String _getPopUpImage(String status) {
    switch (status.toLowerCase().trim()) {
      case 'stabilizing':
        return 'assets/images/illustrations/health/stabilizing.png';
      case 'surviving':
        return 'assets/images/illustrations/health/surviving.png';
      case 'flourishing':
        return 'assets/images/illustrations/health/flourishing.png';
      case 'thriving':
        return 'assets/images/illustrations/health/thriving.png';
      case 'building':
        return 'assets/images/illustrations/health/building.png';
      default:
        return 'assets/images/illustrations/health/stabilizing.png';
    }
  }

  void _showHealthPopup(String statusText) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _getPopUpImage(statusText),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final personaAsync = ref.watch(myPersonaProvider); // ← added
    final firstName = homeDataAsync.valueOrNull?.data?.firstName ?? '';
    final isLoading = homeDataAsync.isLoading && !homeDataAsync.hasValue;
    final hasError = homeDataAsync.hasError;
    final statusText = homeDataAsync.valueOrNull?.data?.aiData?.status ?? '';

    // Resolve highlight rect for the current step (may be null if key not yet laid out)
    final highlightRect = _currentHighlightKey != null
        ? _globalRect(_currentHighlightKey!)
        : null;

    return Stack(
      children: [
        // ── Main Scaffold ─────────────────────────────────────────────────
        Scaffold(
          appBar: _buildAppBar(firstName, context, personaAsync),
          floatingActionButton: _buildHealthJarFAB(statusText),
          body: Stack(
            children: [
              // ── Gradient + content ──────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tools',
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              height: 1.1,
                            ),
                          ),
                          Gap(8),
                          Text(
                            'Your one stop shop for peak financial health',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                          children: [
                            // Each item wrapped in KeyedSubtree so the
                            // GlobalKey attaches to a real widget node.
                            KeyedSubtree(
                              key: _budgetItemKey,
                              child: _buildToolItem(
                                title: 'Budgets',
                                subtitle:
                                    'Create smart budgets, track spending, and get personalized insights.',
                                iconPath: 'assets/images/icons/budget_icon.png',
                                onPressed: () =>
                                    context.pushNamed(BudgetsScreen.path),
                              ),
                            ),
                            const Divider(color: AppColors.grey, height: 1),
                            KeyedSubtree(
                              key: _goalsItemKey,
                              child: _buildToolItem(
                                title: 'Goals',
                                subtitle:
                                    'Set goals, get AI-powered suggestions, and track your progress.',
                                iconPath: 'assets/images/icons/goals_icon.png',
                                onPressed: () =>
                                    context.pushNamed(GoalsScreen.path),
                              ),
                            ),
                            const Divider(color: AppColors.grey, height: 1),
                            KeyedSubtree(
                              key: _debtsItemKey,
                              child: _buildToolItem(
                                title: 'Debt Tracker',
                                subtitle:
                                    'Stay on top of your debts and plan your payoff with ease.',
                                iconPath: 'assets/images/icons/debt_icon.png',
                                onPressed: () =>
                                    context.pushNamed(DebtScreen.path),
                              ),
                            ),
                            const Divider(color: AppColors.grey, height: 1),
                            KeyedSubtree(
                              key: _taxItemKey,
                              child: _buildToolItem(
                                title: 'Tax',
                                subtitle:
                                    'Calculate your tax and track your earnings with ease.',
                                iconPath: 'assets/images/icons/tax_icon.png',
                                onPressed: () => context.pushNamed(
                                  TaxationDashboardScreen.path,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Loading indicator ───────────────────────────────────────
              if (isLoading)
                const Positioned(
                  top: 16,
                  right: 24,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                    ),
                  ),
                ),

              // ── Error overlay ───────────────────────────────────────────
              if (hasError)
                CustomErrorWidget(
                  icon: Icons.person_outline,
                  title: 'Unable to Load User Info',
                  subtitle:
                      'We couldn\'t fetch your account data. Please check your connection and try again.',
                  actionButtonText: 'Retry',
                  onActionPressed: () => ref.invalidate(homeDataProvider),
                ),
            ],
          ),
        ),

        // ── Walkthrough overlay (above AppBar + FAB + body) ───────────────
        if (_walkthroughChecked && _isWalkthroughActive)
          _ToolsWalkthroughOverlay(
            step: _step,
            highlightRect: highlightRect,
            onTap: _advanceWalkthrough,
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tool list item (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildToolItem({
    required String title,
    required String subtitle,
    required String iconPath,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 37,
                  height: 37,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AppBar (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(
    String firstName,
    BuildContext context,
    AsyncValue<dynamic> personaAsync,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => context.pushNamed(ChatScreen.path),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: ClipOval(
                        child: personaAsync.when(
                          data: (persona) {
                            if (persona == null) return _defaultChatIcon();
                            final local = _resolveLocalPersonality(
                              apiId: persona.id ?? '',
                              apiName: persona.name ?? '',
                            );
                            return Image.asset(
                              local['imagePath']!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultChatIcon(),
                            );
                          },
                          loading: () => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          error: (_, __) => _defaultChatIcon(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Chat with Nahl',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              Image.asset(
                'assets/images/topbar/nav-center-icon.png',
                width: 30,
                height: 32,
                fit: BoxFit.contain,
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.pushNamed(ProfileScreen.path),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Text(
                  firstName.isNotEmpty
                      ? (firstName.length > 1
                            ? firstName.substring(0, 2).toUpperCase()
                            : firstName[0].toUpperCase())
                      : 'Me',
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
    );
  }

  Widget _defaultChatIcon() {
    return const Center(
      child: Icon(Icons.smart_toy, size: 20, color: AppColors.primary),
    );
  }

  // AppBar _buildAppBar(String firstName, BuildContext context) {
  //   return AppBar(
  //     elevation: 0,
  //     backgroundColor: Colors.transparent,
  //     flexibleSpace: Container(
  //       decoration: const BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.topRight,
  //           colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
  //         ),
  //       ),
  //     ),
  //     title: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             InkWell(
  //               onTap: () => context.pushNamed(ChatScreen.path),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Container(
  //                     width: 32,
  //                     height: 32,
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       border: Border.all(color: AppColors.primary),
  //                     ),
  //                     child: Center(
  //                       child: Image.asset(
  //                         'assets/images/topbar/nav-left-icon.png',
  //                         width: 32,
  //                         height: 32,
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 6),
  //                   const Text(
  //                     'Chat with Nahl',
  //                     style: TextStyle(
  //                       fontFamily: 'GeneralSans',
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.black,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(width: 25),
  //             Image.asset(
  //               'assets/images/topbar/nav-center-icon.png',
  //               width: 30,
  //               height: 32,
  //               fit: BoxFit.contain,
  //             ),
  //           ],
  //         ),
  //         GestureDetector(
  //           onTap: () => context.pushNamed(ProfileScreen.path),
  //           child: Container(
  //             width: 32,
  //             height: 32,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.black, width: 1),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 firstName.isNotEmpty
  //                     ? (firstName.length > 1
  //                           ? firstName.substring(0, 2).toUpperCase()
  //                           : firstName[0].toUpperCase())
  //                     : 'Me',
  //                 style: const TextStyle(
  //                   fontFamily: 'GeneralSans',
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 16,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     centerTitle: false,
  //     automaticallyImplyLeading: false,
  //   );
  // }

  // ─────────────────────────────────────────────────────────────────────────
  // FAB (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHealthJarFAB(String statusText) {
    return FloatingActionButton(
      onPressed: () => _showHealthPopup(statusText),
      backgroundColor: Colors.transparent,
      elevation: 4,
      shape: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFEFB5),
          border: Border.all(color: const Color(0xFFFFC300), width: 1),
        ),
        child: Image.asset(
          _getHealthImage(statusText),
          fit: BoxFit.contain,
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ToolsWalkthroughOverlay
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable config for each walkthrough step.
class _StepConfig {
  const _StepConfig({
    required this.imagePath,
    required this.imageAlignment, // which corner the character sits in
    this.hasArrow = false,
  });

  final String imagePath;
  final Alignment imageAlignment;
  final bool hasArrow;
}

// Map every step to its visual config.
const Map<_ToolsWalkthroughStep, _StepConfig> _kStepConfigs = {
  _ToolsWalkthroughStep.welcome: _StepConfig(
    imagePath: 'assets/images/walk_through/tools_welcome.png',
    imageAlignment: Alignment.bottomLeft,
  ),
  _ToolsWalkthroughStep.boo: _StepConfig(
    imagePath: 'assets/images/walk_through/boo.png',
    imageAlignment: Alignment.bottomLeft,
  ),
  _ToolsWalkthroughStep.budget: _StepConfig(
    imagePath: 'assets/images/walk_through/home_budget.png',
    imageAlignment: Alignment.bottomRight,
    hasArrow: true,
  ),
  _ToolsWalkthroughStep.goals: _StepConfig(
    imagePath: 'assets/images/walk_through/goals.png',
    imageAlignment: Alignment.bottomLeft,
    hasArrow: true,
  ),
  _ToolsWalkthroughStep.debts: _StepConfig(
    imagePath: 'assets/images/walk_through/debts.png',
    imageAlignment: Alignment.bottomRight,
    hasArrow: true,
  ),
  _ToolsWalkthroughStep.taxes: _StepConfig(
    imagePath: 'assets/images/walk_through/taxes.png',
    imageAlignment: Alignment.bottomRight,
    hasArrow: true,
  ),
};

class _ToolsWalkthroughOverlay extends StatelessWidget {
  const _ToolsWalkthroughOverlay({
    required this.step,
    required this.onTap,
    this.highlightRect,
  });

  final _ToolsWalkthroughStep step;
  final VoidCallback onTap;

  /// Bounding rect (global coords) of the item to spotlight.
  /// Null when no arrow/highlight is active.
  final Rect? highlightRect;

  // Padding inflated around the spotlight target.
  static const double _hPad = 16.0;
  static const double _vPad = -2.5;

  @override
  Widget build(BuildContext context) {
    final config = _kStepConfigs[step];
    if (config == null) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;

    // Inflate the highlight rect so a white background visually bleeds out.
    final Rect? paddedRect = (config.hasArrow && highlightRect != null)
        ? Rect.fromLTRB(
            highlightRect!.left - _hPad,
            highlightRect!.top - _vPad,
            highlightRect!.right + _hPad,
            highlightRect!.bottom + _vPad,
          )
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // ── Cut-out backdrop ──────────────────────────────────────────
          CustomPaint(
            size: size,
            painter: _CutOutOverlayPainter(cutOut: paddedRect),
          ),

          // ── White spotlight behind the target row ──────────────────────
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

          // ── Arrow below the spotlight ──────────────────────────────────
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

          // ── Character image ────────────────────────────────────────────
          Align(
            alignment: config.imageAlignment,
            child: IgnorePointer(
              // The GestureDetector on the whole overlay handles the tap;
              // we IgnorePointer here so it bubbles up correctly.
              ignoring: false,
              child: Image.asset(
                config.imagePath,
                width: size.width * 0.65,
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
// Draws a full-screen semi-transparent dark layer, then "punches out" a
// rounded rectangle at [cutOut] using the even-odd fill rule so that region
// stays fully transparent.
// ─────────────────────────────────────────────────────────────────────────────

class _CutOutOverlayPainter extends CustomPainter {
  const _CutOutOverlayPainter({this.cutOut});

  final Rect? cutOut;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (cutOut == null) {
      canvas.drawRect(fullRect, paint);
      return;
    }

    // Even-odd rule: where the two shapes overlap the fill is removed,
    // leaving the cutOut region transparent.
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutOut!, const Radius.circular(12)));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CutOutOverlayPainter old) => old.cutOut != cutOut;
}



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
// import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budgets_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/taxation_dashboard_screen.dart';

// class ToolsScreen extends ConsumerStatefulWidget {
//   static const String path = '/tools';

//   const ToolsScreen({super.key});

//   @override
//   ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
// }

// class _ToolsScreenState extends ConsumerState<ToolsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Trigger fetch after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.invalidate(homeDataProvider);
//     });
//   }

//   String _getHealthImage(String status) {
//     final normalizedStatus = status.toLowerCase().trim();

//     switch (normalizedStatus) {
//       case 'stabilizing':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR STABILISING.png';
//       case 'surviving':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR SURVIVING.png';
//       case 'flourishing':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR FLOURISHING.png';
//       case 'thriving':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR THRIVING.png';
//       case 'building':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR BUILDING.png';
//       default:
//         return 'assets/images/Financial_Health/JARS/HIVE BAR EMPTY.png';
//     }
//   }

//   String _getPopUpImage(String status) {
//     final normalizedStatus = status.toLowerCase().trim();

//     switch (normalizedStatus) {
//       case 'stabilizing':
//         return 'assets/images/illustrations/health/stabilizing.png';
//       case 'surviving':
//         return 'assets/images/illustrations/health/surviving.png';
//       case 'flourishing':
//         return 'assets/images/illustrations/health/flourishing.png';
//       case 'thriving':
//         return 'assets/images/illustrations/health/thriving.png';
//       case 'building':
//         return 'assets/images/illustrations/health/building.png';
//       default:
//         return 'assets/images/illustrations/health/stabilizing.png';
//     }
//   }

//   void _showHealthPopup(String statusText) {
//     final popupImage = _getPopUpImage(statusText);

//     showDialog(
//       context: context,
//       barrierDismissible: true, // Allow tapping outside to close
//       barrierColor: Colors.black.withOpacity(
//         0.7,
//       ), // Semi-transparent background
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//         child: GestureDetector(
//           onTap: () => Navigator.of(context).pop(), // Close on tap
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Close button
//               // Align(
//               //   alignment: Alignment.topRight,
//               //   child: IconButton(
//               //     onPressed: () => Navigator.of(context).pop(),
//               //     icon: const Icon(Icons.close, color: Colors.white, size: 32),
//               //     style: IconButton.styleFrom(
//               //       backgroundColor: Colors.black.withOpacity(0.5),
//               //     ),
//               //   ),
//               // ),
//               // const SizedBox(height: 16),

//               // Health status image
//               Container(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width * 0.9,
//                   maxHeight: MediaQuery.of(context).size.height * 0.7,
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.asset(popupImage, fit: BoxFit.contain),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Status text
//               // Container(
//               //   padding: const EdgeInsets.symmetric(
//               //     horizontal: 24,
//               //     vertical: 12,
//               //   ),
//               //   decoration: BoxDecoration(
//               //     color: Colors.white,
//               //     borderRadius: BorderRadius.circular(24),
//               //   ),
//               //   child: Text(
//               //     statusText.toUpperCase(),
//               //     style: const TextStyle(
//               //       fontFamily: 'GeneralSans',
//               //       fontSize: 16,
//               //       fontWeight: FontWeight.w600,
//               //       color: Colors.black,
//               //       letterSpacing: 1.2,
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final homeDataAsync = ref.watch(homeDataProvider);

//     // Fallback name until data loads
//     final firstName = homeDataAsync.valueOrNull?.data?.firstName ?? '';

//     final isLoading = homeDataAsync.isLoading && !homeDataAsync.hasValue;
//     final hasError = homeDataAsync.hasError;

//     final healthData = homeDataAsync.valueOrNull?.data?.aiData;
//     final statusText = healthData?.status ?? '';

//     return Scaffold(
//       appBar: _buildAppBar(firstName, context),
//       // ── ADD FLOATING ACTION BUTTON ──
//       floatingActionButton: _buildHealthJarFAB(statusText),
//       body: Stack(
//         children: [
//           // ── Main content ── always visible ───────────────────────────────
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.topRight,
//                 colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Tools',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontFamily: 'GeneralSans',
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                           height: 1.1,
//                         ),
//                       ),
//                       const Gap(8),
//                       const Text(
//                         'Your one stop shop for peak financial health',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'GeneralSans',
//                           fontWeight: FontWeight.w400,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Tools list
//                 Expanded(
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(32),
//                       ),
//                     ),
//                     child: ListView(
//                       padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
//                       children: [
//                         _buildToolItem(
//                           title: 'Budgets',
//                           subtitle:
//                               'Create smart budgets, track spending, and get personalized insights.',
//                           iconPath: 'assets/images/icons/budget_icon.png',
//                           onPressed: () =>
//                               context.pushNamed(BudgetsScreen.path),
//                         ),
//                         const Divider(color: AppColors.grey, height: 1),
//                         _buildToolItem(
//                           title: 'Goals',
//                           subtitle:
//                               'Set goals, get AI-powered suggestions, and track your progress.',
//                           iconPath: 'assets/images/icons/goals_icon.png',
//                           onPressed: () => context.pushNamed(GoalsScreen.path),
//                         ),
//                         const Divider(color: AppColors.grey, height: 1),
//                         _buildToolItem(
//                           title: 'Debt Tracker',
//                           subtitle:
//                               'Stay on top of your debts and plan your payoff with ease.',
//                           iconPath: 'assets/images/icons/debt_icon.png',
//                           onPressed: () => context.pushNamed(DebtScreen.path),
//                         ),
//                         const Divider(color: AppColors.grey, height: 1),
//                         _buildToolItem(
//                           title: 'Tax',
//                           subtitle:
//                               'Calculate your tax and track your earnings with ease.',
//                           iconPath: 'assets/images/icons/tax_icon.png',
//                           onPressed: () =>
//                               context.pushNamed(TaxationDashboardScreen.path),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Small loading indicator (only during initial fetch) ───────────
//           if (isLoading)
//             const Positioned(
//               top: 16,
//               right: 24,
//               child: SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
//                 ),
//               ),
//             ),

//           // ── Error overlay ── only shown on real error ────────────────────
//           if (hasError)
//             CustomErrorWidget(
//               icon: Icons.person_outline,
//               title: 'Unable to Load User Info',
//               subtitle:
//                   'We couldn’t fetch your account data. Please check your connection and try again.',
//               actionButtonText: 'Retry',
//               onActionPressed: () {
//                 ref.invalidate(homeDataProvider);
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToolItem({
//     required String title,
//     required String subtitle,
//     required String iconPath,
//     VoidCallback? onPressed,
//   }) {
//     return InkWell(
//       onTap: onPressed,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Row(
//           children: [
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: AppColors.grey.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               // item image
//               child: Center(
//                 child: Image.asset(
//                   iconPath,
//                   width: 37,
//                   height: 37,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const Gap(16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Gap(4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.grey,
//                       height: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Gap(8),
//             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
//           ],
//         ),
//       ),
//     );
//   }

//   AppBar _buildAppBar(String firstName, BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.topRight,
//             colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
//           ),
//         ),
//       ),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Left side
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               InkWell(
//                 onTap: () => context.pushNamed(ChatScreen.path),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: AppColors.primary),
//                       ),
//                       child: Center(
//                         child: Image.asset(
//                           'assets/images/topbar/nav-left-icon.png',
//                           width: 32,
//                           height: 32,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     const Text(
//                       'Chat with Nahl',
//                       style: TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 25),
//               Image.asset(
//                 'assets/images/topbar/nav-center-icon.png',
//                 width: 30,
//                 height: 32,
//                 fit: BoxFit.contain,
//               ),
//             ],
//           ),

//           // Right side - profile avatar
//           GestureDetector(
//             onTap: () => context.pushNamed(ProfileScreen.path),
//             child: Row(
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.black, width: 1),
//                   ),
//                   child: Center(
//                     child: Text(
//                       firstName.isNotEmpty
//                           ? (firstName.length > 1
//                                 ? firstName.substring(0, 2).toUpperCase()
//                                 : firstName[0].toUpperCase())
//                           : 'Me',
//                       style: const TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       centerTitle: false,
//       automaticallyImplyLeading: false,
//     );
//   }

//   Widget _buildHealthJarFAB(String statusText) {
//     final healthImage = _getHealthImage(statusText);

//     return FloatingActionButton(
//       onPressed: () => _showHealthPopup(statusText),
//       backgroundColor: Colors.transparent,
//       elevation: 4,
//       shape: const CircleBorder(),
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Color(0xFFFFEFB5),
//           border: Border.all(color: Color(0xFFFFC300), width: 1),
//         ),
//         child: Image.asset(
//           healthImage,
//           fit: BoxFit.contain,
//           width: 40,
//           height: 40,
//         ),
//       ),
//     );
//   }
// }