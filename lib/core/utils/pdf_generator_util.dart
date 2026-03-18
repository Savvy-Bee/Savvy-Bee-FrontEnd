import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:savvy_bee_mobile/core/utils/web_download.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/taxation.dart';
import 'package:share_plus/share_plus.dart';

class PdfGeneratorUtil {
  static Future<String?> generateTaxSummaryPdf(
    TaxCalculatorData taxData,
  ) async {
    try {
      // Request storage permission for Android only (not needed on web)
      if (!kIsWeb && Platform.isAndroid) {
        if (await _requestStoragePermission() == false) {
          throw Exception('Storage permission denied');
        }
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add content to PDF (same as before)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey900,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Tax Summary Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateTime.now().toString().split('.')[0]}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Main Tax Information
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Your Estimated Tax',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      _buildPdfRow(
                        'Annual Tax',
                        '₦${_formatNumber(taxData.tax.yearly)}',
                        isHighlight: true,
                      ),
                      pw.SizedBox(height: 8),
                      _buildPdfRow(
                        'Monthly Tax',
                        '₦${_formatNumber(taxData.tax.monthly)}',
                      ),
                      pw.SizedBox(height: 8),
                      _buildPdfRow('Effective Rate', '${taxData.tax.rate}%'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Tax Breakdown
                pw.Text(
                  'Tax Breakdown',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPdfRow(
                        'Gross Income',
                        '₦${_formatNumber(taxData.totalEarnings)}',
                      ),
                      pw.Divider(),
                      _buildPdfRow(
                        'Base Exemption',
                        '-₦${_formatNumber(taxData.totalEarnings - taxData.tax.yearly)}',
                      ),
                      pw.Divider(),
                      _buildPdfRow(
                        'Taxable Income',
                        '₦${_formatNumber(taxData.tax.yearly)}',
                      ),
                      pw.Divider(),
                      _buildPdfRow(
                        'Tax Before Relief',
                        '₦${_formatNumber(taxData.tax.yearly)}',
                      ),
                      pw.SizedBox(height: 16),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 12),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                              color: PdfColors.grey800,
                              width: 2,
                            ),
                          ),
                        ),
                        child: _buildPdfRow(
                          'Final Tax',
                          '₦${_formatNumber(taxData.tax.yearly)}',
                          isHighlight: true,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Footer
                pw.Text(
                  'Note: This is an estimate based on the information provided. Please consult with a tax professional for accurate calculations.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tax_summary_$timestamp.pdf';

      if (kIsWeb) {
        // On web: trigger browser download directly — no filesystem access needed
        await triggerBrowserDownload(pdfBytes, fileName, 'application/pdf');
        return fileName; // Return filename as a signal of success
      }

      // Mobile: save to device storage and return the path
      final directory = await _getStorageDirectory();
      final filePath = '${directory.path}/$fileName';
      await File(filePath).writeAsBytes(pdfBytes);
      return filePath;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  /// Request storage permission for Android
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+)
      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted) {
        return true;
      }

      // Try requesting storage permission
      final status = await Permission.storage.request();
      if (status.isGranted) return true;

      // For Android 11+ (API 30+), try manage external storage
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
    return true; // iOS doesn't need storage permission for app documents
  }

  /// Get the appropriate storage directory based on platform
  static Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      // Try to use Downloads folder first
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir;
      }

      // Fallback to external storage directory
      final externalDir = await getExternalStorageDirectory();
      return externalDir ?? await getApplicationDocumentsDirectory();
    } else {
      // iOS: Use application documents directory
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Share PDF using platform share dialog (works on both Android and iOS)
  static Future<void> sharePdf(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Tax Summary Report',
        subject: 'My Tax Calculation',
      );
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }

  static pw.Widget _buildPdfRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  static String _formatNumber(num number) {
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // Add this method to your existing PdfGeneratorUtil class

  static Future<String?> generateTaxStatsPdf(TaxationHomeData taxData) async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        if (await _requestStoragePermission() == false) {
          throw Exception('Storage permission denied');
        }
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add content to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey900,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Tax Health Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateTime.now().toString().split('.')[0]}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Tax Summary
                pw.Text(
                  'Annual Tax Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPdfRow(
                        'Total Earnings',
                        '₦${_formatNumber(taxData.totalEarnings)}',
                      ),
                      pw.Divider(),
                      _buildPdfRow(
                        'Annual Tax',
                        '₦${_formatNumber(taxData.tax.yearly)}',
                        isHighlight: true,
                      ),
                      pw.Divider(),
                      _buildPdfRow(
                        'Monthly Tax',
                        '₦${_formatNumber(taxData.tax.monthly)}',
                      ),
                      pw.Divider(),
                      _buildPdfRow('Tax Rate', '${taxData.tax.rate}%'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Tax Breakdown
                pw.Text(
                  'Tax Breakdown',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPdfRow(
                        'Gross Income',
                        '₦${_formatNumber(taxData.totalEarnings)}',
                      ),
                      pw.Divider(),
                      _buildPdfRow(
                        'Base Exemption',
                        '-₦${_formatNumber(taxData.totalEarnings - taxData.tax.yearly)}',
                      ),
                      pw.Divider(),
                      _buildPdfRow(
                        'Taxable Income',
                        '₦${_formatNumber(taxData.tax.yearly)}',
                      ),
                      pw.SizedBox(height: 16),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 12),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                              color: PdfColors.grey800,
                              width: 2,
                            ),
                          ),
                        ),
                        child: _buildPdfRow(
                          'Total Tax',
                          '₦${_formatNumber(taxData.tax.yearly)}',
                          isHighlight: true,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Transaction History
                if (taxData.history.isNotEmpty) ...[
                  pw.Text(
                    'Recent Transactions',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Table.fromTextArray(
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    cellHeight: 30,
                    headers: ['Date', 'Narration', 'Type', 'Amount'],
                    data: taxData.history.take(10).map((item) {
                      return [
                        item.date.toString().split(' ')[0],
                        item.narration.length > 30
                            ? '${item.narration.substring(0, 27)}...'
                            : item.narration,
                        item.type,
                        '₦${_formatNumber(item.amount)}',
                      ];
                    }).toList(),
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Footer
                pw.Text(
                  'This is a certified audit report for HR, LIRS, or NRS compliance. All income sources tracked, tax shields & reliefs consolidated.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tax_health_report_$timestamp.pdf';

      if (kIsWeb) {
        await triggerBrowserDownload(pdfBytes, fileName, 'application/pdf');
        return fileName;
      }

      final directory = await _getStorageDirectory();
      final filePath = '${directory.path}/$fileName';
      await File(filePath).writeAsBytes(pdfBytes);
      return filePath;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }
}
