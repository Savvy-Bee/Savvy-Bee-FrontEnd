import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';

class CustomDropdownButton extends StatelessWidget {
  final String? label, hint;
  final List<String> items;
  final String? value; // Add this parameter
  final void Function(String?)? onChanged;
  final Widget? leadingIcon;
  final bool enabled;
  final TextEditingController? controller; // Optional controller

  const CustomDropdownButton({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value, // Add this
    this.onChanged,
    this.leadingIcon,
    this.enabled = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(24);
    var borderSide = BorderSide(color: AppColors.borderDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
        if (label != null) const Gap(4),
        DropdownMenu<String>(
          leadingIcon: leadingIcon,
          trailingIcon: Icon(Icons.keyboard_arrow_down),
          selectedTrailingIcon: Icon(Icons.keyboard_arrow_up),
          hintText: hint,
          expandedInsets: EdgeInsets.zero,
          menuHeight: MediaQuery.sizeOf(context).height / 2,
          enabled: enabled,
          initialSelection: value,
          controller: controller,
          menuStyle: MenuStyle(
            surfaceTintColor: WidgetStatePropertyAll(AppColors.background),
            backgroundColor: WidgetStatePropertyAll(AppColors.background),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.background,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.0,
              color: AppColors.grey,
            ),
            isCollapsed: true,
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: borderSide,
            ),
            outlineBorder: BorderSide(color: AppColors.greyDark),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: borderSide,
            ),
            focusedBorder: OutlineInputBorder(borderRadius: borderRadius),
            errorBorder: OutlineInputBorder(borderRadius: borderRadius),
            focusedErrorBorder: OutlineInputBorder(borderRadius: borderRadius),
          ),
          dropdownMenuEntries: List.generate(
            items.length,
            (index) => DropdownMenuEntry<String>(
              value: items[index],
              label: items[index],
            ),
          ),
          onSelected: onChanged,
        ),
      ],
    );
  }
}
