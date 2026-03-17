import 'dart:async';
import 'package:chakula_chap/core/widgets/chakula_chap_button.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../block/auth_bloc.dart';

class OtpPage extends StatelessWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: _OtpView(phone: phone),
    );
  }
}

class _OtpView extends StatefulWidget {
  final String phone;
  const _OtpView({required this.phone});

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  late Timer _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  void _onOtpComplete(String otp) {
    context.read<AuthBloc>().add(
      VerifyOtpEvent(phone: widget.phone, otp: otp),
    );
  }

  void _onResend() {
    _pinController.clear();
    _timer.cancel();
    _startTimer();
    context.read<AuthBloc>().add(ResendOtpEvent(phone: widget.phone));
  }

  String get _maskedPhone {
    // Show +255 7XX ***XXX
    final digits = widget.phone.replaceAll('+255', '').replaceAll(' ', '');
    if (digits.length < 9) return widget.phone;
    return '+255 ${digits.substring(0, 3)} ***${digits.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          setState(() => _isVerifying = true);
        } else {
          setState(() => _isVerifying = false);
        }
        if (state is AuthenticatedState) {
          if (state.user.name == null || state.user.name!.isEmpty) {
            context.go(AppRoutes.registration, extra: state.user.phone);
          } else {
            context.go(AppRoutes.home, extra: state.user);
          }
        }
        if (state is AuthErrorState) {
          _pinController.clear();
          showChakulaChapSnackbar(context, message: state.message, isError: true);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(decoration: const BoxDecoration(gradient: AppColors.heroGradient)),
            SafeArea(
              child: SingleChildScrollView(
                padding: AppDimensions.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.spaceMd),
                    _buildBackButton(context),
                    const SizedBox(height: AppDimensions.spaceLg),
                    //_buildIllustration(),
                    const SizedBox(height: AppDimensions.spaceLg),
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.spaceXl),
                    _buildPinInput(),
                    const SizedBox(height: AppDimensions.spaceLg),
                    _buildVerifyButton(),
                    const SizedBox(height: AppDimensions.spaceMd),
                    _buildResendRow(),
                  ],
                ),
              ),
            ),
            // Success overlay
            if (_isVerifying) _buildVerifyingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.navyAccent, width: 0.5),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  // Widget _buildIllustration() {
  //   return Center(
  //     child: Lottie.asset(
  //       AppConstants.lottiePayment,
  //       width: 160,
  //       height: 160,
  //       fit: BoxFit.contain,
  //     ),
  //   );
  // }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verify your number', style: AppTextStyles.displayMedium),
        const SizedBox(height: AppDimensions.spaceSm),
        Text.rich(
          TextSpan(
            text: 'We sent a ${AppConstants.otpLength}-digit code to ',
            style: AppTextStyles.bodyMedium,
            children: [
              TextSpan(
                text: _maskedPhone,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.goldBright,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinInput() {
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 62,
      textStyle: AppTextStyles.h1.copyWith(color: AppColors.goldBright),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.navyAccent, width: 0.8),
      ),
    );

    return Center(
      child: Pinput(
        length: AppConstants.otpLength,
        controller: _pinController,
        focusNode: _focusNode,
        autofocus: true,
        onCompleted: _onOtpComplete,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.goldBright, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldBright.withOpacity(0.2),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: AppColors.goldGlow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.goldBright, width: 1.5),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: AppColors.errorBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ChakulaChapButton(
          label: 'Verify & Continue',
          isLoading: state is AuthLoadingState,
          onPressed: _pinController.text.length == AppConstants.otpLength
              ? () => _onOtpComplete(_pinController.text)
              : null,
        );
      },
    );
  }

  Widget _buildResendRow() {
    return Center(
      child: _canResend
          ? TextButton(
        onPressed: _onResend,
        child: Text(
          'Resend OTP',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.goldBright),
        ),
      )
          : Text.rich(
        TextSpan(
          text: 'Resend code in ',
          style: AppTextStyles.bodySmall,
          children: [
            TextSpan(
              text: '${_secondsRemaining}s',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.goldBright,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyingOverlay() {
    return Container(
      color: AppColors.navyDeep.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(AppConstants.lottieLoading, width: 120, height: 120),
            const SizedBox(height: AppDimensions.spaceMd),
            Text('Verifying...', style: AppTextStyles.h3.copyWith(color: AppColors.goldBright)),
          ],
        ),
      ),
    );
  }
}