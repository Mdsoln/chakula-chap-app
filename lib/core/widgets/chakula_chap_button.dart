import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

enum ChakulaChapButtonVariant { primary, secondary, outline, ghost, danger }

class ChakulaChapButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ChakulaChapButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? height;
  final double? borderRadius;

  const ChakulaChapButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ChakulaChapButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.height,
    this.borderRadius,
  });

  @override
  State<ChakulaChapButton> createState() => _ChakulaChapButtonState();
}

class _ChakulaChapButtonState extends State<ChakulaChapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: (_) => !isDisabled ? _scaleController.forward() : null,
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            height: widget.height ?? AppDimensions.buttonHeight,
            width: widget.isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: _buildDecoration(),
            child: Center(
              child: widget.isLoading
                  ? _buildLoader()
                  : _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final radius = widget.borderRadius ?? AppDimensions.radiusMd;

    switch (widget.variant) {
      case ChakulaChapButtonVariant.primary:
        return BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldBright.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case ChakulaChapButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.navyMedium,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.navyAccent),
        );
      case ChakulaChapButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.goldBright, width: 1.5),
        );
      case ChakulaChapButtonVariant.ghost:
        return BoxDecoration(
          color: AppColors.goldGlow,
          borderRadius: BorderRadius.circular(radius),
        );
      case ChakulaChapButtonVariant.danger:
        return BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.error),
        );
    }
  }

  Color get _labelColor {
    switch (widget.variant) {
      case ChakulaChapButtonVariant.primary:
        return AppColors.navyDeep;
      case ChakulaChapButtonVariant.danger:
        return AppColors.error;
      default:
        return AppColors.goldBright;
    }
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(_labelColor),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null) ...[
          widget.prefixIcon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: AppTextStyles.buttonText.copyWith(color: _labelColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: 8),
          widget.suffixIcon!,
        ],
      ],
    );
  }
}