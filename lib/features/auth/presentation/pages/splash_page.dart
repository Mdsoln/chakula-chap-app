import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/auth_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    final signature = await SmsAutoFill().getAppSignature;
    debugPrint('==========================================');
    debugPrint('APP SIGNATURE HASH: [$signature]');
    debugPrint('==========================================');

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.kOnboardingDone) ?? false;
    final authRepo = getIt<AuthRepository>();
    final isLoggedIn = await authRepo.isAuthenticated;

    if (!mounted) return;

    if (!onboardingDone) {
      context.go(AppRoutes.onboarding);
    } else if (isLoggedIn) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            const _GoldGlow(top: -100, right: -100, size: 400),
            const _GoldGlow(bottom: -80, left: -60, size: 280),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SplashIcon(),
                  const SizedBox(height: AppDimensions.spaceLg),
                  const _AppLogotype(),
                  const SizedBox(height: AppDimensions.spaceXs),
                  Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.bodyMedium.copyWith(
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space3xl),
                  const _LoadingDots(),
                ],
              ),
            ),
            const _VersionTag(),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _GoldGlow extends StatelessWidget {
  const _GoldGlow({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          gradient: AppColors.goldGlowGradient,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SplashIcon extends StatelessWidget {
  const _SplashIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.goldBright,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldBright.withOpacity(0.3),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppConstants.splashIcon,
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AppLogotype extends StatelessWidget {
  const _AppLogotype();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'ChakulaChap',
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.goldBright,
        letterSpacing: 8,
      ),
    );
  }
}

class _VersionTag extends StatelessWidget {
  const _VersionTag();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Text(
        'v${AppConstants.appVersion}',
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((_controller.value - delay).abs() % 1.0);
            final scale = value < 0.5 ? 1.0 + value : 2.0 - value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale.clamp(0.6, 1.4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.goldBright,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}