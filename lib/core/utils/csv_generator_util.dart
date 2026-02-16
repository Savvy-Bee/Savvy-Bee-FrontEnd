import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/taxation.dart';
import 'package:csv/csv.dart';

class CsvGeneratorUtil {
  /// Generate CSV file for tax history
  static Future<String?> generateTaxHistoryCsv(
    TaxationHomeData taxData,
  ) async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        if (await _requestStoragePermission() == false) {
          throw Exception('Storage permission denied');
        }
      }

      // Create CSV data
      List<List<dynamic>> rows = [
        // Header row
        ['Date', 'Narration', 'Type', 'Category', 'Amount', 'Balance'],
        // Data rows
        ...taxData.history.map((item) => [
              item.date.toString().split(' ')[0], // Date only
              item.narration,
              item.type,
              item.category ?? 'N/A',
              item.amount.toStringAsFixed(2),
              item.balance.toStringAsFixed(2),
            ]),
        // Summary rows
        [],
        ['Summary'],
        ['Total Earnings', taxData.totalEarnings.toStringAsFixed(2)],
        ['Annual Tax', taxData.tax.yearly.toStringAsFixed(2)],
        ['Monthly Tax', taxData.tax.monthly.toStringAsFixed(2)],
        ['Tax Rate', '${taxData.tax.rate}%'],
      ];

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Get storage directory
      final directory = await _getStorageDirectory();

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tax_history_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Save the CSV file
      final file = File(filePath);
      await file.writeAsString(csv);

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
      if (await downloadDir.exists()) {
        return downloadDir;
      }
      final externalDir = await getExternalStorageDirectory();
      return externalDir ?? await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
}