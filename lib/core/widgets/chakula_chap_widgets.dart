import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'chakula_chap_button.dart';

// ── Shimmer Loading Wrapper ───────────────────────────────────────────────────

class ChakulaChapShimmer extends StatelessWidget {
  final Widget child;
  const ChakulaChapShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.navyMedium,
      highlightColor: AppColors.navyLight,
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = AppDimensions.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: AppColors.navyMedium,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class ChakulaChapEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? lottieAsset;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ChakulaChapEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.lottieAsset,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: AppDimensions.spaceMd),
            Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.spaceSm),
              Text(subtitle!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spaceLg),
              ChakulaChapButton(label: actionLabel!, onPressed: onAction, isFullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class ChakulaChapErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ChakulaChapErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(AppConstants.lottieError, width: 180, height: 180),
            const SizedBox(height: AppDimensions.spaceMd),
            const Text('Oops!', style: AppTextStyles.h1),
            const SizedBox(height: AppDimensions.spaceSm),
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spaceLg),
              ChakulaChapButton(
                label: 'Try Again',
                onPressed: onRetry,
                variant: ChakulaChapButtonVariant.outline,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Customer Number Pad ───────────────────────────────────────────────────────────
class ChakulaChapNumpad extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final VoidCallback? onComplete;

  const ChakulaChapNumpad({
    super.key,
    required this.controller,
    this.maxLength = 9,
    this.onComplete,
  });

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    if (controller.text.length >= maxLength) return;
    controller.text += key;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    if (controller.text.length == maxLength) onComplete?.call();
  }

  void _onBackspace() {
    HapticFeedback.mediumImpact();
    if (controller.text.isEmpty) return;
    controller.text =
        controller.text.substring(0, controller.text.length - 1);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];

        if (key.isEmpty) return const SizedBox.shrink();

        final isBackspace = key == '⌫';

        return Ink(
          decoration: BoxDecoration(
            color: AppColors.navyMedium,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.navyAccent, width: 0.5),
          ),
          child: InkWell(
            onTap: isBackspace ? _onBackspace : () => _onKeyTap(key),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // ← ripple follows shape
            child: Container(
              alignment: Alignment.center,
              child: isBackspace
                  ? const Icon(
                Icons.backspace_outlined,
                color: AppColors.textSecondary,
                size: 22,
              )
                  : Text(
                key,
                style: AppTextStyles.h2,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Snackbar Helper ───────────────────────────────────────────────────────────
void showChakulaChapSnackbar(
    BuildContext context, {
      required String message,
      bool isError = false,
      bool isSuccess = false,
      Duration duration = const Duration(seconds: 3),
    }) {
  Color bgColor = AppColors.surfaceElevated;
  Color textColor = AppColors.textPrimary;
  IconData icon = Icons.info_rounded;

  if (isError) {
    bgColor = AppColors.errorBg;
    textColor = AppColors.error;
    icon = Icons.error_rounded;
  } else if (isSuccess) {
    bgColor = AppColors.successBg;
    textColor = AppColors.success;
    icon = Icons.check_circle_rounded;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: BorderSide(color: textColor.withValues(alpha: 0.3)),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppDimensions.spaceMd),
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
            ),
          ],
        ),
      ),
    );
}