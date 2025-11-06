import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label, endLabel;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool isRounded;
  final bool showOutline;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final VoidCallback? onEndLabelPressed;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final TextInputAction textInputAction;
  final String? subText;

  const CustomTextFormField({
    super.key,
    this.label,
    this.endLabel,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.isRounded = false,
    this.showOutline = true,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.onEndLabelPressed,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.fillColor,
    this.contentPadding,
    this.textInputAction = TextInputAction.next,
    this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            if (endLabel != null)
              InkWell(
                onTap: onEndLabelPressed,
                child: Text(
                  endLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
              ),
          ],
        ),
        if (label != null) const Gap(4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          textCapitalization: textCapitalization,
          focusNode: focusNode,
          onTap: onTap,
          readOnly: readOnly,
          // style: AppTypography.bodyMedium,
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            hintText: hint,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.0,
              color: AppColors.grey,
            ),
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isRounded ? 24 : 8),
              borderSide: BorderSide(color: AppColors.greyDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isRounded ? 24 : 8),
              borderSide: BorderSide(
                color: showOutline ? AppColors.borderDark : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isRounded ? 24 : 8),
              borderSide: BorderSide(
                color: showOutline ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isRounded ? 24 : 8),
              borderSide: BorderSide(
                color: showOutline ? AppColors.error : Colors.transparent,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isRounded ? 24 : 8),
              borderSide: BorderSide(
                color: showOutline ? AppColors.error : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        ),
        const Gap(4.0),
        if (subText != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              subText!,
              style: TextStyle(
                fontSize: 10,
                fontFamily: Constants.exconFontFamily,
              ),
            ),
          ),
      ],
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const CustomSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      focusNode: focusNode,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textLight),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.backgroundDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class CustomOtpField extends StatefulWidget {
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;

  const CustomOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<CustomOtpField> createState() => _CustomOtpFieldState();
}

class _CustomOtpFieldState extends State<CustomOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    setState(() {
      if (value.isNotEmpty) {
        // Move to next field
        if (index < widget.length - 1) {
          _focusNodes[index + 1].requestFocus();
        } else {
          // Last field, unfocus
          _focusNodes[index].unfocus();
        }
      } else {
        // Handle backspace - move to previous field
        if (index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    });

    // Notify parent of changes
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(otp);

    // Check if completed
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < widget.length - 1 ? 10 : 0),
            child: _buildOtpBox(index),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: _focusNodes[index].hasFocus
        //       ? AppColors.primary
        //       : AppColors.greyDark,
        //   width: _focusNodes[index].hasFocus ? 2 : 1,
        // ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        cursorHeight: 20.0,
        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.black, width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onChanged(value, index),
        onTap: () {
          setState(() {
            _controllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _controllers[index].text.length),
            );
          });
        },
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}
