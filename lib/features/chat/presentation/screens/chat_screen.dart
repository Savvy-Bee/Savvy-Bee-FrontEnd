import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/file_picker_util.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_bubble_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/bottom_sheets/create_goal_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/picked_file_preview.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/quick_action_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/providers/chat_providers.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/choose_personality_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static String path = '/chat';

  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  File? _pickedFile;

  final Set<String> _quickActions = {
    'Heal me',
    'Analyse me',
    'Scan Receipt',
    'Smart assistant',
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

    _messageController.clear();

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
        appBar: _buildAppBar(context, chatState.persona?.name ?? '____'),
        body: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryFaint.withValues(alpha: 0.3),
            image: DecorationImage(
              image: AssetImage(Assets.hivePatternYellow),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildChatView(chatState),
        ),
      ),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Error loading chat'))),
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
    );

    // return Scaffold(
    //   appBar: _buildAppBar(context),
    //   body: Container(
    //     decoration: BoxDecoration(
    //       color: AppColors.primaryFaint.withValues(alpha: 0.3),
    //       image: DecorationImage(
    //         image: AssetImage(Assets.hivePatternYellow),
    //         fit: BoxFit.cover,
    //       ),
    //     ),
    //     child: chatAsync.when(
    //       loading: () => _buildLoadingView(),
    //       error: (error, stack) => _buildErrorView(error.toString()),
    //       data: (chatState) => _buildChatView(chatState),
    //     ),
    //   ),
    // );
  }

  /// Build main chat view
  Widget _buildChatView(ChatState chatState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Messages list
        Expanded(
          child: chatState.isEmpty
              ? _buildEmptyState()
              : Column(
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

        if (!chatState.isSending && _pickedFile == null) _buildQuickActions(),

        // Message input
        _buildTextField(chatState),
      ],
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
    return Container(
      color: AppColors.primaryFaint.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Gap(10.0),
          Row(
            children: [
              Text(
                'Quick actions',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
              ),
              const Gap(2.0),
              Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.primaryDark,
                size: 16,
              ),
            ],
          ),
          const Gap(10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickActions
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: QuickActionWidget(
                        icon: Icon(
                          Icons.auto_awesome_outlined,
                          color: AppColors.primaryDark,
                          size: 16,
                        ),
                        label: action,
                        onTap: () => _sendQuickAction(action),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
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
            prefix: IconButton(
              icon: const Icon(Icons.add),
              constraints: BoxConstraints(),
              onPressed: () => CreateGoalBottomSheet.show(context),
              // onPressed: chatState.isSending
              //     ? null
              //     : () => FileUtils.pickFile().then((value) {
              //         setState(() {
              //           _pickedFile = value;
              //         });
              //       }),
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
            suffix: IconButton(
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
  Widget _buildEmptyState() {
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
              'Meet NAHL',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Gap(8.0),
            Text(
              'Your AI financial assistant is here to help you manage your money better',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const Gap(32.0),
            const Text(
              'Try asking:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackButton(),
              InkWell(
                onTap: () => context.pushNamed(ChoosePersonalityScreen.path),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Image.asset(Illustrations.dashAvatar, scale: 1.4),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => ref.read(chatProvider.notifier).refresh(),
                    icon: Icon(Icons.swap_horiz),
                  ),
                  PopupMenuButton<String>(
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
                      const PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            Gap(12.0),
                            Text(
                              'Clear History',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
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
              Navigator.pop(context);
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
