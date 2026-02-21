import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';

class FinancialHealthCard extends StatelessWidget {
  final FinancialHealth healthData;

  const FinancialHealthCard({super.key, required this.healthData});

  String getHealthStatus() {
    // Based on rate score 0-100
    if (healthData.rate >= 80) return 'Thriving';
    if (healthData.rate >= 60) return 'Flourishing';
    if (healthData.rate >= 40) return 'Stabilizing';
    if (healthData.rate >= 20) return 'Building';
    return 'Surviving';
  }

  String getHealthImage() {
    final status = getHealthStatus();
    // Map to your asset paths
    switch (status) {
      case 'Thriving':
        return 'assets/images/illustrations/health/thriving.png';
      case 'Flourishing':
        return 'assets/images/illustrations/health/flourishing.png';
      case 'Stabilizing':
        return 'assets/images/illustrations/health/stabilizing.png';
      case 'Building':
        return 'assets/images/illustrations/health/building.png';
      case 'Surviving':
        return 'assets/images/illustrations/health/surviving.png';
      default:
        return 'assets/images/illustrations/health/surviving.png';
    }
  }

  Color getHealthColor() {
    if (healthData.rate >= 80) return const Color(0xFF4CAF50); // Green
    if (healthData.rate >= 60) return const Color(0xFF66BB6A); // Light Green
    if (healthData.rate >= 40) return const Color(0xFFFF9800); // Orange
    if (healthData.rate >= 20) return const Color(0xFFFF5722); // Deep Orange
    return const Color(0xFFD32F2F); // Red
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 420,
          width: double.infinity,
          child: Image.asset(
            getHealthImage(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image doesn't exist
              return Container(
                color: getHealthColor(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Your financial health is',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 16 * 0.02,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      getHealthStatus(),
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 48 * 0.02,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      healthData.insight,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 14 * 0.02,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
