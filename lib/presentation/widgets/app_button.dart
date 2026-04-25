import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonType { primary, secondary, outline, text, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  double get _height {
    switch (size) {
      case AppButtonSize.small: return 40;
      case AppButtonSize.medium: return 48;
      case AppButtonSize.large: return 56;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small: return 13;
      case AppButtonSize.medium: return 14;
      case AppButtonSize.large: return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final colors = _resolveColors(disabled);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _height,
      child: Material(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: type == AppButtonType.outline
                  ? Border.all(color: colors['border']!, width: 1.5)
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(colors['fg']),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: _fontSize + 4, color: colors['fg']),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: AppTypography.button.copyWith(
                            color: colors['fg'],
                            fontSize: _fontSize,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, Color> _resolveColors(bool disabled) {
    if (disabled) {
      return {
        'bg': type == AppButtonType.outline || type == AppButtonType.text
            ? Colors.transparent
            : AppColors.textDisabled.withOpacity(0.3),
        'fg': AppColors.textDisabled,
        'border': AppColors.textDisabled,
      };
    }

    switch (type) {
      case AppButtonType.primary:
        return {'bg': AppColors.primary, 'fg': AppColors.white, 'border': AppColors.primary};
      case AppButtonType.secondary:
        return {'bg': AppColors.secondary, 'fg': AppColors.white, 'border': AppColors.secondary};
      case AppButtonType.outline:
        return {'bg': Colors.transparent, 'fg': AppColors.primary, 'border': AppColors.primary};
      case AppButtonType.text:
        return {'bg': Colors.transparent, 'fg': AppColors.primary, 'border': Colors.transparent};
      case AppButtonType.danger:
        return {'bg': AppColors.error, 'fg': AppColors.white, 'border': AppColors.error};
    }
  }
}
