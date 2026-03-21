
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/chakula_chap_button.dart';
import '../../../../core/widgets/chakula_chap_widgets.dart';
import '../block/registration_bloc.dart';

class RegistrationPage extends StatelessWidget {
  final String phone;

  const RegistrationPage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegistrationBloc>(),
      child: _RegistrationView(phone: phone),
    );
  }
}

class _RegistrationView extends StatefulWidget {
  final String phone;
  const _RegistrationView({required this.phone});

  @override
  State<_RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<_RegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<RegistrationBloc>().add(
      SubmitRegistrationEvent(
        phone: widget.phone,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state is RegistrationSuccessState) {
          // pass user data as extra
          context.go(AppRoutes.home, extra: state.user);
        }
        if (state is RegistrationErrorState) {
          showChakulaChapSnackbar(
            context,
            message: state.message,
            isError: true,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration:
              const BoxDecoration(gradient: AppColors.heroGradient),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: AppDimensions.screenPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text('Complete your profile',
                          style: AppTextStyles.displaySmall,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Tell us a bit about yourself',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 40),

                      // Full Name
                      const Text('Full Name', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Muddy Ramadhan',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          if (v.trim().length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Email (Optional)
                      Row(
                        children: [
                          const Text('Email', style: AppTextStyles.labelMedium),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Optional',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.goldPure),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(
                              text: newValue.text.toLowerCase(),
                            );
                          }),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'e.g. mdsoln@chakulachap.co.tz',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final emailRegex =
                          RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pre-filled phone (read-only)
                      const Text('Mobile', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: widget.phone,
                        readOnly: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: AppColors.surface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Submit Button
                      BlocBuilder<RegistrationBloc, RegistrationState>(
                        builder: (context, state) {
                          return ChakulaChapButton(
                            label: 'Continue',
                            isLoading: state is RegistrationLoadingState,
                            onPressed: _onSubmit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}