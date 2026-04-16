import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/send_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/transfer_screen_one.dart';

class QuickActionsScreen extends StatelessWidget {
  static const String path = '/quick-actions';

  const QuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'GeneralSans',
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI-assisted shortcuts',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  fontFamily: 'GeneralSans',
                ),
              ),
              const Gap(20),

              // Grid of Quick Actions
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _buildActionCard(
                    icon: Icons.send_rounded,
                    iconColor: const Color(0xFF2196F3),
                    title: 'Send Money',
                    subtitle: 'Transfer to anyone',
                    onTap: () => context.push(TransferScreenOne.path),
                  ),
                  _buildActionCard(
                    icon: Icons.payment_rounded,
                    iconColor: const Color(0xFF9C27B0),
                    title: 'Pay Bills',
                    subtitle: 'Airtime, data, utilities',
                    onTap: () {
                      // Navigate to Pay Bills
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.emoji_events_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Add to Goal',
                    subtitle: 'Save toward a target',
                    onTap: () {
                      // Navigate to Goals
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.call_split_rounded,
                    iconColor: const Color(0xFFFF9800),
                    title: 'Split Bill',
                    subtitle: 'Share with friends',
                    onTap: () {
                      // Navigate to Split Bill
                    },
                  ),
                ],
              ),

              const Gap(32),

              // AI Chat Suggestion Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Or just ask Nahi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                    const Gap(8),
                    const Text(
                      '"Send ₦5,000 to Tolu for lunch"',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'GeneralSans',
                        color: Color(0xFF424242),
                        height: 1.4,
                      ),
                    ),
                    const Gap(20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Open AI Chat
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
            ),
            const Gap(12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            const Gap(2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF757575),
                fontFamily: 'GeneralSans',
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}