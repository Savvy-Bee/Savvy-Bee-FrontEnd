import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class SmartRecommendationCard extends StatefulWidget {
  final String title;
  final String description;
  final String? highlightedText; // Text to highlight in green
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Color backgroundColor;
  final bool showFeedback;
  final VoidCallback? onClose;

  const SmartRecommendationCard({
    super.key,
    required this.title,
    required this.description,
    this.highlightedText,
    required this.buttonText,
    required this.onButtonPressed,
    this.backgroundColor = const Color(0xFFFFF4CC), // Light yellow
    this.showFeedback = true,
    this.onClose,
  });

  @override
  State<SmartRecommendationCard> createState() =>
      _SmartRecommendationCardState();
}

class _SmartRecommendationCardState extends State<SmartRecommendationCard> {
  bool _isVisible = true;
  String? _selectedFeedback;

  void _handleClose() {
    setState(() {
      _isVisible = false;
    });
    widget.onClose?.call();
  }

  void _handleFeedback(String feedback) {
    setState(() {
      _selectedFeedback = feedback;
    });
    // You can add analytics or API call here
    print('User feedback: $feedback');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _handleClose,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: Colors.black),
                ),
              ),
            ],
          ),
          const Gap(16),

          // Description with highlighted text
          _buildDescription(),

          const Gap(16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onButtonPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.buttonText,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Feedback section
          // if (widget.showFeedback) ...[const Gap(24), _buildFeedbackSection()],
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.highlightedText == null ||
        !widget.description.contains(widget.highlightedText!)) {
      return Text(
        widget.description,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          height: 1.4,
        ),
      );
    }

    // Split text and highlight the specified portion
    final parts = widget.description.split(widget.highlightedText!);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          height: 1.4,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: widget.highlightedText,
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
