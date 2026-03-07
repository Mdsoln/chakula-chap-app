import 'package:chakula_chap/core/widgets/chakula_chap_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = const [
    _OnboardingSlide(
      lottieAsset: 'assets/animations/delivery.json',
      title: 'Your community,\nyour food.',
      subtitle: 'Order from local restaurant favourites and get it delivered to your door, fast.',
      emoji: '🍽️',
    ),
    _OnboardingSlide(
      lottieAsset: 'assets/animations/order_tracking.json',
      title: 'Track every\nstep live.',
      subtitle: 'Real-time order status from the moment you place it to the moment it arrives.',
      emoji: '📍',
    ),
    _OnboardingSlide(
      lottieAsset: 'assets/animations/payment.json',
      title: 'Pay your\nway.',
      subtitle: 'M-Pesa, Airtel, Tigo, AzamPesa, Selcom control number, or cash on delivery.',
      emoji: '💳',
    ),
  ];

  Future<void> _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kOnboardingDone, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            // Gold glow accent
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  gradient: AppColors.goldGlowGradient,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: [
                // Skip button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _onGetStarted,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) =>
                        _buildSlide(_slides[index]),
                  ),
                ),
                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spaceMd,
                    AppDimensions.spaceMd,
                    AppDimensions.spaceMd,
                    AppDimensions.spaceLg,
                  ),
                  child: Column(
                    children: [
                      _buildDots(),
                      const SizedBox(height: AppDimensions.spaceLg),
                      SafeArea(
                        top: false,
                        child: _buildNavButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide) {
    return Padding(
      padding: AppDimensions.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            slide.lottieAsset,
            width: 260,
            height: 260,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppDimensions.spaceLg),
          Text(
            slide.title,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Text(
            slide.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
            (i) => AnimatedContainer(
          duration: AppConstants.animFast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentPage ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentPage ? AppColors.goldBright : AppColors.navyAccent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton() {
    final isLast = _currentPage == _slides.length - 1;
    return ChakulaChapButton(
      label: isLast ? 'Get Started 🎉' : 'Next',
      onPressed: isLast
          ? _onGetStarted
          : () => _pageController.nextPage(
        duration: AppConstants.animMedium,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

class _OnboardingSlide {
  final String lottieAsset;
  final String title;
  final String subtitle;
  final String emoji;

  const _OnboardingSlide({
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}