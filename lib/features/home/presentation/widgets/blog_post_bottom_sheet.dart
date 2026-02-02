// lib/features/home/presentation/widgets/blog_post_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/home/domain/models/blog_post.dart';

class BlogPostBottomSheet extends StatefulWidget {
  final BlogPost post;

  const BlogPostBottomSheet({super.key, required this.post});

  @override
  State<BlogPostBottomSheet> createState() => _BlogPostBottomSheetState();
}

class _BlogPostBottomSheetState extends State<BlogPostBottomSheet> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    // Add to favorites logic here
  }

  void _sharePost() {
    // Share logic here
    print('Sharing post: ${widget.post.title}');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Category tag
                    Text(
                      widget.post.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(12),

                    // Title
                    Text(
                      widget.post.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),

                    // Subtitle
                    Text(
                      widget.post.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const Gap(16),

                    // Date and actions row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.post.date,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                        Row(
                          spacing: 16,
                          children: [
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: Icon(
                                _isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: _isFavorited ? Colors.red : Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: _sharePost,
                              child: Icon(
                                Icons.ios_share,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(24),

                    // Featured image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        widget.post.imagePath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(24),

                    // Blog content
                    Text(
                      widget.post.content,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const Gap(40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper function to show the blog post bottom sheet
void showBlogPostBottomSheet(BuildContext context, BlogPost post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlogPostBottomSheet(post: post),
  );
}
