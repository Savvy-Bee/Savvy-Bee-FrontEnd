// lib/features/tools/presentation/screens/taxation/filing/filing_details_screen.dart
//
// Full filing detail with:
//   • Finance summary (dark card, matches existing step screens)
//   • Account details
//   • Income / deduction breakdown (collapsible)
//   • Reviews as a chat-style thread (newest first)
//   • Reply area — text + file attachments (only when canReply)
//   • "View Filing Document" banner when status == Completed
//   • Pull-to-refresh + app-bar refresh button
//   • GestureDetector on root to dismiss keyboard

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/notifications/app_notification.dart';
import 'package:savvy_bee_mobile/core/widgets/tax_filing/filing_routes.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_history_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/filing_history_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FilingDetailsScreen extends ConsumerStatefulWidget {
  static const String path = FilingRoutes.filingDetails;

  final String filingId;
  const FilingDetailsScreen({super.key, required this.filingId});

  @override
  ConsumerState<FilingDetailsScreen> createState() =>
      _FilingDetailsScreenState();
}

class _FilingDetailsScreenState extends ConsumerState<FilingDetailsScreen> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<XFile> _pendingFiles = [];
  bool _isSending = false;
  bool _breakdownExpanded = false;

  static const _yellow = Color(0xFFF5C842);

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

  // ── Send reply ──────────────────────────────────────────────────────────────

  Future<void> _sendReply() async {
    final comment = _commentCtrl.text.trim();
    if (comment.isEmpty && _pendingFiles.isEmpty) return;
    if (_isSending) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);

    final ID = widget.filingId;
    print('Filing ID: $ID');

    try {
      final repo = ref.read(filingHistoryRepositoryProvider);
      await repo.uploadReview(
        filingId: widget.filingId,
        comment: comment,
        files: List.from(_pendingFiles),
      );

      _commentCtrl.clear();
      setState(() => _pendingFiles.clear());

      // Refresh to get server-confirmed review list
      await ref.read(filingDetailProvider(widget.filingId).notifier).refresh();

      if (mounted) {
        AppNotification.show(
          context,
          message: 'Reply sent.',
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF43A047),
        );
        // Scroll to top — reviews shown newest-first
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          icon: Icons.error_outline,
          iconColor: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ── Open document link ──────────────────────────────────────────────────────

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      AppNotification.show(
        context,
        message: 'Could not open the document.',
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(filingDetailProvider(widget.filingId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Filing Details'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Refresh',
              onPressed: () => ref
                  .read(filingDetailProvider(widget.filingId).notifier)
                  .refresh(),
            ),
          ],
        ),
        body: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorBody(
            message: e.toString().replaceFirst('Exception: ', ''),
            onRetry: () => ref
                .read(filingDetailProvider(widget.filingId).notifier)
                .refresh(),
          ),
          data: (record) => Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(filingDetailProvider(widget.filingId).notifier)
                      .refresh(),
                  child: ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                      _buildHeader(record),
                      const Gap(16),
                      // Completed filing banner
                      if (record.isCompleted &&
                          record.filingUploadLink != null) ...[
                        _CompletedBanner(
                          onTap: () => _openLink(record.filingUploadLink!),
                        ),
                        const Gap(16),
                      ],
                      _buildFinanceSummary(record),
                      const Gap(12),
                      _buildBreakdown(record),
                      if (record.acctsDetails != null) ...[
                        const Gap(12),
                        _buildAccountDetails(record.acctsDetails!),
                      ],
                      const Gap(24),
                      _buildReviewsSection(record),
                      const Gap(8),
                    ],
                  ),
                ),
              ),
              // Reply bar — shown only when filing is under review
              if (record.canReply) _buildReplyBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section builders ────────────────────────────────────────────────────────

  Widget _buildHeader(FilingDetailRecord record) {
    final color = _statusColor(record.status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 6,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _yellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    '${record.year} Tax Return',
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 22 * 0.02,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Wrap(
                spacing: 6,
                children: [
                  _MetaChip(label: record.plan),
                  if (record.classification != null)
                    _MetaChip(label: record.classification!),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusBadge(label: record.status.displayLabel, color: color),
      ],
    );
  }

  Widget _buildFinanceSummary(FilingDetailRecord record) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Finance Summary',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 14 * 0.02,
            ),
          ),
        ),
        const Gap(10),
        _DarkRow(
          label: 'Annual Revenue',
          value: record.annualRevenue.formatCurrency(decimalDigits: 0),
        ),
        _DarkRow(
          label: 'Total Deductions',
          value:
              '-${record.noneTaxableIncome.formatCurrency(decimalDigits: 0)}',
          isNegative: true,
        ),
        _DarkRow(
          label: 'Taxable Income',
          value: record.taxableIncome.formatCurrency(decimalDigits: 0),
        ),
        _DarkRow(
          label: 'Effective Rate',
          value: '${record.effectiveTaxRate.toStringAsFixed(1)}%',
        ),
        _DarkRow(
          label: 'Tax Amount',
          value: record.taxAmount.formatCurrency(decimalDigits: 0),
          isHighlight: true,
        ),
        if (record.tin != null)
          _DarkRow(label: 'TIN', value: record.tin!, isLast: true),
      ],
    ),
  );

  Widget _buildBreakdown(FilingDetailRecord record) {
    final hasRevenues = record.revenues.isNotEmpty;
    final hasDeductions = record.noneTaxableRevenues.isNotEmpty;
    if (!hasRevenues && !hasDeductions) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () =>
                setState(() => _breakdownExpanded = !_breakdownExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Income & Deductions',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 14 * 0.02,
                      ),
                    ),
                  ),
                  Icon(
                    _breakdownExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _breakdownExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasRevenues) ...[
                    _SubHeading(label: 'Revenues'),
                    const Gap(6),
                    ...record.revenues.map(
                      (r) => _InfoRow(
                        label: r.source,
                        value: r.amount.formatCurrency(decimalDigits: 0),
                      ),
                    ),
                  ],
                  if (hasRevenues && hasDeductions) const Divider(height: 20),
                  if (hasDeductions) ...[
                    _SubHeading(label: 'Deductions'),
                    const Gap(6),
                    ...record.noneTaxableRevenues
                        .where((r) => r.amount > 0)
                        .map(
                          (r) => _InfoRow(
                            label: r.source,
                            value: r.amount.formatCurrency(decimalDigits: 0),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails(FilingAcctsDetails accts) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.borderLight),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Details',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 14 * 0.02,
          ),
        ),
        const Gap(10),
        if (accts.name.isNotEmpty) _InfoRow(label: 'Name', value: accts.name),
        if (accts.cacNumber?.isNotEmpty ?? false)
          _InfoRow(label: 'CAC', value: accts.cacNumber!),
        if (accts.phoneNo?.isNotEmpty ?? false)
          _InfoRow(label: 'Phone', value: accts.phoneNo!),
        if (accts.email?.isNotEmpty ?? false)
          _InfoRow(label: 'Email', value: accts.email!),
        if (accts.address?.isNotEmpty ?? false)
          _InfoRow(label: 'Address', value: accts.address!),
      ],
    ),
  );

  Widget _buildReviewsSection(FilingDetailRecord record) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 16 * 0.02,
            ),
          ),
          const Spacer(),
          if (record.reviews.isNotEmpty)
            Text(
              '${record.reviews.length} message${record.reviews.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12,
                color: AppColors.greyDark,
              ),
            ),
        ],
      ),
      const Gap(4),
      if (!record.canReply && !record.isCompleted)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Replies are available only while the filing is under review.',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 12,
              color: AppColors.greyDark,
            ),
          ),
        ),
      const Gap(8),
      if (record.reviews.isEmpty)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No messages yet.',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 13,
                color: AppColors.greyDark,
              ),
            ),
          ),
        )
      else
        ...record.reviews.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReviewBubble(review: r, onLinkTap: _openLink),
          ),
        ),
    ],
  );

  Widget _buildReplyBar() => Container(
    padding: EdgeInsets.fromLTRB(
      16,
      10,
      16,
      MediaQuery.of(context).padding.bottom + 10,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.borderLight)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending attachments
        if (_pendingFiles.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (int i = 0; i < _pendingFiles.length; i++)
                _AttachmentChip(
                  name: _pendingFiles[i].name,
                  onRemove: () => _removePending(i),
                ),
            ],
          ),
          const Gap(8),
        ],

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attach button
            GestureDetector(
              onTap: _isSending ? null : _pickFiles,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.attach_file,
                  size: 20,
                  color: _isSending ? AppColors.grey : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Text input
            Expanded(
              child: TextField(
                controller: _commentCtrl,
                minLines: 1,
                maxLines: 5,
                enabled: !_isSending,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write a reply…',
                  hintStyle: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _yellow, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: _isSending ? null : _sendReply,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _isSending ? AppColors.grey : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Color _statusColor(FillingStatus s) {
    switch (s) {
      case FillingStatus.completed:
        return const Color(0xFF43A047);
      case FillingStatus.validatingTax:
        return const Color(0xFF1565C0);
      case FillingStatus.rejected:
      case FillingStatus.failed:
        return Colors.redAccent;
      case FillingStatus.pendingPayment:
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF5C6BC0);
    }
  }
}

// ── Completed banner ──────────────────────────────────────────────────────────

class _CompletedBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CompletedBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF43A047).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.task_outlined,
              size: 22,
              color: Color(0xFF43A047),
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filing Complete',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                Gap(2),
                Text(
                  'Your completed filing document is ready. Tap to view or download.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    color: Color(0xFF388E3C),
                    letterSpacing: 12 * 0.02,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, size: 18, color: Color(0xFF43A047)),
        ],
      ),
    ),
  );
}

// ── Review bubble ─────────────────────────────────────────────────────────────

class _ReviewBubble extends StatelessWidget {
  final FilingReview review;
  final void Function(String url) onLinkTap;
  const _ReviewBubble({required this.review, required this.onLinkTap});

  static const _yellow = Color(0xFFF5C842);
  static final _fmt = DateFormat('d MMM y · HH:mm');

  @override
  Widget build(BuildContext context) {
    final isUser = review.isFromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isUser ? 14 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 14),
            ),
            border: isUser ? null : Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                decoration: BoxDecoration(
                  color: isUser
                      ? _yellow.withValues(alpha: 0.2)
                      : const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  isUser ? 'You' : 'Tax Agency',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isUser ? _yellow : const Color(0xFF1565C0),
                    letterSpacing: 9 * 0.02,
                  ),
                ),
              ),
              const Gap(6),

              // Message
              if (review.text.isNotEmpty)
                Text(
                  review.text,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 13,
                    color: isUser ? Colors.white : Colors.black87,
                    letterSpacing: 13 * 0.02,
                  ),
                ),

              // Attachments
              if (review.documentUrls.isNotEmpty) ...[
                const Gap(8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: review.documentUrls
                      .map(
                        (url) => _DocumentChip(
                          url: url,
                          onTap: () => onLinkTap(url),
                        ),
                      )
                      .toList(),
                ),
              ],

              const Gap(6),
              Text(
                _fmt.format(review.createdAt.toLocal()),
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 9,
                  color: isUser ? Colors.white38 : AppColors.greyDark,
                  letterSpacing: 9 * 0.02,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Document chip (in received message) ──────────────────────────────────────

class _DocumentChip extends StatelessWidget {
  final String url;
  final VoidCallback onTap;
  const _DocumentChip({required this.url, required this.onTap});

  String get _name {
    final parts = url.split('/');
    return parts.isNotEmpty ? parts.last : 'Document';
  }

  bool get _isImage {
    final l = url.toLowerCase();
    return l.endsWith('.jpg') ||
        l.endsWith('.jpeg') ||
        l.endsWith('.png') ||
        l.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(
            _isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
            size: 13,
            color: Colors.white70,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              _name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Pending attachment chip ───────────────────────────────────────────────────

class _AttachmentChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;
  const _AttachmentChip({required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
    decoration: BoxDecoration(
      color: AppColors.greyLight,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        const Icon(Icons.attach_file, size: 13, color: Colors.black54),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, size: 13, color: Colors.black54),
        ),
      ],
    ),
  );
}

// ── Shared layout widgets ─────────────────────────────────────────────────────

class _DarkRow extends StatelessWidget {
  final String label, value;
  final bool isNegative, isHighlight, isLast;
  const _DarkRow({
    required this.label,
    required this.value,
    this.isNegative = false,
    this.isHighlight = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            color: Colors.white70,
            letterSpacing: 13 * 0.02,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isHighlight
                ? const Color(0xFFF5C842)
                : isNegative
                ? Colors.redAccent.shade100
                : Colors.white,
            letterSpacing: 13 * 0.02,
          ),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 12,
              color: AppColors.greyDark,
              letterSpacing: 12 * 0.02,
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
              letterSpacing: 12 * 0.02,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SubHeading extends StatelessWidget {
  final String label;
  const _SubHeading({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontFamily: 'GeneralSans',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.greyDark,
      letterSpacing: 12 * 0.02,
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 10 * 0.02,
      ),
    ),
  );
}

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.greyLight,
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 11 * 0.02,
      ),
    ),
  );
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
          const Gap(12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'GeneralSans', fontSize: 13),
          ),
          const Gap(16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
