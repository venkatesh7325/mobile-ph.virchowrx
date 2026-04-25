import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;

  const AppInput({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          autofocus: autofocus,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            counterText: '',
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textHint, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.inputFill : AppColors.inputFill.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class AppSearchInput extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchInput({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textHint),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  controller?.clear();
                  onChanged?.call('');
                  onClear?.call();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
