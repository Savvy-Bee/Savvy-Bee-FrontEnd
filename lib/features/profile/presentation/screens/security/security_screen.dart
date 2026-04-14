import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart' show CustomSnackbar, SnackbarType;
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/biometric_provider.dart';

import '../../../../../core/utils/assets/app_icons.dart';
import '../../../../../core/widgets/game_card.dart';
import '../../widgets/profile_list_tile.dart';

class SecurityScreen extends ConsumerWidget {
  static const String path = '/security';

  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = ref.watch(biometricProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GameCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileListTile(
                  title: 'Fingerprint / Face ID',
                  iconPath: AppIcons.infoIcon,
                  useDefaultTrailing: false,
                  trailing: biometric.isAuthenticating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Transform.scale(
                          scale: 0.5,
                          child: Switch(
                            value: biometric.isEnabled,
                            onChanged: biometric.isAvailable
                                ? (value) =>
                                    _handleBiometricToggle(context, ref, value, currentUser?.email)
                                : null,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primaryFaint,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                  onTap: biometric.isAvailable
                      ? () => _handleBiometricToggle(
                            context,
                            ref,
                            !biometric.isEnabled,
                            currentUser?.email,
                          )
                      : () => CustomSnackbar.show(
                            context,
                            'Biometrics not available on this device',
                            type: SnackbarType.error,
                          ),
                ),
                if (!biometric.isAvailable) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Biometric authentication is not set up on this device.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ],
                const Divider(height: 0),
                ProfileListTile(
                  title: 'Change PIN',
                  iconPath: AppIcons.infoIcon,
                  onTap: () => CustomSnackbar.show(context, 'Coming soon'),
                ),
                const Divider(height: 0),
                ProfileListTile(
                  title: 'Change Password',
                  iconPath: AppIcons.infoIcon,
                  onTap: () => CustomSnackbar.show(context, 'Coming soon'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBiometricToggle(
    BuildContext context,
    WidgetRef ref,
    bool enable,
    String? email,
  ) async {
    if (enable) {
      if (email == null) {
        CustomSnackbar.show(context, 'Could not identify your account. Please log in again.', type: SnackbarType.error);
        return;
      }
      final success =
          await ref.read(biometricProvider.notifier).enableBiometrics(email);
      if (context.mounted) {
        if (success) {
          CustomSnackbar.show(context, 'Biometric login enabled', type: SnackbarType.success);
        } else {
          final error = ref.read(biometricProvider).errorMessage;
          if (error != null) {
            CustomSnackbar.show(context, error, type: SnackbarType.error);
          }
        }
      }
    } else {
      await ref.read(biometricProvider.notifier).disableBiometrics();
      if (context.mounted) {
        CustomSnackbar.show(context, 'Biometric login disabled', type: SnackbarType.success);
      }
    }
  }
}
