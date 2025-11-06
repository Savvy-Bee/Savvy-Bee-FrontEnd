import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

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

  /// Get the MIME type of a file
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

  /// Check if the file is an image
  static bool isImageFile(String? path) {
    if (path == null) return false;
    final extension = path.toLowerCase().split('.').last;
    return supportedImageExtensions.contains('.$extension');
  }

  /// Check if the file is a document
  static bool isDocumentFile(String? path) {
    if (path == null) return false;
    final extension = path.toLowerCase().split('.').last;
    return supportedDocumentExtensions.contains('.$extension');
  }

  static Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
    return null;
  }

  static Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  static Future<List<File>> pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        return result.paths.map((path) => File(path!)).toList();
      }
    } catch (e) {
      debugPrint('Error picking multiple files: $e');
    }
    return [];
  }
}
