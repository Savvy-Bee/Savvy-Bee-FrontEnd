import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/transfer_screen_one.dart';
import 'package:share_plus/share_plus.dart';

class TransactionDetailScreen extends StatelessWidget {
  static const String path = '/transaction-detail';

  final WalletTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  Future<void> _shareTransaction(BuildContext context) async {
    try {
      final imageBytes = await _buildReceiptImageBytes();
      final tempDir = await getTemporaryDirectory();
      final referenceForName = transaction.koraReferenceId.isNotEmpty
          ? transaction.koraReferenceId
          : transaction.id;
      final safeReference = referenceForName.replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );
      final outputFile = File(
        '${tempDir.path}/savvy_bee_receipt_$safeReference.png',
      );
      await outputFile.writeAsBytes(imageBytes, flush: true);

      await Share.shareXFiles(
        [XFile(outputFile.path)],
        subject: 'Savvy Bee Transaction Receipt',
        text: 'Savvy Bee receipt for ${transaction.amount.formatCurrency()}',
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to generate receipt image. Please try again.'),
        ),
      );
    }
  }

  Future<ui.Image?> _loadLogoImage() async {
    try {
      final logoAsset = await rootBundle.load(Logos.logo);
      final codec = await ui.instantiateImageCodec(
        logoAsset.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  double _drawText(
    Canvas canvas, {
    required String text,
    required double x,
    required double y,
    required double maxWidth,
    required TextStyle style,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '...',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, Offset(x, y));
    return painter.height;
  }

  double _drawReceiptRow(
    Canvas canvas, {
    required double x,
    required double y,
    required double width,
    required String label,
    required String value,
    bool emphasizeValue = false,
  }) {
    const gap = 20.0;
    final valueWidth = width * 0.55;
    final labelWidth = width - valueWidth - gap;

    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: labelWidth);

    final valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: const Color(0xFF111827),
          fontSize: 24,
          fontWeight: emphasizeValue ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      maxLines: 3,
      ellipsis: '...',
    )..layout(maxWidth: valueWidth);

    labelPainter.paint(canvas, Offset(x, y));
    valuePainter.paint(canvas, Offset(x + labelWidth + gap, y));

    return (labelPainter.height > valuePainter.height
            ? labelPainter.height
            : valuePainter.height) +
        22;
  }

  void _drawDashedDivider(
    Canvas canvas, {
    required double y,
    required double xStart,
    required double xEnd,
    double dashWidth = 14,
    double dashGap = 10,
  }) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 2;
    double currentX = xStart;
    while (currentX < xEnd) {
      final nextX = (currentX + dashWidth) > xEnd ? xEnd : currentX + dashWidth;
      canvas.drawLine(Offset(currentX, y), Offset(nextX, y), paint);
      currentX = nextX + dashGap;
    }
  }

  Future<Uint8List> _buildReceiptImageBytes() async {
    const canvasWidth = 1080.0;
    const canvasHeight = 1600.0;
    const cardPadding = 56.0;
    const cardTop = 56.0;
    const cardBottom = 56.0;
    const contentPadding = 52.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
      Paint()..color = const Color(0xFFF3F4F6),
    );

    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(
        cardPadding,
        cardTop,
        canvasWidth - (cardPadding * 2),
        canvasHeight - (cardTop + cardBottom),
      ),
      const Radius.circular(36),
    );

    canvas.drawRRect(
      cardRect.shift(const Offset(0, 12)),
      Paint()..color = const Color(0x1F111827),
    );
    canvas.drawRRect(cardRect, Paint()..color = Colors.white);

    final headerRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        cardPadding,
        cardTop,
        canvasWidth - (cardPadding * 2),
        182,
      ),
      topLeft: const Radius.circular(36),
      topRight: const Radius.circular(36),
    );
    canvas.drawRRect(headerRect, Paint()..color = const Color(0xFFFFE082));

    final logo = await _loadLogoImage();
    if (logo != null) {
      const logoSize = 84.0;
      final logoX = cardPadding + contentPadding;
      final logoY = cardTop + 48.0;
      final logoRect = Rect.fromLTWH(logoX, logoY, logoSize, logoSize);
      canvas.drawImageRect(
        logo,
        Rect.fromLTWH(
          0,
          0,
          logo.width.toDouble(),
          logo.height.toDouble(),
        ),
        logoRect,
        Paint(),
      );
    }

    _drawText(
      canvas,
      text: 'Savvy Bee',
      x: cardPadding + contentPadding + 104,
      y: cardTop + 58,
      maxWidth: 420,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 34,
        fontWeight: FontWeight.w800,
      ),
    );

    _drawText(
      canvas,
      text: 'Transaction Receipt',
      x: cardPadding + contentPadding + 104,
      y: cardTop + 106,
      maxWidth: 420,
      style: const TextStyle(
        color: Color(0xFF374151),
        fontSize: 25,
        fontWeight: FontWeight.w500,
      ),
    );

    final statusColor = transaction.isSuccess
        ? const Color(0xFF166534)
        : transaction.isPending
        ? const Color(0xFF9A3412)
        : const Color(0xFF991B1B);
    final statusBgColor = transaction.isSuccess
        ? const Color(0xFFDCFCE7)
        : transaction.isPending
        ? const Color(0xFFFFEDD5)
        : const Color(0xFFFEE2E2);
    final statusPillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(canvasWidth - 320, cardTop + 68, 210, 62),
      const Radius.circular(31),
    );
    canvas.drawRRect(statusPillRect, Paint()..color = statusBgColor);
    _drawText(
      canvas,
      text: transaction.status.value,
      x: canvasWidth - 320,
      y: cardTop + 84,
      maxWidth: 210,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: statusColor,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );

    var currentY = cardTop + 224.0;
    _drawText(
      canvas,
      text: transaction.isCredit ? 'Amount Received' : 'Amount Sent',
      x: cardPadding + contentPadding,
      y: currentY,
      maxWidth: canvasWidth - ((cardPadding + contentPadding) * 2),
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    );
    currentY += 36;

    currentY += _drawText(
      canvas,
      text: transaction.amount.formatCurrency(),
      x: cardPadding + contentPadding,
      y: currentY,
      maxWidth: canvasWidth - ((cardPadding + contentPadding) * 2),
      style: TextStyle(
        color: transaction.isFailed
            ? const Color(0xFF6B7280)
            : const Color(0xFF111827),
        fontSize: 64,
        fontWeight: FontWeight.w800,
        decoration: transaction.isFailed
            ? TextDecoration.lineThrough
            : TextDecoration.none,
      ),
    );

    currentY += 24;
    _drawDashedDivider(
      canvas,
      y: currentY,
      xStart: cardPadding + contentPadding,
      xEnd: canvasWidth - (cardPadding + contentPadding),
    );

    currentY += 34;
    currentY += _drawReceiptRow(
      canvas,
      x: cardPadding + contentPadding,
      y: currentY,
      width: canvasWidth - ((cardPadding + contentPadding) * 2),
      label: transaction.isCredit ? 'Received From' : 'Sent To',
      value: transaction.transactionFor,
      emphasizeValue: true,
    );

    if (transaction.charges > 0) {
      currentY += _drawReceiptRow(
        canvas,
        x: cardPadding + contentPadding,
        y: currentY,
        width: canvasWidth - ((cardPadding + contentPadding) * 2),
        label: 'Transfer Fee',
        value: transaction.charges.formatCurrency(),
      );
    }

    currentY += _drawReceiptRow(
      canvas,
      x: cardPadding + contentPadding,
      y: currentY,
      width: canvasWidth - ((cardPadding + contentPadding) * 2),
      label: 'Date & Time',
      value: transaction.createdAt.formatDateTime(),
    );

    if (transaction.koraReferenceId.isNotEmpty) {
      currentY += _drawReceiptRow(
        canvas,
        x: cardPadding + contentPadding,
        y: currentY,
        width: canvasWidth - ((cardPadding + contentPadding) * 2),
        label: 'Reference',
        value: transaction.koraReferenceId,
      );
    }

    if (transaction.narration.isNotEmpty) {
      currentY += _drawReceiptRow(
        canvas,
        x: cardPadding + contentPadding,
        y: currentY,
        width: canvasWidth - ((cardPadding + contentPadding) * 2),
        label: 'Narration',
        value: transaction.narration,
      );
    }

    currentY += 24;
    _drawDashedDivider(
      canvas,
      y: currentY,
      xStart: cardPadding + contentPadding,
      xEnd: canvasWidth - (cardPadding + contentPadding),
    );

    currentY += 28;
    _drawText(
      canvas,
      text: 'This receipt is generated by Savvy Bee.',
      x: cardPadding + contentPadding,
      y: currentY,
      maxWidth: canvasWidth - ((cardPadding + contentPadding) * 2),
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 22,
        fontWeight: FontWeight.w400,
      ),
    );

    currentY += 34;
    _drawText(
      canvas,
      text: 'Generated on ${DateTime.now().formatDateTime()}',
      x: cardPadding + contentPadding,
      y: currentY,
      maxWidth: canvasWidth - ((cardPadding + contentPadding) * 2),
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 20,
        fontWeight: FontWeight.w400,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw Exception('Failed to convert receipt image to bytes');
    }
    return bytes.buffer.asUint8List();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final directionLabel = isCredit ? 'From' : 'To';
    final dateLabel =
        '${transaction.createdAt.formatDayOrToday()},  ${transaction.createdAt.formatTime()}';
    final formattedAmount = transaction.amount.formatCurrency();
    final formattedCharges = transaction.charges.formatCurrency();
    final initials = transaction.transactionFor.isNotEmpty
        ? _initials(transaction.transactionFor)
        : '--';

    Color statusColor;
    if (transaction.isSuccess) {
      statusColor = const Color(0xFF22C55E);
    } else if (transaction.isPending) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount + Avatar row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedAmount,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              decoration: transaction.isFailed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: Colors.black,
                              decorationThickness: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(text: '$directionLabel '),
                                TextSpan(
                                  text: transaction.transactionFor,
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar + type chip
                    Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCredit
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF3F0FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isCredit
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF7C5CBF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                transaction.type.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCredit
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF7C5CBF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pushNamed(TransferScreenOne.path),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Send again',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _shareTransaction(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.black26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.upload_outlined,
                              color: Colors.black,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Narration / note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.narration.isNotEmpty
                        ? transaction.narration
                        : 'No note',
                    style: TextStyle(
                      fontSize: 14,
                      color: transaction.narration.isNotEmpty
                          ? Colors.black87
                          : Colors.black38,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Transaction info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _InfoCard(
                  rows: [
                    _DetailRow(
                      label: 'Status',
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            transaction.status.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _DetailRow(label: directionLabel, value: transaction.transactionFor),
                    if (transaction.koraReferenceId.isNotEmpty)
                      _DetailRow(
                        label: 'Transaction Reference',
                        valueWidget: _CopyableValue(
                          text: transaction.koraReferenceId,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Payment details card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _InfoCard(
                  rows: [
                    const _DetailRow(
                      label: 'Payment Method',
                      value: 'Bank Transfer',
                    ),
                    _DetailRow(
                      label: isCredit ? 'Amount received' : 'Amount sent',
                      value: formattedAmount,
                    ),
                    if (transaction.charges > 0)
                      _DetailRow(
                        label: 'Transfer Fee',
                        value: formattedCharges,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_DetailRow> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i != 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEAEAEA),
                indent: 16,
                endIndent: 16,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          valueWidget ??
              Text(
                value ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
      ),
    );
  }
}

class _CopyableValue extends StatelessWidget {
  final String text;
  final String? copyText;

  const _CopyableValue({required this.text, this.copyText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Clipboard.setData(ClipboardData(text: copyText ?? text)),
          child: const Icon(Icons.copy_outlined, size: 16, color: Colors.black45),
        ),
      ],
    );
  }
}
