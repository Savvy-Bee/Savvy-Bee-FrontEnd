import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

// XFile is re-exported from image_picker / cross_file — it is fully
// web-compatible: on web, path is a blob URL; on mobile, path is a real path.

class FileUtils {
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
  ];

  static const List<String> supportedDocumentExtensions = [
    '.pdf',
    '.docx',
    '.doc',
    '.xlsx',
    '.xls',
    '.ppt',
    '.pptx',
  ];

  /// Get the MIME type of a file by name/path
  static String getMimeType(String? path) {
    if (path == null) return 'Unknown';
    return lookupMimeType(path)?.split('/').last.toUpperCase() ?? 'Unknown';
  }

  /// Check if the file extension is supported
  static bool isSupportedFile(String? path) {
    if (path == null) return false;
    final extension = path.toLowerCase().split('.').last;
    return supportedImageExtensions.contains('.$extension') ||
        supportedDocumentExtensions.contains('.$extension');
  }

  /// Check if the file is an image based on its name or path
  static bool isImageFile(String? path) {
    if (path == null) return false;
    final extension = path.toLowerCase().split('.').last;
    return supportedImageExtensions.contains('.$extension');
  }

  /// Check if the file is a document based on its name or path
  static bool isDocumentFile(String? path) {
    if (path == null) return false;
    final extension = path.toLowerCase().split('.').last;
    return supportedDocumentExtensions.contains('.$extension');
  }

  /// Check if an XFile is an image (uses name, which is reliable on all platforms)
  static bool isImageXFile(XFile xfile) => isImageFile(xfile.name);

  /// Pick a single file and return it as an [XFile].
  /// On web, the XFile carries in-memory bytes; on mobile it carries a path.
  static Future<XFile?> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        // withData: true ensures bytes are populated — needed on web where
        // path is null, and harmless on mobile.
        withData: kIsWeb,
      );
      if (result != null) {
        final pf = result.files.single;
        if (kIsWeb) {
          return XFile.fromData(
            pf.bytes!,
            name: pf.name,
            mimeType: lookupMimeType(pf.name),
          );
        } else {
          return XFile(pf.path!);
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
    return null;
  }

  /// Pick an image from the gallery and return it as an [XFile].
  static Future<XFile?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      // pickImage already returns XFile — just pass it through.
      return await picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  /// Pick multiple files and return them as a list of [XFile].
  static Future<List<XFile>> pickMultipleFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: kIsWeb,
      );
      if (result != null) {
        return result.files.map((pf) {
          if (kIsWeb) {
            return XFile.fromData(
              pf.bytes!,
              name: pf.name,
              mimeType: lookupMimeType(pf.name),
            );
          } else {
            return XFile(pf.path!);
          }
        }).toList();
      }
    } catch (e) {
      debugPrint('Error picking multiple files: $e');
    }
    return [];
  }
}
