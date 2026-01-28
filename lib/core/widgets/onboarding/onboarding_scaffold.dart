import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable scaffold wrapper for onboarding screens
/// Provides consistent layout structure with optional skip button
class OnboardingScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomButton;
  final bool showSkip;
  final VoidCallback? onSkip;

  const OnboardingScaffold({
    super.key,
    required this.child,
    this.bottomButton,
    this.showSkip = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: showSkip
            ? [
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: child,
            ),
          ),
          if (bottomButton != null) bottomButton!,
        ],
      ),
    );
  }
}