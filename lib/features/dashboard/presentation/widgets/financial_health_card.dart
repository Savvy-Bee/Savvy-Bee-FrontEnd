import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';

class FinancialHealthCard extends StatelessWidget {
  final FinancialHealth healthData;

  const FinancialHealthCard({super.key, required this.healthData});

  String getHealthStatus() {
    if (healthData.rate >= 80) return 'Flourishing';
    if (healthData.rate >= 60) return 'Thriving';
    if (healthData.rate >= 40) return 'Stabilizing';
    if (healthData.rate >= 20) return 'Building';
    return 'Surviving';
  }

  String getHealthImage() {
    final status = getHealthStatus();
    // Map to your actual asset paths
    switch (status) {
      case 'stabilizing':
        return 'assets/images/illustrations/health/stabilizing.png';
      case 'surviving':
        return 'assets/images/illustrations/health/surviving.png';
      case 'flourishing':
        return 'assets/images/illustrations/health/flourishing.png';
      case 'thriving':
        return 'assets/images/illustrations/health/thriving.png';
      case 'building':
        return 'assets/images/illustrations/health/building.png';
      default:
        // Fallback to stabilizing as default
        return 'assets/images/illustrations/health/stabilizing.png';
    }
  }

  Color getHealthColor() {
    if (healthData.rate >= 80) return const Color(0xFF4CAF50); // Green
    if (healthData.rate >= 60) return const Color(0xFF2196F3); // Blue
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
        child: Stack(
          children: [
            // Full background image
            SizedBox(
              height: 420,
              width: double.infinity,
              child: Image.asset(
                getHealthImage(),
                fit: BoxFit.contain,
                height: 400,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image doesn't exist
                  return Container(
                    color: getHealthColor(),
                    child: Center(
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
                          const Gap(8),
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
                          const Gap(16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              healthData.insight,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'GeneralSans',
                                letterSpacing: 14 * 0.02,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Insight overlay at the bottom
            if (healthData.insight.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getHealthStatus(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'GeneralSans',
                          letterSpacing: 18 * 0.02,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        healthData.insight,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'GeneralSans',
                          letterSpacing: 12 * 0.02,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
