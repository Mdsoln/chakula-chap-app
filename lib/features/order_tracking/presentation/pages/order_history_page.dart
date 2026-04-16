import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/chakula_chap_widgets.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_history_bloc.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderHistoryBloc>()..add(LoadOrderHistoryEvent()),
      child: const _OrderHistoryView(),
    );
  }
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration:
              const BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ),
          SafeArea(
            child: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildHeader(context, state),
                    Expanded(child: _buildBody(context, state)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OrderHistoryState state) {
    final orderCount = state is OrderHistoryLoadedState
        ? state.orders.length
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.navyAccent, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order History', style: AppTextStyles.h2),
                if (orderCount != null)
                  Text(
                    '$orderCount order${orderCount == 1 ? '' : 's'}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          // Refresh button — only visible when data is loaded
          if (state is OrderHistoryLoadedState)
            GestureDetector(
              onTap: () => context
                  .read<OrderHistoryBloc>()
                  .add(RefreshOrderHistoryEvent()),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
                  border:
                  Border.all(color: AppColors.navyAccent, width: 0.5),
                ),
                child: state.isRefreshing
                    ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    color: AppColors.goldBright,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.refresh_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderHistoryState state) {
    if (state is OrderHistoryLoadingState) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.goldBright,
          strokeWidth: 2,
        ),
      );
    }

    if (state is OrderHistoryErrorState) {
      return ChakulaChapErrorState(
        message: state.message,
        onRetry: () =>
            context.read<OrderHistoryBloc>().add(LoadOrderHistoryEvent()),
      );
    }

    if (state is OrderHistoryLoadedState) {
      if (state.orders.isEmpty) {
        return ChakulaChapEmptyState(
          title: 'No orders yet',
          subtitle: 'Your order history will appear here.',
          lottieAsset: AppConstants.lottieEmptyCart,
          actionLabel: 'Browse Menu',
          onAction: () => context.go(AppRoutes.home),
        );
      }

      return RefreshIndicator(
        color: AppColors.goldBright,
        backgroundColor: AppColors.surfaceCard,
        onRefresh: () async => context
            .read<OrderHistoryBloc>()
            .add(RefreshOrderHistoryEvent()),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          itemCount: state.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final order = state.orders[i];
            return _OrderCard(
              order: order,
              onTrack: _isTrackable(order.status)
                  ? () => context.push(
                AppRoutes.orderTracking
                    .replaceFirst(':orderId', order.id),
              )
                  : null,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  bool _isTrackable(OrderStatus status) =>
      status == OrderStatus.confirmed ||
          status == OrderStatus.preparing ||
          status == OrderStatus.ready ||
          status == OrderStatus.pickedUp;
}

// ── Order Card ─────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTrack;

  const _OrderCard({required this.order, this.onTrack});

  @override
  Widget build(BuildContext context) {
    final (Color statusColor, Color statusBg) = switch (order.status) {
      OrderStatus.delivered => (AppColors.success, AppColors.successBg),
      OrderStatus.cancelled => (AppColors.error, AppColors.errorBg),
      OrderStatus.failed => (AppColors.error, AppColors.errorBg),
      _ => (AppColors.goldBright, AppColors.goldGlow),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.navyAccent, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderNumber}',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.goldBright),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius:
                  BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${order.status.emoji} ${order.status.label}',
                  style:
                  AppTextStyles.labelSmall.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Items summary ──────────────────────────────────
          Text(
            _formatItems(order.items),
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // ── Bottom row ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tsh ${_formatAmount(order.total)}',
                    style: AppTextStyles.labelLarge,
                  ),
                  Text(
                    _formatDate(order.placedAt),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              _buildActionButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (onTrack != null) {
      return GestureDetector(
        onTap: onTrack,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            'Track Order',
            style:
            AppTextStyles.labelSmall.copyWith(color: AppColors.navyDeep),
          ),
        ),
      );
    }

    if (order.status == OrderStatus.delivered) {
      return GestureDetector(
        onTap: () {
          // TODO: Re-order logic implementation
        },
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: AppColors.navyAccent, width: 0.5),
          ),
          child: Text(
            'Reorder',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatItems(List items) {
    if (items.isEmpty) return 'No items';
    return items
        .map((i) => '${i.menuItem.emoji} ${i.menuItem.name}')
        .join(', ');
  }

  String _formatAmount(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}