import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/file_picker_util.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_bubble_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/picked_file_preview.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/providers/chat_providers.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';

enum ChatScreenState { newChat, existingChat, chatHistory }

class ChatScreen extends ConsumerStatefulWidget {
  static const String path = '/chat';

  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  final ChatScreenState _chatScreenState = ChatScreenState.newChat;

  File? _pickedFile;

  final Set<String> _quickActions = {
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

  /// Scroll to bottom of chat
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

  /// Send message with optional attachments
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    // Check if we have either a message or a file
    if (message.isEmpty && _pickedFile == null) return;

    // _messageController.clear();

    // Determine file type (image or document)
    File? image;
    File? document;

    if (_pickedFile != null) {
      final path = _pickedFile!.path.toLowerCase();
      final isImage = FileUtils.isImageFile(path);

      if (isImage) {
        image = _pickedFile;
      } else {
        document = _pickedFile;
      }
    }

    final success = await ref
        .read(chatProvider.notifier)
        .sendMessage(
          message.isEmpty ? "Sending attachment" : message,
          image: image,
          document: document,
        );

    if (success) {
      // Clear the picked file
      setState(() {
        _pickedFile = null;
      });
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

    // Scroll to bottom after sending
    _scrollToBottom();
  }

  /// Send quick action message
  void _sendQuickAction(String action) {
    _messageController.text = action;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatProvider);

    return chatAsync.when(
      data: (chatState) => Scaffold(
        appBar: _buildAppBar(context, chatState.persona?.name ?? '-----'),
        body: _buildChatView(chatState),
      ),
      error: (error, stackTrace) => Scaffold(
        body: CustomErrorWidget.error(
          onRetry: () => ref.read(chatProvider.notifier).refresh(),
        ),
      ),
      loading: () =>
          Scaffold(body: const CustomLoadingWidget(text: 'Loading chat...')),
    );
  }

  /// Build main chat view
  Widget _buildChatView(ChatState chatState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuickActions(),
        if (_chatScreenState == ChatScreenState.chatHistory) ...[
          const Gap(32),
          _buildChatHistoryTitle(),
          const Gap(16),
          _buildChatHistoryCard(),
        ],

        if (chatState.isEmpty && _chatScreenState == ChatScreenState.newChat)
          _buildNewChatWidget(),
        // Messages list
        if (!chatState.isEmpty &&
            _chatScreenState == ChatScreenState.existingChat)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex =
                          chatState.messages.length - 1 - index;
                      final message = chatState.messages[reversedIndex];

                      final isFirst =
                          reversedIndex == 0 ||
                          chatState.messages[reversedIndex - 1].from !=
                              message.from;
                      final isLast =
                          reversedIndex == chatState.messages.length - 1 ||
                          (reversedIndex + 1 < chatState.messages.length &&
                              chatState.messages[reversedIndex + 1].from !=
                                  message.from);

                      return buildChatBubble(
                        context: context,
                        message: message,
                        isFirst: isFirst,
                        isLast: isLast,
                        onBudgetAction: () => _handleBudgetAction(message),
                        onGoalAction: () => _handleGoalAction(message),
                      );
                    },
                  ),
                ),

                // Typing indicator
                const Gap(6),
                if (chatState.isSending)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(children: [_buildTypingIndicator()]),
                  ),
              ],
            ),
          ),

        // Message input
        if (!chatState.isEmpty &&
            _chatScreenState == ChatScreenState.existingChat)
          _buildTextField(chatState),
      ],
    );
  }

  Container _buildChatHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChatHistoryItem(
            "Things You Need To Know About Nigeria's New Tax Reform",
            "2:18PM",
          ),
          _buildChatHistoryItem(
            "Things You Need To Know About Nigeria's New Tax Reform",
            "2:18PM",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Padding _buildChatHistoryTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'YOUR CHATS (2/50)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          InkWell(
            onTap: () {},
            child: Text(
              'Start new chat',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryItem(
    String chatTitle,
    String chatTime, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(top: 24),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.grey, width: 0.5)),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  chatTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz_outlined)),
        ],
      ),
    );
  }

  void _handleBudgetAction(ChatMessage message) {
    // Parse budget data if needed
    final budgetData = ChatWidgetDataParser.parseBudgetData(message.otherData);

    if (budgetData != null && budgetData.isNotEmpty) {
      // Navigate to budget adjustment screen with data
      // context.push('/budget/adjust', extra: budgetData);

      // Or show a bottom sheet
      // showModalBottomSheet(
      //   context: context,
      //   builder: (context) =>
      //       BudgetAdjustmentBottomSheet(budgetData: budgetData),
      // );
    }
  }

  void _handleGoalAction(ChatMessage message) {
    // Parse goal data if needed
    final goalData = ChatWidgetDataParser.parseGoalData(message.otherData);

    if (goalData != null) {
      // Navigate to goal creation screen with pre-filled data
      // context.push('/goals/create', extra: goalData);

      // Or show a bottom sheet
      // showModalBottomSheet(
      //   context: context,
      //   isScrollControlled: true,
      //   builder: (context) => GoalCreationBottomSheet(suggestedGoal: goalData),
      // );
    }
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 12,
          children: _quickActions
              .map(
                (action) => _buildQuickActionItem(
                  icon: Icon(
                    Icons.auto_awesome_outlined,
                    color: AppColors.primaryDark,
                    size: 16,
                  ),
                  label: action,
                  onTap: () => _sendQuickAction(action),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// Build quick action item
  Widget _buildQuickActionItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
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
            icon,
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

  /// Build typing indicator
  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.primaryFaint,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: LoadingAnimationWidget.waveDots(
        color: AppColors.primaryDark,
        size: 20,
      ),
    );
  }

  /// Build message input field
  Widget _buildTextField(ChatState chatState) {
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
          if (!chatState.isSending && _pickedFile != null)
            Wrap(
              children: [
                PickedFilePreview(
                  file: _pickedFile,
                  onRemove: () {
                    setState(() {
                      _pickedFile = null;
                    });
                  },
                ),
              ],
            ),
          const Gap(10),
          CustomTextFormField(
            controller: _messageController,
            hint: 'Start a message',
            isRounded: true,
            enabled: !chatState.isSending,
            showOutline: _pickedFile == null,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _sendMessage(),
            maxLines: 3,
            minLines: 1,
            prefixIcon: IconButton(
              icon: const Icon(Icons.add),
              constraints: BoxConstraints(),
              // onPressed: () => CreateGoalBottomSheet.show(context),
              onPressed: chatState.isSending
                  ? null
                  : () => FileUtils.pickFile().then((value) {
                      setState(() {
                        _pickedFile = value;
                      });
                    }),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.1,
                ),
                disabledForegroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            suffixIcon: IconButton(
              icon: _messageController.text.isNotEmpty || _pickedFile != null
                  ? const Icon(Icons.send_rounded, color: AppColors.primary)
                  : const Icon(
                      Icons.multitrack_audio_rounded,
                      color: AppColors.primary,
                    ),
              onPressed: chatState.isSending
                  ? null
                  : () {
                      if (_messageController.text.isNotEmpty ||
                          _pickedFile != null) {
                        _sendMessage();
                      } else {
                        // showModalBottomSheet(
                        //   context: context,
                        //   builder: (context) => AddBudgetCategoryBottomSheet(),
                        // );
                        // Future: Add voice input functionality
                      }
                    },
            ),
            onChanged: (value) {
              setState(() {}); // Update suffix icon
            },
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildNewChatWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Image.asset(Illustrations.familyBee, scale: 4),
            ),
            const Gap(24.0),
            const Text(
              'Nahl Chat',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
            const Gap(16),
            Text(
              'Start a conversation to see your Nahl chat history',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Gap(16),
            CustomElevatedButton(
              text: 'Start conversation',
              icon: Icon(Icons.add),
              isSmall: true,
              isFullWidth: false,
              buttonColor: CustomButtonColor.black,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  /// Build app bar
  PreferredSize _buildAppBar(BuildContext context, String personaName) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BackButton(),
              InkWell(
                onTap: () => context.pushNamed(ChoosePersonalityScreen.path),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.primary),
                      ),
                      // child: Image.asset(
                      //   Illustrations.avatars.firstWhere(
                      //     (element) => element.toLowerCase().contains(
                      //       personaName.toLowerCase(),
                      //     ),
                      //   ),
                      //   scale: 1.5,
                      // ),
                    ),
                    Text(
                      personaName,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                style: Constants.collapsedButtonStyle,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'refresh':
                      ref.read(chatProvider.notifier).refresh();
                      break;
                    case 'clear':
                      _showClearConfirmation();
                      break;
                  }
                },
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show clear confirmation dialog
  void _showClearConfirmation() {
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
              // ref.read(chatProvider.notifier).clearHistory(clearOnServer: true);
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
}
