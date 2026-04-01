import 'package:animate_do/animate_do.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_tracking_bloc.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;
  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderTrackingBloc>()
        ..add(StartTrackingEvent(orderId: orderId)),
      child: const _OrderTrackingView(),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  const _OrderTrackingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: BlocBuilder<OrderTrackingBloc, TrackingState>(
          builder: (context, state) {
            if (state is TrackingLoadingState) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(AppConstants.lottieOrderTracking, width: 160, height: 160),
                    const Text('Connecting to your order...', style: AppTextStyles.bodyMedium),
                  ],
                ),
              );
            }

            if (state is TrackingErrorState) {
              return ChakulaChapErrorState(
                message: state.message,
                onRetry: () => context.read<OrderTrackingBloc>().add(
                  const StartTrackingEvent(orderId: 'retry'),
                ),
              );
            }

            if (state is TrackingActiveState) {
              return _buildTrackingUI(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTrackingUI(BuildContext context, TrackingActiveState state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, state)),
        SliverToBoxAdapter(child: _buildMapPlaceholder(state)),
        SliverToBoxAdapter(child: _buildStatusTimeline(state)),
        SliverToBoxAdapter(child: _buildRiderCard(state)),
        SliverToBoxAdapter(child: _buildOrderDetails(state)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TrackingActiveState state) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.home),
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
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tracking Order', style: AppTextStyles.h2),
              Text(state.order.orderNumber,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldBright)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildMapPlaceholder(TrackingActiveState state) => Container(
    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    height: 160,
    decoration: BoxDecoration(
      color: const Color(0xFF0A1A0A),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      border: Border.all(color: AppColors.navyAccent, width: 0.5),
    ),
    clipBehavior: Clip.hardEdge,
    child: Stack(
      children: [
        // Grid background
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter()),
        ),
        // Lottie delivery animation
        Center(
          child: Lottie.asset(
            AppConstants.lottieDelivery,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
        // ETA badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: [
                Text('${state.etaMinutes}', style: AppTextStyles.h1.copyWith(color: AppColors.navyDeep, fontSize: 22)),
                Text('min', style: AppTextStyles.caption.copyWith(color: AppColors.navyDeep, fontSize: 10)),
              ],
            ),
          ),
        ),
        // Live indicator
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text('LIVE', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 9)),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStatusTimeline(TrackingActiveState state) {
    final steps = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.pickedUp,
      OrderStatus.delivered,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Progress', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final currentStep = state.currentStatus.step;
            final isDone = step.step <= currentStep;
            final isActive = step.step == currentStep;
            final isLast = i == steps.length - 1;

            return FadeInLeft(
              delay: Duration(milliseconds: i * 80),
              duration: AppConstants.animMedium,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDone
                              ? (isActive ? AppColors.goldBright : AppColors.successBg)
                              : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                            color: isDone
                                ? (isActive ? AppColors.goldBright : AppColors.success)
                                : AppColors.navyAccent,
                            width: isActive ? 2 : 0.5,
                          ),
                          boxShadow: isActive
                              ? [BoxShadow(color: AppColors.goldBright.withValues(alpha: 0.4), blurRadius: 12)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            step.emoji,
                            style: TextStyle(fontSize: isActive ? 22 : 18),
                          ),
                        ),
                      ),
                      if (!isLast)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 2,
                          height: 28,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isDone && !isActive ? AppColors.success : AppColors.navyAccent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isDone ? AppColors.textPrimary : AppColors.textMuted,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        if (isActive)
                          Text(
                            'In progress...',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldBright),
                          ),
                        if (isDone && !isActive)
                          Text(
                            '✓ Completed',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRiderCard(TrackingActiveState state) {
    final rider = state.order.rider;
    if (rider == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.navyAccent, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Rider 🛵', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Center(child: Text('🧑', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rider.name, style: AppTextStyles.h4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 13, color: AppColors.goldBright),
                        const SizedBox(width: 3),
                        Text('${rider.rating}', style: AppTextStyles.bodySmall),
                        Text(' · ${rider.totalDeliveries} deliveries',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _RiderActionBtn(
                    icon: Icons.phone_rounded,
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _RiderActionBtn(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppColors.goldBright,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(TrackingActiveState state) {
    final order = state.order;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.navyAccent, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Items', style: AppTextStyles.h4),
              Text('${order.items.length} items',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldBright)),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(i.menuItem.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(child: Text(i.menuItem.name, style: AppTextStyles.bodyMedium)),
                Text('×${i.quantity}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted)),
              ],
            ),
          )),
          const Divider(color: AppColors.navyAccent),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Paid', style: AppTextStyles.h4),
              Text('Tsh ${order.total.toInt()}', style: AppTextStyles.priceLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiderActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RiderActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, color: color, size: 20),
    ),
  );
}

// Simple grid background painter for map placeholder
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00).withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}