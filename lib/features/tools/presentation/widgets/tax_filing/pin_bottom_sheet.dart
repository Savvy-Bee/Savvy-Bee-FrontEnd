// lib/core/widgets/tax_filing/pin_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

/// Shows a bottom sheet that collects a 4-digit PIN.
/// Returns the entered PIN as a [String] when the user confirms,
/// or null if dismissed.
///
/// Usage:
///   final pin = await PinBottomSheet.show(context, title: 'Confirm payment');
///   if (pin != null) { ... proceed with payment ... }
class PinBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String confirmLabel;

  const PinBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
  });

  /// Convenience method — shows the sheet and returns the PIN or null.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String subtitle =
        'Enter your 4-digit transaction PIN to authorise this payment.',
    String confirmLabel = 'Confirm',
  }) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinBottomSheet(
        title: title,
        subtitle: subtitle,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends State<PinBottomSheet> {
  final List<TextEditingController> _ctrls = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());
  bool _obscure = true;

  static const _yellow = Color(0xFFF5C842);

  static TextStyle _gs(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black87,
  }) => TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * 0.02,
  );

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _pin => _ctrls.map((c) => c.text).join();
  bool get _complete => _pin.length == 4;

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _onConfirm() {
    if (!_complete) return;
    Navigator.of(context).pop(_pin);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(20),

          // ── Icon ──────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _yellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, color: _yellow, size: 24),
            ),
          ),
          const Gap(16),

          // ── Title ─────────────────────────────────────────────────────
          Center(
            child: Text(
              widget.title,
              style: _gs(18, weight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(6),
          Center(
            child: Text(
              widget.subtitle,
              style: _gs(13, color: AppColors.greyDark),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(28),

          // ── PIN boxes ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 58,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _ctrls[i].text.isNotEmpty
                        ? _yellow
                        : const Color(0xFFE5E5E5),
                    width: _ctrls[i].text.isNotEmpty ? 1.8 : 1.0,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _ctrls[i],
                    focusNode: _nodes[i],
                    keyboardType: TextInputType.number,
                    obscureText: _obscure,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: _gs(22, weight: FontWeight.w700),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => _onDigitEntered(i, v),
                  ),
                ),
              );
            }),
          ),
          const Gap(12),

          // ── Toggle visibility ─────────────────────────────────────────
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 16,
                color: AppColors.greyDark,
              ),
              label: Text(
                _obscure ? 'Show PIN' : 'Hide PIN',
                style: _gs(12, color: AppColors.greyDark),
              ),
            ),
          ),
          const Gap(20),

          // ── Confirm button ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _complete ? _onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _yellow,
                disabledBackgroundColor: _yellow.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                widget.confirmLabel,
                style: _gs(15, weight: FontWeight.w600, color: Colors.black),
              ),
            ),
          ),
          const Gap(8),

          // ── Cancel ────────────────────────────────────────────────────
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel', style: _gs(13, color: AppColors.greyDark)),
            ),
          ),
        ],
      ),
    );
  }
}
