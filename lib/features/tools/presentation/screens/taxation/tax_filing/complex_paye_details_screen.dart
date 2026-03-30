// lib/features/tools/presentation/screens/taxation/tax_filing/complex_paye_details_screen.dart
//
// Shows details of a single Complex/Pro PAYE filing.
// • Business info, revenues, non-taxable revenues
// • Status banner (Processing / Price Assigned / Finished / Rejected)
// • Chat-style review thread
// • Reply bar (visible when status == Processing)
// • Payment flow (when status == Assigned-Price):
//     init → show price → pay filing fee (PIN) → pay liability fee (PIN) → history

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/complex_paye_models.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/complex_paye_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_home_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/tax_filing/bottom_action_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplexPayeDetailsScreen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.complexPayeDetails;

  final String filingId;
  const ComplexPayeDetailsScreen({super.key, required this.filingId});

  @override
  ConsumerState<ComplexPayeDetailsScreen> createState() =>
      _ComplexPayeDetailsScreenState();
}

class _ComplexPayeDetailsScreenState
    extends ConsumerState<ComplexPayeDetailsScreen> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<XFile> _pendingFiles = [];
  bool _isSending = false;
  bool _isPaying = false;
  bool _breakdownExpanded = false;
  bool _autoPayTriggered = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── File picker ─────────────────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      for (final f in result.files) {
        if (kIsWeb && f.bytes != null) {
          _pendingFiles.add(XFile.fromData(f.bytes!, name: f.name));
        } else if (!kIsWeb && f.path != null) {
          _pendingFiles.add(XFile(f.path!));
        }
      }
    });
  }

  void _removePending(int i) => setState(() => _pendingFiles.removeAt(i));

  // ── Send reply ───────────────────────────────────────────────────────────────

  Future<void> _sendReply() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty && _pendingFiles.isEmpty) return;
    if (_isSending) return;

    setState(() => _isSending = true);
    try {
      final repo = ref.read(complexPayeRepositoryProvider);
      final review = await repo.uploadReview(
        id: widget.filingId,
        comment: text,
        files: List.from(_pendingFiles),
      );
      _commentCtrl.clear();
      setState(() => _pendingFiles.clear());
      await ref
          .read(complexPayeDetailProvider(widget.filingId).notifier)
          .addReview(review);
    } catch (e) {
      if (!mounted) return;
      AppNotification.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        icon: Icons.error_outline,
        iconColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ── Payment flow ─────────────────────────────────────────────────────────────

  Future<void> _startPayment(ComplexPayeDetailRecord record) async {
    if (_isPaying) return;
    setState(() => _isPaying = true);

    try {
      final repo = ref.read(complexPayeRepositoryProvider);
      final initResult = await repo.initPayment(widget.filingId);

      if (!mounted) return;

      // Show price summary sheet
      final proceed = await _showPriceSheet(
        context,
        filingFee: initResult.filingFee,
        taxLiability: initResult.taxLiability,
        walletBalance: initResult.walletBalance,
      );
      if (proceed != true || !mounted) return;

      // Write to shared filing providers so Step 4 & 5 work as-is
      // Use the _id from the init payment response, not the temp record ID.
      ref.read(filingIDProvider.notifier).state = initResult.id;
      ref.read(filingTaxDueProvider.notifier).state = initResult.taxLiability;
      ref.read(filingWalletBalanceProvider.notifier).state = initResult.walletBalance;
      ref.read(selectedFilingPlanProvider.notifier).state = 'Pro Complex';
      // Store the actual PayePrice so Step 4 shows a real amount
      ref.read(complexPayeFilingFeeProvider.notifier).state = initResult.filingFee;

      context.pushNamed(FilingRoutes.step4);
    } catch (e) {
      if (!mounted) return;
      AppNotification.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        icon: Icons.error_outline,
        iconColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  Future<bool?> _showPriceSheet(
    BuildContext ctx, {
    required double filingFee,
    required double taxLiability,
    required double walletBalance,
  }) {
    return showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PriceSheet(
        filingFee: filingFee,
        taxLiability: taxLiability,
        walletBalance: walletBalance,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complexPayeDetailProvider(widget.filingId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Filing Details'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(complexPayeDetailProvider(widget.filingId).notifier)
                .refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 14),
              ),
              const Gap(16),
              TextButton(
                onPressed: () => ref
                    .read(
                      complexPayeDetailProvider(widget.filingId).notifier,
                    )
                    .refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (record) => _body(record),
      ),
    );
  }

  Widget _body(ComplexPayeDetailRecord record) {
    // Auto-show payment sheet on first load when status is PendingPayment
    if (record.autoTriggerPayment && !_autoPayTriggered) {
      _autoPayTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startPayment(record);
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(complexPayeDetailProvider(widget.filingId).notifier)
                  .refresh(),
              child: ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  _StatusBanner(status: record.status),
                  const Gap(16),
                  _FinanceCard(record: record),
                  const Gap(16),
                  _InfoCard(record: record),
                  const Gap(16),
                  _BreakdownSection(
                    record: record,
                    expanded: _breakdownExpanded,
                    onToggle: () =>
                        setState(() => _breakdownExpanded = !_breakdownExpanded),
                  ),
                  if (record.reviews.isNotEmpty) ...[
                    const Gap(20),
                    _SectionLabel(label: 'Reviews'),
                    const Gap(8),
                    ...record.reviews.map((r) => _ReviewBubble(review: r)),
                  ],
                  const Gap(8),
                ],
              ),
            ),
          ),
          if (record.canPay)
            BottomActionButton(
              label: 'Start Payment',
              isLoading: _isPaying,
              onTap: _isPaying ? null : () => _startPayment(record),
            )
          else if (record.canReply)
            _ReplyBar(
              ctrl: _commentCtrl,
              files: _pendingFiles,
              isSending: _isSending,
              onAttach: _pickFiles,
              onRemoveFile: _removePending,
              onSend: _sendReply,
            ),
        ],
      ),
    );
  }
}

// ── Status banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final ComplexPayeStatus status;
  const _StatusBanner({required this.status});

  static const _yellow = Color(0xFFF5C842);

  Color get _bg {
    switch (status) {
      case ComplexPayeStatus.processing:
        return Colors.blue.shade50;
      case ComplexPayeStatus.assignedPrice:
        return _yellow.withValues(alpha: 0.12);
      case ComplexPayeStatus.pendingPayment:
        return Colors.orange.shade50;
      case ComplexPayeStatus.finished:
        return Colors.green.shade50;
      case ComplexPayeStatus.rejected:
        return Colors.red.shade50;
      case ComplexPayeStatus.unknown:
        return Colors.grey.shade100;
    }
  }

  Color get _fg {
    switch (status) {
      case ComplexPayeStatus.processing:
        return Colors.blue.shade700;
      case ComplexPayeStatus.assignedPrice:
        return const Color(0xFFB8900A);
      case ComplexPayeStatus.pendingPayment:
        return Colors.orange.shade800;
      case ComplexPayeStatus.finished:
        return Colors.green.shade700;
      case ComplexPayeStatus.rejected:
        return Colors.red.shade700;
      case ComplexPayeStatus.unknown:
        return Colors.grey.shade700;
    }
  }

  IconData get _icon {
    switch (status) {
      case ComplexPayeStatus.processing:
        return Icons.hourglass_empty_rounded;
      case ComplexPayeStatus.assignedPrice:
        return Icons.price_check_rounded;
      case ComplexPayeStatus.pendingPayment:
        return Icons.payment_rounded;
      case ComplexPayeStatus.finished:
        return Icons.check_circle_rounded;
      case ComplexPayeStatus.rejected:
        return Icons.cancel_rounded;
      case ComplexPayeStatus.unknown:
        return Icons.help_outline;
    }
  }

  String get _subtitle {
    switch (status) {
      case ComplexPayeStatus.processing:
        return 'Your filing is under review by a tax consultant.';
      case ComplexPayeStatus.assignedPrice:
        return 'A price has been assigned. Tap "Start Payment" below.';
      case ComplexPayeStatus.pendingPayment:
        return 'Payment required. Loading payment details…';
      case ComplexPayeStatus.finished:
        return 'Your filing has been completed successfully.';
      case ComplexPayeStatus.rejected:
        return 'Filing was rejected. Send a reply with corrections.';
      case ComplexPayeStatus.unknown:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _fg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayLabel,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _fg,
                  ),
                ),
                if (_subtitle.isNotEmpty) ...[
                  const Gap(2),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 12,
                      color: _fg.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Finance card ──────────────────────────────────────────────────────────────

class _FinanceCard extends StatelessWidget {
  final ComplexPayeDetailRecord record;
  const _FinanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.businessName.isNotEmpty
                ? record.businessName
                : 'Pro / Complex Filing',
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Gap(4),
          Text(
            'Tax Year ${record.year}',
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const Gap(14),
          if (record.filingFee > 0 || record.taxLiability > 0) ...[
            _FinanceTile(
              label: 'Filing Fee',
              value: record.filingFee.formatCurrency(),
            ),
            _FinanceTile(
              label: 'Tax Liability',
              value: record.taxLiability.formatCurrency(),
            ),
          ],
          if (record.assignedPrice > 0)
            _FinanceTile(
              label: 'Assigned Price',
              value: record.assignedPrice.formatCurrency(),
              highlight: true,
            ),
        ],
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _FinanceTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: highlight
                  ? const Color(0xFFF5C842)
                  : Colors.white70,
            ),
          ),
          Text(
            '₦$value',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlight ? const Color(0xFFF5C842) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ComplexPayeDetailRecord record;
  const _InfoCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Filing Info'),
          const Gap(10),
          _InfoRow(label: 'TIN', value: record.tin),
          _InfoRow(label: 'Classification', value: record.classification),
          if (record.cacNumber.isNotEmpty)
            _InfoRow(label: 'CAC Number', value: record.cacNumber),
          if (record.description.isNotEmpty)
            _InfoRow(label: 'Description', value: record.description),
          if (record.phone.isNotEmpty)
            _InfoRow(label: 'Phone', value: record.phone),
          if (record.email.isNotEmpty)
            _InfoRow(label: 'Email', value: record.email),
          if (record.address.isNotEmpty)
            _InfoRow(label: 'Address', value: record.address),
          if (record.createdAt != null)
            _InfoRow(
              label: 'Submitted',
              value: DateFormat('d MMM y').format(record.createdAt!),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12,
                color: AppColors.greyDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Breakdown section ─────────────────────────────────────────────────────────

class _BreakdownSection extends StatelessWidget {
  final ComplexPayeDetailRecord record;
  final bool expanded;
  final VoidCallback onToggle;
  const _BreakdownSection({
    required this.record,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasData =
        record.revenues.isNotEmpty || record.noneTaxableRevenues.isNotEmpty;
    if (!hasData) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              const _SectionLabel(label: 'Income Breakdown'),
              const Spacer(),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: AppColors.greyDark,
              ),
            ],
          ),
        ),
        if (expanded) ...[
          const Gap(10),
          if (record.revenues.isNotEmpty) ...[
            Text(
              'Revenues',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.greyDark,
              ),
            ),
            const Gap(6),
            ...record.revenues.map(
              (r) => _RevenueRow(source: r.source, amount: r.amount),
            ),
          ],
          if (record.noneTaxableRevenues.isNotEmpty) ...[
            const Gap(10),
            Text(
              'Non-Taxable',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.greyDark,
              ),
            ),
            const Gap(6),
            ...record.noneTaxableRevenues.map(
              (r) => _RevenueRow(source: r.source, amount: r.amount),
            ),
          ],
        ],
      ],
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String source;
  final double amount;
  const _RevenueRow({required this.source, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              source,
              style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 13),
            ),
          ),
          Text(
            '₦${amount.formatCurrency()}',
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review bubble ─────────────────────────────────────────────────────────────

class _ReviewBubble extends StatelessWidget {
  final ComplexPayeReview review;
  const _ReviewBubble({required this.review});

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _fileName(String url) {
    final name = url.split('/').last.split('?').first;
    return name.isNotEmpty ? name : 'Document';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = review.isFromUser;
    final hasText = review.text.isNotEmpty;
    final hasDocs = review.documentUrls.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFFF5C842).withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasText)
                  Text(
                    review.text,
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                    ),
                  ),
                if (hasText && hasDocs) const Gap(8),
                if (hasDocs)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: review.documentUrls.map((url) {
                      return GestureDetector(
                        onTap: () => _openUrl(url),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isUser
                                  ? const Color(0xFFF5C842)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insert_drive_file_outlined,
                                size: 14,
                                color: isUser
                                    ? const Color(0xFFB8900A)
                                    : AppColors.greyDark,
                              ),
                              const SizedBox(width: 5),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 160),
                                child: Text(
                                  _fileName(url),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'GeneralSans',
                                    fontSize: 11,
                                    color: isUser
                                        ? const Color(0xFFB8900A)
                                        : AppColors.greyDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const Gap(3),
          Text(
            '${isUser ? 'You' : 'Consultant'} · ${DateFormat('d MMM, HH:mm').format(review.createdAt)}',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 11,
              color: AppColors.greyDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reply bar ─────────────────────────────────────────────────────────────────

class _ReplyBar extends StatelessWidget {
  final TextEditingController ctrl;
  final List<XFile> files;
  final bool isSending;
  final VoidCallback onAttach;
  final ValueChanged<int> onRemoveFile;
  final VoidCallback onSend;

  const _ReplyBar({
    required this.ctrl,
    required this.files,
    required this.isSending,
    required this.onAttach,
    required this.onRemoveFile,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (files.isNotEmpty) ...[
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) => Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        files[i].name,
                        style: const TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => onRemoveFile(i),
                        child: const CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(6),
          ],
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: onAttach,
                color: AppColors.greyDark,
                splashRadius: 20,
              ),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  maxLines: null,
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    hintStyle: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 13,
                      color: AppColors.greyDark,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: Color(0xFFF5C842),
                        width: 1.6,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: isSending ? null : onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSending
                        ? Colors.grey.shade300
                        : const Color(0xFFF5C842),
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.send, size: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Price sheet ───────────────────────────────────────────────────────────────

class _PriceSheet extends StatelessWidget {
  final double filingFee;
  final double taxLiability;
  final double walletBalance;
  const _PriceSheet({
    required this.filingFee,
    required this.taxLiability,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    final total = filingFee + taxLiability;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          Text(
            'Review the amounts before proceeding.',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13,
              color: AppColors.greyDark,
            ),
          ),
          const Gap(20),
          _SheetRow(label: 'Filing Fee', value: filingFee),
          _SheetRow(label: 'Tax Liability', value: taxLiability),
          const Divider(height: 20),
          _SheetRow(label: 'Total', value: total, bold: true),
          const Gap(6),
          _SheetRow(
            label: 'Wallet Balance',
            value: walletBalance,
            color: walletBalance >= total
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5C842),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Proceed',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  final Color? color;
  const _SheetRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'GeneralSans',
      fontSize: bold ? 15 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${value.formatCurrency()}', style: style),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 15 * 0.02,
      ),
    );
  }
}
