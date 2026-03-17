
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/chakula_chap_widgets.dart';
import '../../domain/entities/order_entity.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  static final _mockOrders = [
    _MockOrder(
      id: 'CCHAP-20240001',
      items: 'Nyama Choma, Ugali, Kachumbari',
      total: 18500,
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _MockOrder(
      id: 'CCHAP-20240002',
      items: 'Pilau, Kuku wa Kupaka',
      total: 24000,
      status: OrderStatus.preparing,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _MockOrder(
      id: 'CCHAP-20240003',
      items: 'Mishkaki x4, Chips',
      total: 11000,
      status: OrderStatus.cancelled,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    _MockOrder(
      id: 'CCHAP-20240004',
      items: 'Biryani, Juice ya Mango',
      total: 16500,
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 160,
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _mockOrders.isEmpty
                      ? ChakulaChapEmptyState(
                    title: 'No orders yet',
                    subtitle: 'Your order history will appear here.',
                    lottieAsset: AppConstants.lottieEmptyCart,
                    actionLabel: 'Browse Menu',
                    onAction: () => context.go(AppRoutes.home),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    itemCount: _mockOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OrderCard(
                      order: _mockOrders[i],
                      onTrack: _mockOrders[i].status == OrderStatus.pickedUp ||
                          _mockOrders[i].status == OrderStatus.preparing
                          ? () => context.push(
                        AppRoutes.orderTracking
                            .replaceFirst(':orderId', _mockOrders[i].id),
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
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
                Text(
                  '${_mockOrders.length} orders',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final _MockOrder order;
  final VoidCallback? onTrack;

  const _OrderCard({required this.order, this.onTrack});

  @override
  Widget build(BuildContext context) {
    final (Color statusColor, Color statusBg) = switch (order.status) {
      OrderStatus.delivered  => (AppColors.success, AppColors.successBg),
      OrderStatus.cancelled  => (AppColors.error,   AppColors.errorBg),
      OrderStatus.failed     => (AppColors.error,   AppColors.errorBg),
      _                      => (AppColors.goldBright, AppColors.goldGlow),
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
                '#${order.id}',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.goldBright),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${order.status.emoji} ${order.status.label}',
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Items ──────────────────────────────────────────
          Text(
            order.items,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                    'Tsh ${order.total.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                    style: AppTextStyles.labelLarge,
                  ),
                  Text(
                    _formatDate(order.date),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              if (onTrack != null)
                GestureDetector(
                  onTap: onTrack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      'Track Order',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyDeep),
                    ),
                  ),
                ),
              if (order.status == OrderStatus.delivered)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.navyAccent, width: 0.5),
                    ),
                    child: Text(
                      'Reorder',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ── Mock model (temporary until OrderBloc is wired) ───────────────────────────

class _MockOrder {
  final String id;
  final String items;
  final int total;
  final OrderStatus status;
  final DateTime date;

  const _MockOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.date,
  });
}