import 'package:animate_do/animate_do.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/cart_bloc.dart';
import '../../domain/entities/cart_entity.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CartBloc>()..add(LoadCartEvent()),
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoadingState) {
              return const Center(child: CircularProgressIndicator(color: AppColors.goldBright));
            }

            final cart = switch (state) {
              CartLoadedState s => s.cart,
              CartItemAddedState s => s.cart,
              _ => null,
            };

            if (cart == null) return const SizedBox.shrink();

            return Column(
              children: [
                _buildHeader(context, cart),
                Expanded(
                  child: cart.isEmpty ? _buildEmpty() : _buildCartList(context, cart),
                ),
                if (!cart.isEmpty) _buildSummaryAndCheckout(context, cart),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartEntity cart) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(
      children: [
        GestureDetector(
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
        ),
        const SizedBox(width: 14),
        const Expanded(child: Text('Your Cart 🛒', style: AppTextStyles.h2)),
        if (!cart.isEmpty)
          TextButton(
            onPressed: () => context.read<CartBloc>().add(ClearCartEvent()),
            child: Text('Clear', style: AppTextStyles.labelMedium.copyWith(color: AppColors.error)),
          ),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(AppConstants.lottieEmptyCart, width: 200, height: 200),
        const SizedBox(height: 16),
        const Text('Cart is empty', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        const Text('Add something delicious first!', style: AppTextStyles.bodyMedium),
      ],
    ),
  );

  Widget _buildCartList(BuildContext context, CartEntity cart) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    itemCount: cart.items.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, i) => FadeInLeft(
      delay: Duration(milliseconds: i * 50),
      duration: AppConstants.animMedium,
      child: _CartItemTile(item: cart.items[i]),
    ),
  );

  Widget _buildSummaryAndCheckout(BuildContext context, CartEntity cart) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      border: const Border(top: BorderSide(color: AppColors.navyAccent, width: 0.5)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -4))],
    ),
    child: Column(
      children: [
        if (cart.qualifiesForFreeDelivery)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text('🎉 Free delivery unlocked!',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.success)),
              ],
            ),
          ),
        _SummaryRow(label: 'Subtotal', value: 'Tsh ${cart.subtotal.toInt()}'),
        const SizedBox(height: 6),
        _SummaryRow(
          label: 'Delivery',
          value: cart.deliveryFee == 0 ? 'FREE' : 'Tsh ${cart.deliveryFee.toInt()}',
          valueColor: cart.deliveryFee == 0 ? AppColors.success : null,
        ),
        if (cart.discount > 0) ...[
          const SizedBox(height: 6),
          _SummaryRow(label: 'Discount', value: '-Tsh ${cart.discount.toInt()}', valueColor: AppColors.success),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: AppColors.navyAccent),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: AppTextStyles.h3),
            Text('Tsh ${cart.total.toInt()}', style: AppTextStyles.priceLarge),
          ],
        ),
        const SizedBox(height: 14),
        ChakulaChapButton(
          label: 'Proceed to Checkout →',
          onPressed: () => context.push(AppRoutes.checkout),
        ),
      ],
    ),
  );
}

class _CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.navyAccent, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.navyMedium,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Center(child: Text(item.menuItem.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menuItem.name, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (item.selectedVariant != null)
                  Text(item.selectedVariant!.label, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text('Tsh ${item.lineTotal.toInt()}', style: AppTextStyles.price.copyWith(fontSize: 14)),
              ],
            ),
          ),
          // Qty controls
          Row(
            children: [
              _QtyBtn(
                icon: item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                iconColor: item.quantity == 1 ? AppColors.error : AppColors.textSecondary,
                onTap: () => context.read<CartBloc>().add(
                  UpdateCartQtyEvent(
                    cartItemId: item.cartItemId,
                    quantity: item.quantity - 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('${item.quantity}', style: AppTextStyles.h4),
              ),
              _QtyBtn(
                icon: Icons.add_rounded,
                iconColor: AppColors.goldBright,
                onTap: () => context.read<CartBloc>().add(
                  UpdateCartQtyEvent(
                    cartItemId: item.cartItemId,
                    quantity: item.quantity + 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.navyMedium,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.navyAccent, width: 0.5),
      ),
      child: Icon(icon, size: 16, color: iconColor),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTextStyles.bodyMedium),
      Text(value,
          style: AppTextStyles.labelLarge.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          )),
    ],
  );
}