import 'package:chakula_chap/core/widgets/chakula_chap_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/order_entity.dart';

class OrderConfirmPage extends StatefulWidget {
  final String orderId;
  final OrderEntity? order;
  const OrderConfirmPage({super.key, required this.orderId, this.order});

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                AppConstants.lottieSuccess,
                controller: _lottieController,
                width: 200,
                height: 200,
                onLoaded: (comp) {
                  _lottieController
                    ..duration = comp.duration
                    ..forward();
                },
              ),
              const SizedBox(height: AppDimensions.spaceLg),
              const Text('Order Placed! 🎉', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.spaceMd),
              if (order != null) ...[
                Text(
                  order.orderNumber,
                  style: AppTextStyles.h3.copyWith(color: AppColors.goldBright),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
              ],
              const Text(
                'Your order has been received and the kitchen is being notified.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              // Selcom control number
              if (order?.controlNumber != null) ...[
                const SizedBox(height: AppDimensions.spaceLg),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.selcom.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: AppColors.selcom.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Text('🧾 Selcom Control Number', style: AppTextStyles.h4.copyWith(color: AppColors.selcom)),
                      const SizedBox(height: 8),
                      SelectableText(
                        order!.controlNumber!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pay via Selcom app, agent, or bank branch. Order confirms automatically on payment.',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.spaceXl),
              ChakulaChapButton(
                label: '📍 Track My Order',
                onPressed: () => context.go('/order/tracking/${widget.orderId}'),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              ChakulaChapButton(
                label: 'Back to Home',
                variant: ChakulaChapButtonVariant.outline,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}