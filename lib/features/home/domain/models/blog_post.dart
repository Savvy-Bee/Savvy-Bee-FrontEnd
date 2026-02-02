// lib/features/home/domain/models/blog_post.dart

class BlogPost {
  final String category;
  final String title;
  final String subtitle;
  final String date;
  final String imagePath;
  final String content;
  final int readTimeMinutes;

  BlogPost({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imagePath,
    required this.content,
    required this.readTimeMinutes,
  });
}
