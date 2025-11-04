import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_picker_util.dart';

class PickedFilePreview extends StatelessWidget {
  final File? file;
  final VoidCallback? onRemove;
  const PickedFilePreview({super.key, required this.file, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final path = file!.path.toLowerCase();
    final isImage = FileUtils.isImageFile(path);

    return isImage
        ? Padding(
            padding: const EdgeInsets.only(right: 5.0, bottom: 5.0),
            child: OutlinedCard(
              borderRadius: 5,
              padding: EdgeInsets.zero,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  SizedBox.square(
                    dimension: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(file!, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.primaryFaint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.file_present_outlined,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                const Gap(8.0),
                Text(
                  file?.path.split('/').last ?? 'No file selected',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                ),
                const Gap(8.0),
                IconButton(
                  icon: Icon(
                    Icons.close_outlined,
                    color: AppColors.error,
                    size: 16,
                  ),
                  onPressed: onRemove,
                ),
              ],
            ),
          );
  }
}
