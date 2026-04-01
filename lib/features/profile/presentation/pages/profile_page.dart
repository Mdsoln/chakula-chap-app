
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/block/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  final UserEntity? user;
  const ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: _ProfileView(user: user),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final UserEntity? user;
  const _ProfileView({this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnauthenticatedState) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.navyDeep,
        body: Stack(
          children: [
            // Background gradient header
            Positioned(
              top: 0, left: 0, right: 0,
              height: 220,
              child: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildMenuSection(context),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final name = user?.name ?? 'New User';
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: AppColors.navyAccent, width: 0.5),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2,
                ),
              ),
              const SizedBox(width: 40), // balance the back button
            ],
          ),
          const SizedBox(height: 28),

          // Avatar
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldBright.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.navyDeep),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(name, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            user?.phone ?? '',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),

          if (user?.verified == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.success, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Info Card ──────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.navyAccent, width: 0.5),
        ),
        child: Column(
          children: [
            _InfoTile(
              icon: Icons.person_outline_rounded,
              label: 'Full Name',
              value: user?.name ?? '—',
            ),
            _buildDivider(),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Mobile',
              value: user?.phone ?? '—',
            ),
            _buildDivider(),
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user?.email ?? 'Not provided',
              valueColor: user?.email != null
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
            _buildDivider(),
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: user != null ? _formatDate(user!.createdAt) : '—',
            ),
          ],
        ),
      ),
    );
  }

  // ── Menu Section ───────────────────────────────────────────────────────────

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.navyAccent, width: 0.5),
        ),
        child: Column(
          children: [
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              label: 'Order History',
              onTap: () => context.push(AppRoutes.orderHistory),
            ),
            _buildDivider(),
            _MenuTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => context.push(AppRoutes.notifications),
            ),
            _buildDivider(),
            _MenuTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () {},
            ),
            _buildDivider(),
            _MenuTile(
              icon: Icons.info_outline_rounded,
              label: 'App Version',
              trailing: Text(
                AppConstants.appVersion,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoadingState;
          return GestureDetector(
            onTap: isLoading
                ? null
                : () => context.read<AuthBloc>().add(const LogoutEvent()),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: isLoading
                  ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.error,
                    strokeWidth: 2,
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildDivider() => const Divider(
    height: 1,
    thickness: 0.5,
    color: AppColors.navyAccent,
    indent: 52,
  );

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ── Reusable Tiles ─────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.goldPure, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}