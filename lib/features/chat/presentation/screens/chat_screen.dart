import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/file_picker_util.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/providers/chat_providers.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/chat_bubble_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/picked_file_preview.dart';

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
  File? _pickedFile;
  ChatViewMode _viewMode = ChatViewMode.newChat;

  // Constants
  static const Set<String> _quickActions = {
    'Heal me',
    'Analyse me',
    'Scan Receipt',
    'Assistant',
  };

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ==================== State Management ====================

  /// Determine the appropriate view mode based on chat state
  ChatViewMode _determineViewMode(ChatState chatState) {
    // If explicitly in history mode
    if (_viewMode == ChatViewMode.chatHistory) {
      return ChatViewMode.chatHistory;
    }

    // If there are messages, show active chat
    if (chatState.messages.isNotEmpty) {
      return ChatViewMode.activeChat;
    }

    // Otherwise, show new chat welcome screen
    return ChatViewMode.newChat;
  }

  /// Switch to chat history view
  void _showChatHistory() {
    setState(() {
      _viewMode = ChatViewMode.chatHistory;
    });
  }

  /// Start a new chat (from history view or anywhere else)
  void _startNewChat() {
    setState(() {
      _viewMode = ChatViewMode.newChat;
    });
    // Clear current chat if needed
    // ref.read(chatProvider.notifier).clearCurrentChat();
  }

  /// Return to active chat from history
  void _returnToActiveChat() {
    setState(() {
      _viewMode = ChatViewMode.activeChat;
    });
  }

  // ==================== Message Handling ====================

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty && _pickedFile == null) return;

    // Clear input immediately for better UX
    _messageController.clear();

    final (image, document) = _categorizeFile();

    final success = await ref
        .read(chatProvider.notifier)
        .sendMessage(
          message.isEmpty ? "Sending attachment" : message,
          image: image,
          document: document,
        );

    if (success) {
      setState(() {
        _pickedFile = null;
        // Switch to active chat mode after first message
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

  (File?, File?) _categorizeFile() {
    if (_pickedFile == null) return (null, null);

    final isImage = FileUtils.isImageFile(_pickedFile!.path.toLowerCase());
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
      // context.push('/budget/adjust', extra: budgetData);
    }
  }

  void _handleGoalAction(ChatMessage message) {
    final goalData = ChatWidgetDataParser.parseGoalData(message.otherData);

    if (goalData != null) {
      // Navigate to goal creation screen with pre-filled data
      // context.push('/goals/create', extra: goalData);
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
              ref.read(chatProvider.notifier).refresh();
              // ref.read(chatProvider.notifier).clearHistory(clearOnServer: true);
              setState(() {
                _viewMode = ChatViewMode.newChat;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat history cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
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
    final chatAsync = ref.watch(chatProvider);

    return chatAsync.when(
      data: (chatState) {
        // Determine current view mode
        final currentMode = _determineViewMode(chatState);

        return Scaffold(
          appBar: _buildAppBar(context, chatState, currentMode),
          body: _buildChatView(chatState, currentMode),
        );
      },
      error: (error, stackTrace) => Scaffold(
        appBar: _buildAppBar(context, ChatState(), ChatViewMode.newChat),
        body: CustomErrorWidget.error(
          onRetry: () => ref.read(chatProvider.notifier).refresh(),
        ),
      ),
      loading: () =>
          const Scaffold(body: CustomLoadingWidget(text: 'Loading chat...')),
    );
  }

  Widget _buildChatView(ChatState chatState, ChatViewMode mode) {
    return Column(
      children: [
        // Quick actions always visible at top
        _buildQuickActions(),
        const Gap(16),

        // Main content area
        Expanded(child: _buildMainContent(chatState, mode)),

        // Message input (only in new chat or active chat modes)
        if (mode != ChatViewMode.chatHistory)
          _buildMessageInputArea(chatState, mode),
      ],
    );
  }

  Widget _buildMainContent(ChatState chatState, ChatViewMode mode) {
    switch (mode) {
      case ChatViewMode.chatHistory:
        return _buildChatHistoryView();

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
              // Back button or menu button based on mode
              if (mode == ChatViewMode.chatHistory)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: chatState.messages.isNotEmpty
                      ? _returnToActiveChat
                      : _startNewChat,
                )
              else
                const BackButton(),

              // Persona selector
              _buildPersonaSelector(chatState.persona?.name ?? '-----'),

              // Menu
              _buildMenuButton(mode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaSelector(String personaName) {
    return InkWell(
      onTap: () => context.pushNamed(ChoosePersonalityScreen.path),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.primary),
            ),
          ),
          const Gap(8),
          Text(
            personaName,
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

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
              Text('Refresh Chat'),
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
                Text('Clear Chat'),
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
        if (label.toLowerCase() == "scan receipt") {
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Chat History View ====================

  Widget _buildChatHistoryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildChatHistoryHeader(),
          const Gap(16),
          _buildChatHistoryList(),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildChatHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'YOUR CHATS (2/50)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        InkWell(
          onTap: _startNewChat,
          child: const Text(
            'Start new chat',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatHistoryList() {
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
        children: [
          _buildChatHistoryItem(
            "Things You Need To Know About Nigeria's New Tax Reform",
            "2:18PM",
            onTap: () {
              // Load specific chat
              _returnToActiveChat();
            },
          ),
          _buildChatHistoryItem(
            "Budget Planning for Q1 2026",
            "Yesterday",
            isLast: true,
            onTap: () {
              // Load specific chat
              _returnToActiveChat();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryItem(
    String chatTitle,
    String chatTime, {
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                    chatTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    chatTime,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Show options for this chat item
              },
              icon: const Icon(Icons.more_horiz_outlined),
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
          CircleAvatar(backgroundColor: AppColors.primaryFaint),
          Text(
            'Thinking...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
            const Gap(16),
            const Text(
              'Start a conversation to see your Nahl chat history',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
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
    // Show simplified input in new chat mode, full input in active chat
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
        hasContent ? Icons.send_rounded : Icons.multitrack_audio_rounded,
        color: AppColors.primary,
      ),
      onPressed: chatState.isSending
          ? null
          : () {
              if (hasContent) {
                _sendMessage();
              } else {
                // Future: Add voice input functionality
              }
            },
    );
  }
}
