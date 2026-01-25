import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/avatars.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/providers/profile_provider.dart';

class ChooseAvatarScreen extends ConsumerStatefulWidget {
  static const String path = '/choose-avatar';
  const ChooseAvatarScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChooseAvatarScreenState();
}

class _ChooseAvatarScreenState extends ConsumerState<ChooseAvatarScreen> {
  String? _selectedAvatar;
  String? _selectedCharacter;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose avatar')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle('Luna'),
                _buildAvatarPicker(Avatars.lunaAvatars, 'Luna'),
                const Gap(8),
                _buildSectionTitle('Dash'),
                _buildAvatarPicker(Avatars.dashAvatars, 'Dash'),
                const Gap(8),
                _buildSectionTitle('Susu'),
                _buildAvatarPicker(Avatars.susuAvatars, 'Susu'),
                const Gap(8),
                _buildSectionTitle('Penny'),
                _buildAvatarPicker(Avatars.pennyAvatars, 'Penny'),
                const Gap(8),
                _buildSectionTitle('Boo'),
                _buildAvatarPicker(Avatars.booAvatars, 'Boo'),
                const Gap(8),
                _buildSectionTitle('Bloom'),
                _buildAvatarPicker(Avatars.bloomAvatars, 'Bloom'),
                const Gap(8),
                _buildSectionTitle('Loki'),
                _buildAvatarPicker(Avatars.lokiAvatars, 'Loki'),
                const Gap(25),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 32),
            child: CustomElevatedButton(
              text: 'Select Avatar',
              isLoading: isLoading,
              onPressed: _selectedCharacter == null
                  ? null
                  : _handleSelectAvatar,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelectAvatar() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    if (_selectedCharacter != null) {
      final success = await ref
          .read(updateProfileAvatarProvider.notifier)
          .updateAvatar(_selectedCharacter!);
      if (success) {
        ref.invalidate(homeDataProvider);

        if (mounted) {
          context.pop(_selectedCharacter);

          CustomSnackbar.show(
            context,
            'Avatar updated successfully!',
            type: SnackbarType.success,
          );
        }
      } else {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'Failed to update avatar. Please try again',
            type: SnackbarType.error,
          );
        }
      }
    }

    setState(() => isLoading = false);
  }

  Widget _buildAvatarPicker(List<String> avatars, String characterName) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16,
        children: List.generate(
          avatars.length,
          (index) => InkWell(
            onTap: () {
              setState(() {
                _selectedAvatar = avatars[index];
                _selectedCharacter = '$characterName${index + 1}';
              });
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                border: _selectedAvatar == avatars[index]
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(avatars[index], height: 100, width: 100),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
