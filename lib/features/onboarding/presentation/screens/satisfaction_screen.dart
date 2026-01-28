import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/answer_button.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/onboarding_scaffold.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup_screen.dart';

class SatisfactionScreen extends StatefulWidget {
  static const String path = '/satisfaction';
  const SatisfactionScreen({super.key});

  @override
  State<SatisfactionScreen> createState() => _SatisfactionScreenState();
}

class _SatisfactionScreenState extends State<SatisfactionScreen> {
  bool? selectedAnswer;

  void _handleSkip() {
    // TODO: Navigate to next screen
    // print('Skipped');
    context.pushNamed(SignupScreen.path);
  }

  void _selectAnswer(bool answer) {
    setState(() {
      selectedAnswer = answer;
    });
    // Auto-navigate after selection (optional)
    Future.delayed(const Duration(milliseconds: 300), () {
      context.pushNamed(SignupScreen.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      showSkip: true,
      onSkip: _handleSkip,
      bottomButton: _buildAnswerButtons(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          // Bee character illustration
          Center(child: _BeeCharacterPlaceholder()),
          SizedBox(height: 48.h),
          // Question text
          Text(
            'I am satisfied with the amount of money I save given my current income.',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 20.h),
          // Description text
          Text(
            'Savings includes any amount of money put towards your future, such as an emergency fund, vacation fund, retirement, investing, or paying debt.',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
              height: 1.5,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          AnswerButton(
            text: 'True',
            isSelected: selectedAnswer == true,
            onTap: () => _selectAnswer(true),
          ),
          SizedBox(height: 12.h),
          AnswerButton(
            text: 'False',
            isSelected: selectedAnswer == false,
            onTap: () => _selectAnswer(false),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

/// Placeholder for the bee character
/// Replace with your actual asset image when available
class _BeeCharacterPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Option 1: If you have the asset, uncomment this:
    return Image.asset(
      'assets/images/other/bee_onboarding_img.png',
      height: 257.h,
      width: 257.h,
      fit: BoxFit.contain,
    );

    // Option 2: Placeholder until you add the asset:
    // return Container(
    //   height: 240.h,
    //   width: 240.w,
    //   decoration: BoxDecoration(
    //     color: const Color(0xFFFFC107).withOpacity(0.2),
    //     shape: BoxShape.circle,
    //   ),
    //   child: Center(
    //     child: Icon(
    //       Icons.emoji_nature,
    //       size: 100.sp,
    //       color: const Color(0xFFFFC107),
    //     ),
    //   ),
    // );
  }
}
