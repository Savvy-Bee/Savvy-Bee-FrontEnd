import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/budget_chat_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/goal_chat_widget.dart';

import 'formatted_chat_message_widget.dart';

/// Build chat bubble with dynamic widget support
Widget buildChatBubble({
  required BuildContext context,
  required ChatMessage message,
  required bool isFirst,
  required bool isLast,
  VoidCallback? onBudgetAction,
  VoidCallback? onGoalAction,
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
    final double tr = isMe
        ? (isLast ? roundedRadius : sharpRadius)
        : roundedRadius;
    final double br = isMe
        ? (isFirst ? roundedRadius : sharpRadius)
        : roundedRadius;
    final double tl = isMe
        ? roundedRadius
        : (isLast ? roundedRadius : sharpRadius);
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
  final hasWidget =
      message.hasWidget && !isMe; // Only show widgets for AI messages

  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMe) CircleAvatar(radius: 16),
        // Main chat bubble
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          padding: isMe
              ? const EdgeInsets.symmetric(vertical: 10, horizontal: 14)
              : null,
          decoration: BoxDecoration(
            color: isMe ? AppColors.black : null,
            borderRadius: borderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display GIF if present
              if (hasGif) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: message.gif!,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, child, loadingProgress) {
                          return _buildGifLoadingWidget(loadingProgress, isMe);
                        },
                    errorWidget: (context, error, stackTrace) {
                      return _buildGifErrorWidget(isMe);
                    },
                  ),
                ),
                // Add spacing between GIF and text if both exist
                if (hasText) const Gap(8.0),
              ],
              // Display text if present
              if (hasText)
                FormattedChatMessage(
                  message: message.message,
                  style: TextStyle(
                    color: isMe ? AppColors.background : Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),

        // Widget rendering below the chat bubble (for AI messages only)
        if (hasWidget) ...[
          const Gap(8.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: _buildChatWidget(
              message: message,
              onBudgetAction: onBudgetAction,
              onGoalAction: onGoalAction,
            ),
          ),
        ],
      ],
    ),
  );
}

Container _buildGifLoadingWidget(DownloadProgress loadingProgress, bool isMe) {
  return Container(
    height: 150,
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      value: loadingProgress.totalSize != null
          ? loadingProgress.downloaded / loadingProgress.totalSize!
          : null,
      color: isMe ? AppColors.background : AppColors.primary,
    ),
  );
}

Container _buildGifErrorWidget(bool isMe) {
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
        const Gap(8.0),
        Text(
          'Failed to load GIF',
          style: TextStyle(
            color: isMe ? AppColors.background : Colors.black54,
            fontSize: 12.0,
          ),
        ),
      ],
    ),
  );
}

/// Build the appropriate widget based on chat type
Widget _buildChatWidget({
  required ChatMessage message,
  VoidCallback? onBudgetAction,
  VoidCallback? onGoalAction,
}) {
  return switch (message.chatType) {
    ChatType.budget => BudgetChatWidget(
      budgetData: ChatWidgetDataParser.parseBudgetData(message.otherData),
      onAdjustBudget: onBudgetAction,
      onViewDetails: onBudgetAction,
    ),
    ChatType.goal => GoalChatWidget(
      goalData: ChatWidgetDataParser.parseGoalData(message.otherData),
      onCreateGoal: onGoalAction,
      onViewAchievements: onGoalAction,
    ),
    ChatType.general => const SizedBox.shrink(),
  };
}
