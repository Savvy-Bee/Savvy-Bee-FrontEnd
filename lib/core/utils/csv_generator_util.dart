import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:savvy_bee_mobile/core/utils/web_download.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/taxation.dart';

class CsvGeneratorUtil {
  /// Generate CSV file for tax history.
  /// On web: triggers a browser download and returns the filename.
  /// On mobile: writes to device storage and returns the file path.
  static Future<String?> generateTaxHistoryCsv(
    TaxationHomeData taxData,
  ) async {
    try {
      // Build CSV rows
      final List<List<dynamic>> rows = [
        ['Date', 'Narration', 'Type', 'Category', 'Amount', 'Balance'],
        ...taxData.history.map((item) => [
              item.date.toString().split(' ')[0],
              item.narration,
              item.type,
              item.category ?? 'N/A',
              item.amount.toStringAsFixed(2),
              item.balance.toStringAsFixed(2),
            ]),
        [],
        ['Summary'],
        ['Total Earnings', taxData.totalEarnings.toStringAsFixed(2)],
        ['Annual Tax', taxData.tax.yearly.toStringAsFixed(2)],
        ['Monthly Tax', taxData.tax.monthly.toStringAsFixed(2)],
        ['Tax Rate', '${taxData.tax.rate}%'],
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tax_history_$timestamp.csv';

      if (kIsWeb) {
        // On web: trigger browser download
        await triggerBrowserDownload(
          csv.codeUnits,
          fileName,
          'text/csv',
        );
        return fileName;
      }

      // Android: request storage permission
      if (Platform.isAndroid) {
        if (!await _requestStoragePermission()) {
          throw Exception('Storage permission denied');
        }
      }

      final directory = await _getStorageDirectory();
      final filePath = '${directory.path}/$fileName';
      await File(filePath).writeAsString(csv);
      return filePath;
    } catch (e) {
      print('Error generating CSV: $e');
      return null;
    }
  }

  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
    return true;
  }

  static Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) return downloadDir;
      final externalDir = await getExternalStorageDirectory();
      return externalDir ?? await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }
}
