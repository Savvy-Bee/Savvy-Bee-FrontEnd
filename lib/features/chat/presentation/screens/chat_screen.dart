import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // XFile
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
import 'package:savvy_bee_mobile/core/utils/file_picker_util.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/chat/data/services/nahl_consent_service.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/providers/chat_providers.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/chat_bubble_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/nahl_consent_blocked_view.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/nahl_consent_dialog.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/picked_file_preview.dart';

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

/// Represents the current view mode of the chat screen
enum ChatViewMode {
  /// Empty state - no messages, show welcome screen
  newChat,

  /// Active chat - messages are present, show chat interface
  activeChat,

  /// Chat history list - show list of previous conversations
  chatHistory,
}

class ChatScreen extends ConsumerStatefulWidget {
  static const String path = '/chat';

  /// Optional: pass chat ID to load specific conversation
  final String? chatId;

  const ChatScreen({super.key, this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // Local state
  XFile? _pickedFile;
  ChatViewMode _viewMode = ChatViewMode.newChat;
  bool _isInitialized = false;

  /// null = consent check not yet complete
  /// true  = user granted consent
  /// false = user declined consent
  bool? _consentGranted;

  // Constants
  static const Set<String> _quickActions = {
    'Heal me',
    'Analyse me',
    'Upload Receipt',
    'Assistant',
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ── 1. Resolve consent before doing anything else ──────────────────
      final alreadyConsented = await NahlConsentService.hasConsent();

      if (alreadyConsented) {
        // Previously granted — skip dialog entirely
        setState(() => _consentGranted = true);
      } else {
        // First visit (or consent cleared) — show dialog, block until chosen
        if (!mounted) return;
        final agreed = await showNahlConsentDialog(context);
        final granted = agreed == true;
        await NahlConsentService.saveConsent(granted);
        if (mounted) setState(() => _consentGranted = granted);
      }

      // ── 2. Only initialise chat data when consent is granted ───────────
      if (_consentGranted == true) {
        ref.invalidate(myPersonaProvider);

        if (widget.chatId != null && widget.chatId!.isNotEmpty) {
          await _loadChatById(widget.chatId!);
        } else {
          ref.read(chatProvider.notifier).refresh();
        }
      }

      _isInitialized = true;
      MixpanelService.trackFirstFeatureUsed('NAHL');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ==================== State Management ====================

  Future<void> _loadChatById(String chatId) async {
    try {
      await ref.read(chatProvider.notifier).loadChatById(chatId);

      final chatState = ref.read(chatProvider).value;

      if (chatState == null) return;

      if (chatState.needsReAuth) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'Session expired. Please login again.',
            type: SnackbarType.error,
          );
        }
        return;
      }

      if (chatState.hasError) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            chatState.errorMessage ?? 'Failed to load chat',
            type: SnackbarType.error,
          );
        }
        return;
      }

      if (chatState.messages.isNotEmpty && mounted) {
        setState(() {
          _viewMode = ChatViewMode.activeChat;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Error loading chat',
          type: SnackbarType.error,
        );
      }
    }
  }

  ChatViewMode _determineViewMode(ChatState chatState) {
    if (_viewMode == ChatViewMode.chatHistory) {
      return ChatViewMode.chatHistory;
    }
    if (chatState.messages.isNotEmpty) {
      return ChatViewMode.activeChat;
    }
    return ChatViewMode.newChat;
  }

  void _showChatHistory() {
    setState(() {
      _viewMode = ChatViewMode.chatHistory;
    });
    ref.read(chatProvider.notifier).fetchChatHistory();
  }

  void _startNewChat() {
    setState(() {
      _viewMode = ChatViewMode.newChat;
    });
    ref.read(chatProvider.notifier).clearCurrentChat();
  }

  void _returnToActiveChat() {
    setState(() {
      _viewMode = ChatViewMode.activeChat;
    });
  }

  void _loadChatRoom(RoomData room) {
    _loadChatById(room.id);
  }

  // ==================== Message Handling ====================

  Future<void> _sendMessage() async {
    // Hard block: never transmit data without explicit consent
    if (_consentGranted != true) return;

    final message = _messageController.text.trim();

    if (message.isEmpty && _pickedFile == null) return;

    _messageController.clear();

    final (image, document) = _categorizeFile();

    final success = await ref
        .read(chatProvider.notifier)
        .sendMessage(
          message.isEmpty ? 'Sending attachment' : message,
          image: image,
          document: document,
        );

    if (success) {
      setState(() {
        _pickedFile = null;
        if (_viewMode == ChatViewMode.newChat) {
          _viewMode = ChatViewMode.activeChat;
        }
      });
      _scrollToBottom();
    } else {
      _messageController.text = message;
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to send message',
          type: SnackbarType.error,
        );
      }
    }
  }

  (XFile?, XFile?) _categorizeFile() {
    if (_pickedFile == null) return (null, null);
    // Use the filename (not the full path) for reliable extension checking on web
    final isImage = FileUtils.isImageXFile(_pickedFile!);
    return isImage ? (_pickedFile, null) : (null, _pickedFile);
  }

  void _sendQuickAction(String action) {
    _messageController.text = action;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==================== Action Handlers ====================

  void _handleBudgetAction(ChatMessage message) {
    final budgetData = ChatWidgetDataParser.parseBudgetData(message.otherData);
    if (budgetData != null && budgetData.isNotEmpty) {
      // Navigate to budget adjustment screen with data
    }
  }

  void _handleGoalAction(ChatMessage message) {
    final goalData = ChatWidgetDataParser.parseGoalData(message.otherData);
    if (goalData != null) {
      // Navigate to goal creation screen with pre-filled data
    }
  }

  void _handleClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ref.read(chatProvider.notifier).clearCurrentChat();
              setState(() {
                _viewMode = ChatViewMode.newChat;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontFamily: 'GeneralSans'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteChatRoom(RoomData room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete "${room.roomName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontFamily: 'GeneralSans'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'refresh':
        ref.read(chatProvider.notifier).refresh();
        break;
      case 'clear':
        _handleClearChat();
        break;
      case 'history':
        _showChatHistory();
        break;
    }
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    // ── Consent check in progress — show neutral loader ──────────────────
    if (_consentGranted == null) {
      return const Scaffold(body: CustomLoadingWidget(text: 'Loading...'));
    }

    // ── User declined — show blocked state with re-accept path ───────────
    if (_consentGranted == false) {
      return Scaffold(
        appBar: _buildAppBar(context, ChatState(), ChatViewMode.newChat),
        body: NahlConsentBlockedView(
          onConsentGranted: () {
            setState(() => _consentGranted = true);
            ref.invalidate(myPersonaProvider);
            ref.read(chatProvider.notifier).refresh();
          },
        ),
      );
    }

    // ── Consent granted — normal chat flow ────────────────────────────────
    final chatAsync = ref.watch(chatProvider);

    return chatAsync.when(
      data: (chatState) {
        final currentMode = _determineViewMode(chatState);

        return Scaffold(
          appBar: _buildAppBar(context, chatState, currentMode),
          body: chatState.isLoading && _isInitialized
              ? const CustomLoadingWidget(text: 'Loading chat...')
              : _buildChatView(chatState, currentMode),
        );
      },
      error: (error, stackTrace) => Scaffold(
        appBar: _buildAppBar(context, ChatState(), ChatViewMode.newChat),
        body: CustomErrorWidget.error(
          onRetry: () => ref.read(chatProvider.notifier).refresh(),
        ),
      ),
      loading: () =>
          const Scaffold(body: CustomLoadingWidget(text: 'Loading...')),
    );
  }

  Widget _buildChatView(ChatState chatState, ChatViewMode mode) {
    return Column(
      children: [
        _buildQuickActions(),
        const Gap(16),
        Expanded(child: _buildMainContent(chatState, mode)),
        if (mode != ChatViewMode.chatHistory)
          _buildMessageInputArea(chatState, mode),
      ],
    );
  }

  Widget _buildMainContent(ChatState chatState, ChatViewMode mode) {
    switch (mode) {
      case ChatViewMode.chatHistory:
        return _buildChatHistoryView(chatState);
      case ChatViewMode.activeChat:
        return _buildActiveChatView(chatState);
      case ChatViewMode.newChat:
        return _buildNewChatView();
    }
  }

  // ==================== App Bar ====================

  PreferredSize _buildAppBar(
    BuildContext context,
    ChatState chatState,
    ChatViewMode mode,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (mode == ChatViewMode.chatHistory)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: chatState.messages.isNotEmpty
                      ? _returnToActiveChat
                      : _startNewChat,
                )
              else
                const BackButton(),

              // ── Persona selector — fetches from API, resolves local image ──
              _buildPersonaSelector(),

              _buildMenuButton(mode),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Persona selector
  //
  // Watches [myPersonaProvider] → GET /auth/update/getmypersona
  // The returned Persona.id / Persona.name is matched against
  // [_kLocalPersonalities] so the correct character image and name are shown.
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPersonaSelector() {
    final personaAsync = ref.watch(myPersonaProvider);

    return InkWell(
      onTap: () => context.pushNamed(ChoosePersonalityScreen.path),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            personaAsync.when(
              // ── Loaded: resolve local image + name from API response ────
              data: (persona) {
                if (persona == null) {
                  return _personaSelectorContent(null, 'Select AI');
                }

                final local = _resolveLocalPersonality(
                  apiId: persona.id,
                  apiName: persona.name,
                );

                return _personaSelectorContent(
                  local['imagePath'],
                  local['name']!,
                );
              },

              // ── Loading: slim skeleton ──────────────────────────────────
              loading: () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _personaAvatar(null),
                  const Gap(8),
                  Container(
                    width: 48,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),

              // ── Error: fallback icon + tap-to-select label ──────────────
              error: (_, __) => _personaSelectorContent(null, 'Select AI'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the inner [avatar + name] row used in the loaded & error states.
  Widget _personaSelectorContent(String? imagePath, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _personaAvatar(imagePath),
        const Gap(8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            fontFamily: 'GeneralSans',
            letterSpacing: 12 * 0.02,
          ),
        ),
      ],
    );
  }

  /// Circular avatar — shows the character image when [imagePath] is non-null,
  /// otherwise falls back to the bot icon.
  Widget _personaAvatar(String? imagePath) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary),
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.asset(
                imagePath,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                // If the asset is missing for any reason, fall back to icon
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy,
                  size: 18,
                  color: AppColors.primary,
                ),
              )
            : const Icon(Icons.smart_toy, size: 18, color: AppColors.primary),
      ),
    );
  }

  // ==================== Menu ====================

  Widget _buildMenuButton(ChatViewMode mode) {
    return PopupMenuButton<String>(
      style: Constants.collapsedButtonStyle,
      icon: const Icon(Icons.more_vert),
      onSelected: _handleMenuAction,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 20),
              Gap(12.0),
              Text('Refresh'),
            ],
          ),
        ),
        if (mode != ChatViewMode.chatHistory)
          const PopupMenuItem(
            value: 'history',
            child: Row(
              children: [
                Icon(Icons.history, size: 20),
                Gap(12.0),
                Text('Chat History'),
              ],
            ),
          ),
        if (mode == ChatViewMode.activeChat)
          const PopupMenuItem(
            value: 'clear',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20),
                Gap(12.0),
                Text('Clear Current Chat'),
              ],
            ),
          ),
      ],
    );
  }

  // ==================== Quick Actions ====================

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 12,
          children: _quickActions
              .map((action) => _buildQuickActionItem(action))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String label) {
    return CustomCard(
      onTap: () {
        if (label.toLowerCase() == 'scan receipt') {
          FileUtils.pickFile().then((value) {
            setState(() => _pickedFile = value);
          });
          return;
        }
        _sendQuickAction(label);
      },
      height: 100,
      width: 100,
      borderRadius: 12,
      borderColor: AppColors.grey,
      bgColor: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.primaryDark,
              size: 16,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                letterSpacing: 12 * 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Chat History View ====================

  Widget _buildChatHistoryView(ChatState chatState) {
    final rooms = chatState.allRooms;
    const maxChats = 50;

    return RefreshIndicator(
      onRefresh: () => ref.read(chatProvider.notifier).fetchChatHistory(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildChatHistoryHeader(rooms.length, maxChats),
            const Gap(16),
            rooms.isEmpty
                ? _buildEmptyChatHistory()
                : _buildChatHistoryList(rooms),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistoryHeader(int currentCount, int maxCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'YOUR CHATS ($currentCount/$maxCount)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        InkWell(
          onTap: _startNewChat,
          child: const Text(
            'Start new chat',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              fontFamily: 'GeneralSans',
              letterSpacing: 12 * 0.02,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChatHistory() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const Gap(16),
          const Text(
            'No chat history yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
              fontFamily: 'GeneralSans',
              letterSpacing: 16 * 0.02,
            ),
          ),
          const Gap(8),
          const Text(
            'Start a conversation to see your chats here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              fontFamily: 'GeneralSans',
              letterSpacing: 14 * 0.02,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryList(List<RoomData> rooms) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rooms.asMap().entries.map((entry) {
          return _buildChatHistoryItem(
            room: entry.value,
            isLast: entry.key == rooms.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatHistoryItem({required RoomData room, bool isLast = false}) {
    final timeAgo = room.updatedAt.formatRelative();

    return InkWell(
      onTap: () => _loadChatRoom(room),
      child: Container(
        padding: const EdgeInsets.all(16).copyWith(top: 24),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.grey, width: 0.5),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    room.roomName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 16 * 0.02,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 12 * 0.02,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_outlined),
              onSelected: (value) {
                if (value == 'delete') {
                  _handleDeleteChatRoom(room);
                } else if (value == 'open') {
                  _loadChatRoom(room);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 20),
                      Gap(12.0),
                      Text('Open'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      Gap(12.0),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Active Chat View ====================

  Widget _buildActiveChatView(ChatState chatState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(8.0),
            itemCount: chatState.messages.length,
            separatorBuilder: (context, index) => const Gap(16),
            itemBuilder: (context, index) =>
                _buildMessageItem(chatState, index),
          ),
        ),
        if (chatState.isSending) ...[const Gap(6), _buildTypingIndicator()],
      ],
    );
  }

  Widget _buildMessageItem(ChatState chatState, int index) {
    final reversedIndex = chatState.messages.length - 1 - index;
    final message = chatState.messages[reversedIndex];

    final isFirst =
        reversedIndex == 0 ||
        chatState.messages[reversedIndex - 1].from != message.from;

    final isLast =
        reversedIndex == chatState.messages.length - 1 ||
        (reversedIndex + 1 < chatState.messages.length &&
            chatState.messages[reversedIndex + 1].from != message.from);

    return buildChatBubble(
      context: context,
      message: message,
      isFirst: isFirst,
      isLast: isLast,
      onBudgetAction: () => _handleBudgetAction(message),
      onGoalAction: () => _handleGoalAction(message),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryFaint,
            child: const Icon(
              Icons.smart_toy,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const Text(
            'Thinking...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'GeneralSans',
              letterSpacing: 16 * 0.02,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== New Chat View ====================

  Widget _buildNewChatView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyStateIcon(),
            const Gap(24.0),
            const Text(
              'Nahl Chat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                letterSpacing: 28 * 0.02,
              ),
            ),
            const Gap(16),
            const Text(
              'Start a conversation to see your Nahl chat history',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'GeneralSans',
                letterSpacing: 16 * 0.02,
              ),
            ),
            const Gap(24),
            CustomElevatedButton(
              text: 'View Chat History',
              icon: const Icon(Icons.history),
              isSmall: true,
              isFullWidth: false,
              buttonColor: CustomButtonColor.black,
              onPressed: _showChatHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateIcon() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Image.asset(Illustrations.familyBee, scale: 4),
    );
  }

  // ==================== Message Input Area ====================

  Widget _buildMessageInputArea(ChatState chatState, ChatViewMode mode) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!chatState.isSending && _pickedFile != null) _buildFilePreview(),
          if (!chatState.isSending && _pickedFile != null) const Gap(10),
          _buildInputField(chatState),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return Wrap(
      children: [
        PickedFilePreview(
          file: _pickedFile,
          onRemove: () => setState(() => _pickedFile = null),
        ),
      ],
    );
  }

  Widget _buildInputField(ChatState chatState) {
    return CustomTextFormField(
      controller: _messageController,
      hint: 'Start a message',
      isRounded: true,
      enabled: !chatState.isSending,
      showOutline: _pickedFile == null,
      textInputAction: TextInputAction.send,
      onFieldSubmitted: (_) => _sendMessage(),
      maxLines: 3,
      minLines: 1,
      prefixIcon: _buildAttachmentButton(chatState),
      suffixIcon: _buildSendButton(chatState),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildAttachmentButton(ChatState chatState) {
    return IconButton(
      icon: const Icon(Icons.add),
      constraints: const BoxConstraints(),
      onPressed: chatState.isSending
          ? null
          : () => FileUtils.pickFile().then((value) {
              setState(() => _pickedFile = value);
            }),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
        disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildSendButton(ChatState chatState) {
    final hasContent =
        _messageController.text.isNotEmpty || _pickedFile != null;

    return IconButton(
      icon: Icon(
        Icons.send_rounded,
        color: hasContent
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.2),
      ),
      onPressed: chatState.isSending
          ? null
          : () {
              if (hasContent) {
                _sendMessage();
              }
            },
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
// import 'package:savvy_bee_mobile/core/utils/file_picker_util.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
// import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/providers/chat_providers.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/widgets/chat_bubble_widget.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/widgets/picked_file_preview.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // Local personality catalogue used to resolve API persona → image + name
// // ─────────────────────────────────────────────────────────────────────────────

// const List<Map<String, String>> _kLocalPersonalities = [
//   {
//     'id': 'loan_pro',
//     'name': 'Dash',
//     'imagePath': 'assets/images/icons/dash.png',
//   },
//   {
//     'id': 'budgeting_bee',
//     'name': 'Penny',
//     'imagePath': 'assets/images/icons/penny.png',
//   },
//   {
//     'id': 'saving_star',
//     'name': 'Bloom',
//     'imagePath': 'assets/images/icons/bloom.png',
//   },
//   {
//     'id': 'big_dreamer',
//     'name': 'Susu',
//     'imagePath': 'assets/images/icons/susu.png',
//   },
//   {
//     'id': 'matching_bee',
//     'name': 'Luna',
//     'imagePath': 'assets/images/icons/luna.png',
//   },
//   {
//     'id': 'quiz_bee',
//     'name': 'Boo',
//     'imagePath': 'assets/images/icons/boo.png',
//   },
//   {
//     'id': 'scam_spotter',
//     'name': 'Loki',
//     'imagePath': 'assets/images/icons/loki.png',
//   },
// ];

// /// Resolves an API [Persona] to its matching local entry.
// ///
// /// Matching priority:
// ///   1. API `ID` (e.g. "Nurturing_Guide") normalised to snake_case vs local `id`
// ///   2. API `Name` (e.g. "Boo") case-insensitive vs local `name`
// ///
// /// Falls back to Boo if nothing matches.
// Map<String, String> _resolveLocalPersonality({
//   required String apiId,
//   required String apiName,
// }) {
//   print(apiId);
//   print(apiName);
//   // Normalise the API id: lowercase + replace spaces/hyphens with underscores
//   final normId   = apiId.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
//   final normName = apiName.toLowerCase().trim();

//   return _kLocalPersonalities.firstWhere(
//     (p) =>
//         p['id']!.toLowerCase() == normId ||
//         p['name']!.toLowerCase() == normName,
//     orElse: () => _kLocalPersonalities.firstWhere(
//       (p) => p['name']! == 'Boo',
//       orElse: () => _kLocalPersonalities.first,
//     ),
//   );
// }

// // ─────────────────────────────────────────────────────────────────────────────

// /// Represents the current view mode of the chat screen
// enum ChatViewMode {
//   /// Empty state - no messages, show welcome screen
//   newChat,

//   /// Active chat - messages are present, show chat interface
//   activeChat,

//   /// Chat history list - show list of previous conversations
//   chatHistory,
// }

// class ChatScreen extends ConsumerStatefulWidget {
//   static const String path = '/chat';

//   /// Optional: pass chat ID to load specific conversation
//   final String? chatId;

//   const ChatScreen({super.key, this.chatId});

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   // Controllers
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _messageController = TextEditingController();

//   // Local state
//   File? _pickedFile;
//   ChatViewMode _viewMode = ChatViewMode.newChat;
//   bool _isInitialized = false;

//   // Constants
//   static const Set<String> _quickActions = {
//     'Heal me',
//     'Analyse me',
//     'Upload Receipt',
//     'Assistant',
//   };

//   @override
// void initState() {
//   super.initState();

//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     // ── Force re-fetch of persona every time screen is opened ────────
//     ref.invalidate(myPersonaProvider);

//     // Also useful: refresh current chat if needed
//     if (widget.chatId != null && widget.chatId!.isNotEmpty) {
//       _loadChatById(widget.chatId!);
//     } else {
//       // Optional: refresh current active chat too
//       ref.read(chatProvider.notifier).refresh();
//     }

//     _isInitialized = true;
//   });

//   MixpanelService.trackFirstFeatureUsed('NAHL');
// }

//   // @override
//   // void initState() {
//   //   super.initState();

//   //   // Load specific chat if chatId is provided
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (widget.chatId != null && widget.chatId!.isNotEmpty) {
//   //       _loadChatById(widget.chatId!);
//   //     }
//   //     _isInitialized = true;
//   //   });

//   //   MixpanelService.trackFirstFeatureUsed('NAHL');
//   // }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   // ==================== State Management ====================

//   Future<void> _loadChatById(String chatId) async {
//     try {
//       await ref.read(chatProvider.notifier).loadChatById(chatId);

//       final chatState = ref.read(chatProvider).value;

//       if (chatState == null) return;

//       if (chatState.needsReAuth) {
//         if (mounted) {
//           CustomSnackbar.show(
//             context,
//             'Session expired. Please login again.',
//             type: SnackbarType.error,
//           );
//         }
//         return;
//       }

//       if (chatState.hasError) {
//         if (mounted) {
//           CustomSnackbar.show(
//             context,
//             chatState.errorMessage ?? 'Failed to load chat',
//             type: SnackbarType.error,
//           );
//         }
//         return;
//       }

//       if (chatState.messages.isNotEmpty && mounted) {
//         setState(() {
//           _viewMode = ChatViewMode.activeChat;
//         });
//         _scrollToBottom();
//       }
//     } catch (e) {
//       if (mounted) {
//         CustomSnackbar.show(
//           context,
//           'Error loading chat',
//           type: SnackbarType.error,
//         );
//       }
//     }
//   }

//   ChatViewMode _determineViewMode(ChatState chatState) {
//     if (_viewMode == ChatViewMode.chatHistory) {
//       return ChatViewMode.chatHistory;
//     }
//     if (chatState.messages.isNotEmpty) {
//       return ChatViewMode.activeChat;
//     }
//     return ChatViewMode.newChat;
//   }

//   void _showChatHistory() {
//     setState(() {
//       _viewMode = ChatViewMode.chatHistory;
//     });
//     ref.read(chatProvider.notifier).fetchChatHistory();
//   }

//   void _startNewChat() {
//     setState(() {
//       _viewMode = ChatViewMode.newChat;
//     });
//     ref.read(chatProvider.notifier).clearCurrentChat();
//   }

//   void _returnToActiveChat() {
//     setState(() {
//       _viewMode = ChatViewMode.activeChat;
//     });
//   }

//   void _loadChatRoom(RoomData room) {
//     _loadChatById(room.id);
//   }

//   // ==================== Message Handling ====================

//   Future<void> _sendMessage() async {
//     final message = _messageController.text.trim();

//     if (message.isEmpty && _pickedFile == null) return;

//     _messageController.clear();

//     final (image, document) = _categorizeFile();

//     final success = await ref.read(chatProvider.notifier).sendMessage(
//           message.isEmpty ? "Sending attachment" : message,
//           image: image,
//           document: document,
//         );

//     if (success) {
//       setState(() {
//         _pickedFile = null;
//         if (_viewMode == ChatViewMode.newChat) {
//           _viewMode = ChatViewMode.activeChat;
//         }
//       });
//       _scrollToBottom();
//     } else {
//       _messageController.text = message;
//       if (mounted) {
//         CustomSnackbar.show(
//           context,
//           'Failed to send message',
//           type: SnackbarType.error,
//         );
//       }
//     }
//   }

//   (File?, File?) _categorizeFile() {
//     if (_pickedFile == null) return (null, null);
//     final isImage = FileUtils.isImageFile(_pickedFile!.path.toLowerCase());
//     return isImage ? (_pickedFile, null) : (null, _pickedFile);
//   }

//   void _sendQuickAction(String action) {
//     _messageController.text = action;
//     _sendMessage();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.minScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   // ==================== Action Handlers ====================

//   void _handleBudgetAction(ChatMessage message) {
//     final budgetData = ChatWidgetDataParser.parseBudgetData(message.otherData);
//     if (budgetData != null && budgetData.isNotEmpty) {
//       // Navigate to budget adjustment screen with data
//     }
//   }

//   void _handleGoalAction(ChatMessage message) {
//     final goalData = ChatWidgetDataParser.parseGoalData(message.otherData);
//     if (goalData != null) {
//       // Navigate to goal creation screen with pre-filled data
//     }
//   }

//   void _handleClearChat() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear Chat History'),
//         content: const Text(
//           'Are you sure you want to clear all messages? This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               context.pop();
//               ref.read(chatProvider.notifier).clearCurrentChat();
//               setState(() {
//                 _viewMode = ChatViewMode.newChat;
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Chat cleared'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//             child: const Text(
//               'Clear',
//               style: TextStyle(color: Colors.red, fontFamily: 'GeneralSans'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleDeleteChatRoom(RoomData room) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Chat'),
//         content: Text('Are you sure you want to delete "${room.roomName}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               context.pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Chat deleted'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(color: Colors.red, fontFamily: 'GeneralSans'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleMenuAction(String value) {
//     switch (value) {
//       case 'refresh':
//         ref.read(chatProvider.notifier).refresh();
//         break;
//       case 'clear':
//         _handleClearChat();
//         break;
//       case 'history':
//         _showChatHistory();
//         break;
//     }
//   }

//   // ==================== Build Methods ====================

//   @override
//   Widget build(BuildContext context) {
//     final chatAsync = ref.watch(chatProvider);

//     return chatAsync.when(
//       data: (chatState) {
//         final currentMode = _determineViewMode(chatState);

//         return Scaffold(
//           appBar: _buildAppBar(context, chatState, currentMode),
//           body: chatState.isLoading && _isInitialized
//               ? const CustomLoadingWidget(text: 'Loading chat...')
//               : _buildChatView(chatState, currentMode),
//         );
//       },
//       error: (error, stackTrace) => Scaffold(
//         appBar: _buildAppBar(context, ChatState(), ChatViewMode.newChat),
//         body: CustomErrorWidget.error(
//           onRetry: () => ref.read(chatProvider.notifier).refresh(),
//         ),
//       ),
//       loading: () =>
//           const Scaffold(body: CustomLoadingWidget(text: 'Loading...')),
//     );
//   }

//   Widget _buildChatView(ChatState chatState, ChatViewMode mode) {
//     return Column(
//       children: [
//         _buildQuickActions(),
//         const Gap(16),
//         Expanded(child: _buildMainContent(chatState, mode)),
//         if (mode != ChatViewMode.chatHistory)
//           _buildMessageInputArea(chatState, mode),
//       ],
//     );
//   }

//   Widget _buildMainContent(ChatState chatState, ChatViewMode mode) {
//     switch (mode) {
//       case ChatViewMode.chatHistory:
//         return _buildChatHistoryView(chatState);
//       case ChatViewMode.activeChat:
//         return _buildActiveChatView(chatState);
//       case ChatViewMode.newChat:
//         return _buildNewChatView();
//     }
//   }

//   // ==================== App Bar ====================

//   PreferredSize _buildAppBar(
//     BuildContext context,
//     ChatState chatState,
//     ChatViewMode mode,
//   ) {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(90),
//       child: Container(
//         color: AppColors.background,
//         child: SafeArea(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               if (mode == ChatViewMode.chatHistory)
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: chatState.messages.isNotEmpty
//                       ? _returnToActiveChat
//                       : _startNewChat,
//                 )
//               else
//                 const BackButton(),

//               // ── Persona selector — fetches from API, resolves local image ──
//               _buildPersonaSelector(),

//               _buildMenuButton(mode),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Persona selector
//   //
//   // Watches [myPersonaProvider] → GET /auth/update/getmypersona
//   // The returned Persona.id / Persona.name is matched against
//   // [_kLocalPersonalities] so the correct character image and name are shown.
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildPersonaSelector() {
//     final personaAsync = ref.watch(myPersonaProvider);

//     return InkWell(
//       onTap: () => context.pushNamed(ChoosePersonalityScreen.path),
//       borderRadius: BorderRadius.circular(20),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             personaAsync.when(
//               // ── Loaded: resolve local image + name from API response ────
//               data: (persona) {
//                 if (persona == null) return _personaSelectorContent(null, 'Select AI');

//                 final local = _resolveLocalPersonality(
//                   apiId: persona.id,
//                   apiName: persona.name,
//                 );

//                 return _personaSelectorContent(
//                   local['imagePath'],
//                   local['name']!,
//                 );
//               },

//               // ── Loading: slim skeleton ──────────────────────────────────
//               loading: () => Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _personaAvatar(null),
//                   const Gap(8),
//                   Container(
//                     width: 48,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                 ],
//               ),

//               // ── Error: fallback icon + tap-to-select label ──────────────
//               error: (_, __) => _personaSelectorContent(null, 'Select AI'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Builds the inner [avatar + name] row used in the loaded & error states.
//   Widget _personaSelectorContent(String? imagePath, String name) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _personaAvatar(imagePath),
//         const Gap(8),
//         Text(
//           name,
//           style: const TextStyle(
//             fontSize: 12.0,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'GeneralSans',
//             letterSpacing: 12 * 0.02,
//           ),
//         ),
//       ],
//     );
//   }

//   /// Circular avatar — shows the character image when [imagePath] is non-null,
//   /// otherwise falls back to the bot icon.
//   Widget _personaAvatar(String? imagePath) {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: AppColors.primary.withValues(alpha: 0.1),
//         border: Border.all(color: AppColors.primary),
//       ),
//       child: ClipOval(
//         child: imagePath != null
//             ? Image.asset(
//                 imagePath,
//                 width: 32,
//                 height: 32,
//                 fit: BoxFit.cover,
//                 // If the asset is missing for any reason, fall back to icon
//                 errorBuilder: (_, __, ___) => const Icon(
//                   Icons.smart_toy,
//                   size: 18,
//                   color: AppColors.primary,
//                 ),
//               )
//             : const Icon(
//                 Icons.smart_toy,
//                 size: 18,
//                 color: AppColors.primary,
//               ),
//       ),
//     );
//   }

//   // ==================== Menu ====================

//   Widget _buildMenuButton(ChatViewMode mode) {
//     return PopupMenuButton<String>(
//       style: Constants.collapsedButtonStyle,
//       icon: const Icon(Icons.more_vert),
//       onSelected: _handleMenuAction,
//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: 'refresh',
//           child: Row(
//             children: [
//               Icon(Icons.refresh, size: 20),
//               Gap(12.0),
//               Text('Refresh'),
//             ],
//           ),
//         ),
//         if (mode != ChatViewMode.chatHistory)
//           const PopupMenuItem(
//             value: 'history',
//             child: Row(
//               children: [
//                 Icon(Icons.history, size: 20),
//                 Gap(12.0),
//                 Text('Chat History'),
//               ],
//             ),
//           ),
//         if (mode == ChatViewMode.activeChat)
//           const PopupMenuItem(
//             value: 'clear',
//             child: Row(
//               children: [
//                 Icon(Icons.delete_outline, size: 20),
//                 Gap(12.0),
//                 Text('Clear Current Chat'),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   // ==================== Quick Actions ====================

//   Widget _buildQuickActions() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           spacing: 12,
//           children: _quickActions
//               .map((action) => _buildQuickActionItem(action))
//               .toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActionItem(String label) {
//     return CustomCard(
//       onTap: () {
//         if (label.toLowerCase() == "scan receipt") {
//           FileUtils.pickFile().then((value) {
//             setState(() => _pickedFile = value);
//           });
//           return;
//         }
//         _sendQuickAction(label);
//       },
//       height: 100,
//       width: 100,
//       borderRadius: 12,
//       borderColor: AppColors.grey,
//       bgColor: AppColors.background,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           spacing: 16,
//           children: [
//             const Icon(
//               Icons.auto_awesome_outlined,
//               color: AppColors.primaryDark,
//               size: 16,
//             ),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 12.0,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'GeneralSans',
//                 letterSpacing: 12 * 0.02,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== Chat History View ====================

//   Widget _buildChatHistoryView(ChatState chatState) {
//     final rooms = chatState.allRooms;
//     const maxChats = 50;

//     return RefreshIndicator(
//       onRefresh: () => ref.read(chatProvider.notifier).fetchChatHistory(),
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           children: [
//             _buildChatHistoryHeader(rooms.length, maxChats),
//             const Gap(16),
//             rooms.isEmpty
//                 ? _buildEmptyChatHistory()
//                 : _buildChatHistoryList(rooms),
//             const Gap(24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChatHistoryHeader(int currentCount, int maxCount) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'YOUR CHATS ($currentCount/$maxCount)',
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//         ),
//         InkWell(
//           onTap: _startNewChat,
//           child: const Text(
//             'Start new chat',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               decoration: TextDecoration.underline,
//               fontFamily: 'GeneralSans',
//               letterSpacing: 12 * 0.02,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyChatHistory() {
//     return Container(
//       padding: const EdgeInsets.all(32.0),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.chat_bubble_outline,
//             size: 48,
//             color: AppColors.grey.withValues(alpha: 0.5),
//           ),
//           const Gap(16),
//           const Text(
//             'No chat history yet',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: AppColors.grey,
//               fontFamily: 'GeneralSans',
//               letterSpacing: 16 * 0.02,
//             ),
//           ),
//           const Gap(8),
//           const Text(
//             'Start a conversation to see your chats here',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.grey,
//               fontFamily: 'GeneralSans',
//               letterSpacing: 14 * 0.02,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatHistoryList(List<RoomData> rooms) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: rooms.asMap().entries.map((entry) {
//           return _buildChatHistoryItem(
//             room: entry.value,
//             isLast: entry.key == rooms.length - 1,
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildChatHistoryItem({required RoomData room, bool isLast = false}) {
//     final timeAgo = room.updatedAt.formatRelative();

//     return InkWell(
//       onTap: () => _loadChatRoom(room),
//       child: Container(
//         padding: const EdgeInsets.all(16).copyWith(top: 24),
//         decoration: BoxDecoration(
//           border: isLast
//               ? null
//               : const Border(
//                   bottom: BorderSide(color: AppColors.grey, width: 0.5),
//                 ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           spacing: 24,
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 spacing: 8,
//                 children: [
//                   Text(
//                     room.roomName,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       fontFamily: 'GeneralSans',
//                       letterSpacing: 16 * 0.02,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     timeAgo,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.grey,
//                       fontFamily: 'GeneralSans',
//                       letterSpacing: 12 * 0.02,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             PopupMenuButton<String>(
//               icon: const Icon(Icons.more_horiz_outlined),
//               onSelected: (value) {
//                 if (value == 'delete') {
//                   _handleDeleteChatRoom(room);
//                 } else if (value == 'open') {
//                   _loadChatRoom(room);
//                 }
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'open',
//                   child: Row(
//                     children: [
//                       Icon(Icons.open_in_new, size: 20),
//                       Gap(12.0),
//                       Text('Open'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete_outline, size: 20, color: Colors.red),
//                       Gap(12.0),
//                       Text(
//                         'Delete',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontFamily: 'GeneralSans',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== Active Chat View ====================

//   Widget _buildActiveChatView(ChatState chatState) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: ListView.separated(
//             controller: _scrollController,
//             reverse: true,
//             padding: const EdgeInsets.all(8.0),
//             itemCount: chatState.messages.length,
//             separatorBuilder: (context, index) => const Gap(16),
//             itemBuilder: (context, index) =>
//                 _buildMessageItem(chatState, index),
//           ),
//         ),
//         if (chatState.isSending) ...[const Gap(6), _buildTypingIndicator()],
//       ],
//     );
//   }

//   Widget _buildMessageItem(ChatState chatState, int index) {
//     final reversedIndex = chatState.messages.length - 1 - index;
//     final message = chatState.messages[reversedIndex];

//     final isFirst = reversedIndex == 0 ||
//         chatState.messages[reversedIndex - 1].from != message.from;

//     final isLast = reversedIndex == chatState.messages.length - 1 ||
//         (reversedIndex + 1 < chatState.messages.length &&
//             chatState.messages[reversedIndex + 1].from != message.from);

//     return buildChatBubble(
//       context: context,
//       message: message,
//       isFirst: isFirst,
//       isLast: isLast,
//       onBudgetAction: () => _handleBudgetAction(message),
//       onGoalAction: () => _handleGoalAction(message),
//     );
//   }

//   Widget _buildTypingIndicator() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         spacing: 8.0,
//         children: [
//           CircleAvatar(
//             backgroundColor: AppColors.primaryFaint,
//             child: const Icon(
//               Icons.smart_toy,
//               size: 18,
//               color: AppColors.primary,
//             ),
//           ),
//           const Text(
//             'Thinking...',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: 'GeneralSans',
//               letterSpacing: 16 * 0.02,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== New Chat View ====================

//   Widget _buildNewChatView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildEmptyStateIcon(),
//             const Gap(24.0),
//             const Text(
//               'Nahl Chat',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'GeneralSans',
//                 letterSpacing: 28 * 0.02,
//               ),
//             ),
//             const Gap(16),
//             const Text(
//               'Start a conversation to see your Nahl chat history',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontFamily: 'GeneralSans',
//                 letterSpacing: 16 * 0.02,
//               ),
//             ),
//             const Gap(24),
//             CustomElevatedButton(
//               text: 'View Chat History',
//               icon: const Icon(Icons.history),
//               isSmall: true,
//               isFullWidth: false,
//               buttonColor: CustomButtonColor.black,
//               onPressed: _showChatHistory,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyStateIcon() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: AppColors.primary.withValues(alpha: 0.1),
//       ),
//       child: Image.asset(Illustrations.familyBee, scale: 4),
//     );
//   }

//   // ==================== Message Input Area ====================

//   Widget _buildMessageInputArea(ChatState chatState, ChatViewMode mode) {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       margin: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (!chatState.isSending && _pickedFile != null) _buildFilePreview(),
//           if (!chatState.isSending && _pickedFile != null) const Gap(10),
//           _buildInputField(chatState),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilePreview() {
//     return Wrap(
//       children: [
//         PickedFilePreview(
//           file: _pickedFile,
//           onRemove: () => setState(() => _pickedFile = null),
//         ),
//       ],
//     );
//   }

//   Widget _buildInputField(ChatState chatState) {
//     return CustomTextFormField(
//       controller: _messageController,
//       hint: 'Start a message',
//       isRounded: true,
//       enabled: !chatState.isSending,
//       showOutline: _pickedFile == null,
//       textInputAction: TextInputAction.send,
//       onFieldSubmitted: (_) => _sendMessage(),
//       maxLines: 3,
//       minLines: 1,
//       prefixIcon: _buildAttachmentButton(chatState),
//       suffixIcon: _buildSendButton(chatState),
//       onChanged: (_) => setState(() {}),
//     );
//   }

//   Widget _buildAttachmentButton(ChatState chatState) {
//     return IconButton(
//       icon: const Icon(Icons.add),
//       constraints: const BoxConstraints(),
//       onPressed: chatState.isSending
//           ? null
//           : () => FileUtils.pickFile().then((value) {
//                 setState(() => _pickedFile = value);
//               }),
//       style: IconButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
//         disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
//         visualDensity: VisualDensity.compact,
//         backgroundColor: AppColors.primary.withValues(alpha: 0.1),
//       ),
//     );
//   }

//   Widget _buildSendButton(ChatState chatState) {
//     final hasContent =
//         _messageController.text.isNotEmpty || _pickedFile != null;

//     return IconButton(
//       icon: Icon(
//         Icons.send_rounded,
//         color: hasContent
//             ? AppColors.primary
//             : AppColors.primary.withValues(alpha: 0.2),
//       ),
//       onPressed: chatState.isSending
//           ? null
//           : () {
//               if (hasContent) {
//                 _sendMessage();
//               }
//             },
//     );
//   }
// }
