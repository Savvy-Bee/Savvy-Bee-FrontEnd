// lib/widgets/help_back_app_bar.dart
import 'package:flutter/material.dart';

class HelpBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HelpBackAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
        onPressed: () => Navigator.pop(context),
        // If using go_router everywhere → context.pop() instead
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
