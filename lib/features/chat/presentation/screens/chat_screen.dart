import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readmore/readmore.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets.dart';
import 'package:savvy_bee_mobile/core/utils/file_picker_util.dart';
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
      final isImage = FilePickerUtil.isImageFile(path);

      if (isImage) {
        image = _pickedFile;
      } else {
        document = _pickedFile;
      }
    }

    await ref
        .read(chatProvider.notifier)
        .sendMessage(
          message.isEmpty ? "Sending attachment" : message,
          image: image,
          document: document,
        );

    // Clear the picked file
    setState(() {
      _pickedFile = null;
    });

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

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryFaint.withValues(alpha: 0.3),
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternYellow),
            fit: BoxFit.cover,
          ),
        ),
        child: chatAsync.when(
          loading: () => _buildLoadingView(),
          error: (error, stack) => _buildErrorView(error.toString()),
          data: (chatState) => _buildChatView(chatState),
        ),
      ),
    );
  }

  /// Build main chat view
  Widget _buildChatView(ChatState chatState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
                          // Reverse index since list is reversed
                          final reversedIndex =
                              chatState.messages.length - 1 - index;
                          final message = chatState.messages[reversedIndex];

                          // Determine bubble styling based on sequence
                          final isFirst =
                              reversedIndex == 0 ||
                              chatState.messages[reversedIndex - 1].from !=
                                  message.from;
                          final isLast =
                              reversedIndex == chatState.messages.length - 1 ||
                              (reversedIndex + 1 < chatState.messages.length &&
                                  chatState.messages[reversedIndex + 1].from !=
                                      message.from);

                          return _buildChatBubble(
                            message: message,
                            isFirst: isFirst,
                            isLast: isLast,
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

        // Quick actions
        if (!chatState.isSending && _pickedFile != null)
          _buildPickedFilePreview(),
        if (!chatState.isSending && _pickedFile == null) _buildQuickActions(),

        // Message input
        _buildTextField(chatState),
      ],
    );
  }

  Widget _buildPickedFilePreview() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.primaryFaint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.file_present_outlined,
            color: AppColors.primaryDark,
            size: 24,
          ),
          const Gap(8.0),
          Text(
            _pickedFile?.path.split('/').last ?? 'No file selected',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
          const Gap(8.0),
          IconButton(
            icon: Icon(Icons.close_outlined, color: AppColors.error, size: 16),
            onPressed: () {
              setState(() {
                _pickedFile = null;
              });
            },
          ),
        ],
      ),
    );
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

  /// Build chat bubble
  Widget _buildChatBubble({
    required ChatMessage message,
    required bool isFirst,
    required bool isLast,
  }) {
    final isMe = message.isFromUser;

    // --- Constants and Local Helper Function ---
    const double sharpRadius = 0.0;
    const double roundedRadius = 16.0;
    Radius radius(double value) => Radius.circular(value);

    /// Calculates the specific BorderRadius for a chat bubble.
    BorderRadiusGeometry getBubbleBorderRadius() {
      // Single message case: sharp corner on the "tail" side
      if (isFirst) {
        if (isMe) {
          // User (Right side): sharp bottom-right
          return BorderRadius.only(
            topLeft: radius(roundedRadius),
            topRight: radius(roundedRadius),
            bottomLeft: radius(roundedRadius),
            bottomRight: radius(sharpRadius),
          );
        } else {
          // Other (Left side): sharp bottom-left
          return BorderRadius.only(
            topLeft: radius(roundedRadius),
            topRight: radius(roundedRadius),
            bottomLeft: radius(sharpRadius),
            bottomRight: radius(roundedRadius),
          );
        }
      } else if (isLast) {
        if (isMe) {
          // User (Right side): sharp bottom-right
          return BorderRadius.only(
            topLeft: radius(roundedRadius),
            topRight: radius(sharpRadius),
            bottomLeft: radius(roundedRadius),
            bottomRight: radius(roundedRadius),
          );
        } else {
          // Other (Left side): sharp bottom-left
          return BorderRadius.only(
            topLeft: radius(sharpRadius),
            topRight: radius(roundedRadius),
            bottomLeft: radius(roundedRadius),
            bottomRight: radius(roundedRadius),
          );
        }
      }

      // Sequence messages (First, Last, Middle)
      // Determine the radii for the four corners.
      // The side of the message flow (right for isMe, left for others) should be sharp
      // if it connects to another message (i.e., not the end of the sequence).

      // Top-Right: Sharp if isMe AND NOT the last message (connects to the message below).
      final double tr = isMe
          ? (isLast ? roundedRadius : sharpRadius)
          : roundedRadius;

      // Bottom-Right: Sharp if isMe AND NOT the first message (connects to the message above).
      final double br = isMe
          ? (isFirst ? roundedRadius : sharpRadius)
          : roundedRadius;

      // Top-Left: Sharp if NOT isMe AND NOT the last message.
      final double tl = isMe
          ? roundedRadius
          : (isLast ? roundedRadius : sharpRadius);

      // Bottom-Left: Sharp if NOT isMe AND NOT the first message.
      final double bl = isMe
          ? roundedRadius
          : (isFirst ? roundedRadius : sharpRadius);

      return BorderRadius.only(
        topLeft: radius(tl),
        topRight: radius(tr),
        bottomLeft: radius(bl),
        bottomRight: radius(br),
      );
    }
    // --------------------------------------------------------------------------

    // Determine border radii using the helper function
    final borderRadius = getBubbleBorderRadius();

    // Check if the message has a GIF
    final hasGif = message.gif != null && message.gif!.isNotEmpty;
    final hasText = message.message.isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryDark : AppColors.primaryFaint,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display GIF if present
            if (hasGif) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  message.gif!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: isMe ? AppColors.background : AppColors.primary,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: isMe ? AppColors.background : Colors.black54,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load GIF',
                            style: TextStyle(
                              color: isMe
                                  ? AppColors.background
                                  : Colors.black54,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Add spacing between GIF and text if both exist
              if (hasText) const SizedBox(height: 8.0),
            ],
            // Display text if present
            if (hasText)
              ReadMoreText(
                message.message,
                trimLines: 8,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                style: TextStyle(
                  color: isMe ? AppColors.background : Colors.black87,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                moreStyle: TextStyle(
                  color: isMe
                      ? AppColors.background.withValues(alpha: 0.8)
                      : AppColors.primary,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
                lessStyle: TextStyle(
                  color: isMe
                      ? AppColors.background.withValues(alpha: 0.8)
                      : AppColors.primary,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CustomTextFormField(
        controller: _messageController,
        hint: 'Start a message',
        isRounded: true,
        enabled: !chatState.isSending,
        textInputAction: TextInputAction.send,
        onFieldSubmitted: (_) => _sendMessage(),
        prefix: IconButton(
          icon: const Icon(Icons.add),
          onPressed: chatState.isSending ? null : _showAttachmentPicker,
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
            disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
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
                    // Future: Add voice input functionality
                  }
                },
        ),
        onChanged: (value) {
          setState(() {}); // Update suffix icon
        },
      ),
    );
  }

  void _showAttachmentPicker() {
    // Future: Implement attachment picker functionality
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                FilePickerUtil.pickImage().then((value) {
                  setState(() {
                    _pickedFile = value;
                  });
                });
              },
              child: const Text('Pick Image'),
            ),
            TextButton(
              onPressed: () {
                FilePickerUtil.pickFile().then((value) {
                  setState(() {
                    _pickedFile = value;
                  });
                  context.pop();
                });
              },
              child: const Text('Pick File'),
            ),
          ],
        ),
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
              child: Image.asset(Assets.familyBee, scale: 4),
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

  /// Build loading view
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.waveDots(color: AppColors.primary, size: 50),
          const Gap(16.0),
          const Text(
            'Loading chat...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const Gap(16.0),
            const Text(
              'Failed to load chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(8.0),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const Gap(24.0),
            ElevatedButton.icon(
              onPressed: () => ref.read(chatProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build app bar
  PreferredSize _buildAppBar(BuildContext context) {
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
                      // padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Image.asset(Assets.dashAvatar, scale: 1.4),
                    ),
                    const Text(
                      'dash',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
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
