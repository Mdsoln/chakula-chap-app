import 'package:chakula_chap/core/widgets/chakula_chap_button.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import 'auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      SendOtpEvent(
        phone: '${AppConstants.countryCode}${_phoneController.text.trim()}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          context.push(AppRoutes.otp, extra: state.phone);
        }
        if (state is AuthErrorState) {
          showChakulaChapSnackbar(context, message: state.message, isError: true);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            ),
            // Gold glow
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  gradient: AppColors.goldGlowGradient,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: AppDimensions.screenPadding,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.space2xl),
                        _buildHeader(),
                        const SizedBox(height: AppDimensions.space2xl),
                        _buildForm(),
                        const SizedBox(height: AppDimensions.spaceLg),
                        _buildSendButton(),
                        const SizedBox(height: AppDimensions.spaceLg),
                        _buildDivider(),
                        const SizedBox(height: AppDimensions.spaceLg),
                        _buildSocialButtons(),
                        const SizedBox(height: AppDimensions.spaceXl),
                        _buildTermsText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zetu logo mark
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: const Center(
            child: Text('Z', style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.navyDeep)),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceLg),
        const Text('Welcome back 👋', style: AppTextStyles.displayMedium),
        const SizedBox(height: AppDimensions.spaceSm),
        Text(
          'Sign in with your phone number to\ncontinue ordering.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PHONE NUMBER',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.goldMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          Row(
            children: [
              // Country code badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMd,
                  vertical: AppDimensions.spaceMd,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.navyAccent, width: 0.8),
                ),
                child: const Row(
                  children: [
                    Text('🇹🇿', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 6),
                    Text('+255', style: AppTextStyles.labelLarge),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              // Phone number input
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: AppTextStyles.h3.copyWith(letterSpacing: 2),
                  decoration: const InputDecoration(
                    hintText: '7XX XXX XXX',
                    hintStyle: TextStyle(letterSpacing: 2, color: AppColors.textDisabled),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter your phone number';
                    if (value.length < 9) return 'Enter a valid 9-digit number';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ChakulaChapButton(
          label: 'Send OTP Code',
          isLoading: state is AuthLoadingState,
          onPressed: _onSendOtp,
          suffixIcon: const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.navyDeep),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd),
          child: Text('or continue with', style: AppTextStyles.bodySmall),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: '🔵',
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Expanded(
          child: _SocialButton(
            label: 'Facebook',
            icon: '📘',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: AppTextStyles.bodySmall,
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldBright),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldBright),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.navyAccent, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }
}