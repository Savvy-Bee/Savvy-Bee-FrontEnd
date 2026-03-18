import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart'; // XFile
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_picker_util.dart';

class PickedFilePreview extends StatelessWidget {
  final XFile? file;
  final VoidCallback? onRemove;

  const PickedFilePreview({super.key, required this.file, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final name = file!.name.toLowerCase();
    final isImage = FileUtils.isImageFile(name);

    return isImage ? _buildImagePreview() : _buildDocumentPreview(name);
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0, bottom: 5.0),
      child: CustomCard(
        borderRadius: 5,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            SizedBox.square(
              dimension: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                // FutureBuilder reads bytes once; works on web and mobile alike
                child: FutureBuilder<Uint8List>(
                  future: file!.readAsBytes(),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      return Image.memory(snap.data!, fit: BoxFit.cover);
                    }
                    return const SizedBox.square(dimension: 50);
                  },
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(String name) {
    return CustomCard(
      padding: const EdgeInsets.all(5.0).copyWith(left: 8),
      bgColor: AppColors.primaryFaint.withValues(alpha: 0.3),
      borderRadius: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.file_present_outlined, size: 20),
          ),
          const Gap(8.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (file?.name ?? 'No file selected')
                        .truncate(15, addEllipsis: true),
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 14 * 0.02,
                    ),
                  ),
                  const Gap(16),
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                FileUtils.getMimeType(name),
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'GeneralSans',
                  letterSpacing: 12 * 0.02,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
