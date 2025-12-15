import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/avatars.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class ChooseAvatarScreen extends ConsumerStatefulWidget {
  static String path = '/choose-avatar';

  const ChooseAvatarScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChooseAvatarScreenState();
}

class _ChooseAvatarScreenState extends ConsumerState<ChooseAvatarScreen> {
  String? _selectedAvatar;

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
                _buildAvatarPicker(Avatars.lunaAvatars),
                const Gap(8),

                _buildSectionTitle('Dash'),
                _buildAvatarPicker(Avatars.dashAvatars),
                const Gap(8),

                _buildSectionTitle('Susu'),
                _buildAvatarPicker(Avatars.susuAvatars),
                const Gap(8),

                _buildSectionTitle('Penny'),
                _buildAvatarPicker(Avatars.pennyAvatars),
                const Gap(8),

                _buildSectionTitle('Boo'),
                _buildAvatarPicker(Avatars.booAvatars),
                const Gap(8),

                _buildSectionTitle('Bloom'),
                _buildAvatarPicker(Avatars.bloomAvatars),
                const Gap(8),

                _buildSectionTitle('Loki'),
                _buildAvatarPicker(Avatars.lokiAvatars),
                const Gap(25),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 32),
            child: CustomElevatedButton(
              text: 'Select Avatar',
              onPressed: _selectedAvatar == null
                  ? null
                  : () {
                      if (_selectedAvatar != null) {
                        Navigator.pop(context, _selectedAvatar);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(List<String> avatars) {
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
