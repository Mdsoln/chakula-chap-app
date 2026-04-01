
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/chakula_chap_widgets.dart';

enum _NotifType { order, promo, system }

class _NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final _NotifType type;
  final bool isRead;

  const _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Mock notifications — replace with BLoC + real data later
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      id: '1',
      title: 'Order Confirmed! ✅',
      body: 'Your order #CCHAP-20240001 has been confirmed and is being prepared.',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      type: _NotifType.order,
      isRead: false,
    ),
    _NotificationItem(
      id: '2',
      title: 'Your rider is on the way 🛵',
      body: 'Hassan is heading to your location. ETA: 12 minutes.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: _NotifType.order,
      isRead: false,
    ),
    _NotificationItem(
      id: '3',
      title: 'Weekend Special 🔥',
      body: 'Get 20% off all orders above Tsh 15,000 this weekend only!',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: _NotifType.promo,
      isRead: true,
    ),
    _NotificationItem(
      id: '4',
      title: 'Order Delivered 🏠',
      body: 'Your order #CCHAP-20230998 was delivered. Enjoy your meal!',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: _NotifType.order,
      isRead: true,
    ),
    _NotificationItem(
      id: '5',
      title: 'New dishes added 🍽️',
      body: 'Check out the new Zanzibar seafood menu — available now!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: _NotifType.promo,
      isRead: true,
    ),
    _NotificationItem(
      id: '6',
      title: 'App updated',
      body: 'ChakulaChap v${AppConstants.appVersion} is here with faster delivery tracking.',
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: _NotifType.system,
      isRead: true,
    ),
  ];

  void _markAllRead() {
    setState(() {
      _notifications.replaceRange(
        0,
        _notifications.length,
        _notifications.map((n) => _NotificationItem(
          id: n.id,
          title: n.title,
          body: n.body,
          time: n.time,
          type: n.type,
          isRead: true,
        )).toList(),
      );
    });
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

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
                  child: _notifications.isEmpty
                      ? const ChakulaChapEmptyState(
                    title: 'No notifications',
                    subtitle: 'You\'re all caught up! Check back later.',
                    lottieAsset: AppConstants.lottieEmptyCart,
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _NotifCard(
                      item: _notifications[i],
                      onTap: () => setState(() {
                        _notifications[i] = _NotificationItem(
                          id: _notifications[i].id,
                          title: _notifications[i].title,
                          body: _notifications[i].body,
                          time: _notifications[i].time,
                          type: _notifications[i].type,
                          isRead: true,
                        );
                      }),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                const Text('Notifications', style: AppTextStyles.h2),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount unread',
                    style: AppTextStyles.caption.copyWith(color: AppColors.goldBright),
                  ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllRead,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.navyAccent, width: 0.5),
                ),
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.goldBright),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notification Card ──────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onTap;

  const _NotifCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surfaceCard : AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: item.isRead ? AppColors.navyAccent : AppColors.goldBright.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: item.isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.goldBright,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(item.time),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final (IconData icon, Color color) = switch (item.type) {
      _NotifType.order  => (Icons.receipt_long_rounded, AppColors.goldBright),
      _NotifType.promo  => (Icons.local_offer_rounded, AppColors.success),
      _NotifType.system => (Icons.info_outline_rounded, AppColors.info),
    };

    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}