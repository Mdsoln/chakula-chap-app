import 'package:chakula_chap/core/widgets/chakula_chap_button.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/block/registration_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../order_tracking/domain/entities/order_entity.dart';
import '../bloc/checkout_bloc.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CheckoutBloc>()),
        BlocProvider(create: (_) => getIt<CartBloc>()..add(LoadCartEvent())),
        BlocProvider(create: (_) => getIt<RegistrationBloc>()..add(FetchLocationEvent())),
      ],
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutOrderPlacedState) {
          // Clear cart after successful order
          context.read<CartBloc>().add(ClearCartEvent());
          context.go(
            '/order/tracking/${state.order.id}',
            extra: state.order,
          );
        }
        if (state is CheckoutErrorState) {
          showChakulaChapSnackbar(context, message: state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.navyDeep,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildDeliveryAddress(),
                      const SizedBox(height: 24),
                      _buildOrderSummary(),
                      const SizedBox(height: 24),
                      _buildOrderNotes(),
                      const SizedBox(height: 24),
                      _buildPaymentMethods(),
                      const SizedBox(height: 24),
                      _buildPaymentPhoneInput(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
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
        const Text('Checkout', style: AppTextStyles.h2),
      ],
    ),
  );

  Widget _buildDeliveryAddress() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('📍 Delivery Address', style: AppTextStyles.h3),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.navyAccent, width: 0.5),
        ),
        child: BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, state) {
            return Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.goldGlow,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(Icons.home_rounded, color: AppColors.goldBright, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Home',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 14)),
                      const SizedBox(height: 2),
                      if (state is LocationFetchedState) ...[
                        Text(state.location.displayName,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.textSecondary,
                                fontSize: 13)),
                      ] else if (state is LocationLoadingState) ...[
                        const Text('Detecting your location...',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      ] else ...[
                        const Text('Location not set',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<RegistrationBloc>().add(FetchLocationEvent()),
                  child: Text('Change',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.goldBright)),
                ),
              ],
            );
          },
        ),
      ),
    ],
  );

  Widget _buildPaymentMethods() {
    const methods = PaymentMethod.values;
    return Builder(builder: (context) {
      return BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          final selected = state is CheckoutReadyState ? state.selectedMethod : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💳 Payment Method', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: methods.map((m) => _PaymentMethodTile(
                  method: m,
                  isSelected: selected == m,
                  onTap: () => context.read<CheckoutBloc>().add(SelectPaymentMethodEvent(m)),
                )).toList(),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildPaymentPhoneInput() => BlocBuilder<CheckoutBloc, CheckoutState>(
    builder: (context, state) {
      if (state is! CheckoutReadyState) return const SizedBox.shrink();
      final method = state.selectedMethod;
      if (method == null || !method.requiresPhone) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${method.emoji} ${method.label} Number', style: AppTextStyles.h4),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.navyAccent, width: 0.8),
                ),
                child: const Row(
                  children: [
                    Text('🇹🇿', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text('+255', style: AppTextStyles.labelLarge),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  onChanged: (v) => context.read<CheckoutBloc>().add(SetPaymentPhoneEvent(v)),
                  style: AppTextStyles.h4.copyWith(letterSpacing: 2),
                  decoration: const InputDecoration(hintText: '7XX XXX XXX'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.goldGlow,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Text(
              '📲 You will receive a PIN prompt on your phone to confirm payment.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldBright),
            ),
          ),
        ],
      );
    },
  );

  Widget _buildOrderNotes() => Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📝 Special Instructions', style: AppTextStyles.h4),
        const SizedBox(height: 10),
        TextFormField(
          maxLines: 3,
          onChanged: (v) => context.read<CheckoutBloc>().add(SetNotesEvent(v)),
          decoration: const InputDecoration(
            hintText: 'Allergies, gate code, extra spice...',
          ),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
      ],
    ),
  );

  Widget _buildOrderSummary() => BlocBuilder<CartBloc, CartState>(
    builder: (context, state) {
      final cart = switch (state) {
        CartLoadedState s => s.cart,
        _ => null,
      };
      if (cart == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.navyAccent, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary', style: AppTextStyles.h4),
            const SizedBox(height: 10),
            ...cart.items.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text('${i.menuItem.emoji} ${i.quantity}×', style: AppTextStyles.bodySmall),
                  const SizedBox(width: 8),
                  Expanded(child: Text(i.menuItem.name, style: AppTextStyles.bodySmall)),
                  Text('Tsh ${i.lineTotal.toInt()}', style: AppTextStyles.labelMedium),
                ],
              ),
            )),
            const Divider(color: AppColors.navyAccent),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: AppTextStyles.bodyMedium),
                Text('Tsh ${cart.subtotal.toInt()}', style: AppTextStyles.labelLarge),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery', style: AppTextStyles.bodyMedium),
                Text(
                  cart.deliveryFee == 0 ? 'FREE' : 'Tsh ${cart.deliveryFee.toInt()}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: cart.deliveryFee == 0 ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.navyAccent),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: AppTextStyles.h4),
                Text('Tsh ${cart.total.toInt()}', style: AppTextStyles.priceLarge),
              ],
            ),
          ],
        ),
      );
    },
  );

  Widget _buildPlaceOrderButton() => BlocBuilder<CheckoutBloc, CheckoutState>(
    builder: (context, checkoutState) {
      return BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          final cart = switch (cartState) {
            CartLoadedState s => s.cart,
            _ => null,
          };
          final ready = checkoutState is CheckoutReadyState;
          final canPlace = ready && (checkoutState).canPlaceOrder;
          final isPlacing = checkoutState is CheckoutPlacingOrderState;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: const Border(top: BorderSide(color: AppColors.navyAccent, width: 0.5)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -4))],
            ),
            child: isPlacing
                ? Column(
              children: [
                Lottie.asset(AppConstants.lottieLoading, width: 60, height: 60),
                const SizedBox(height: 4),
                Text('Placing your order...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.goldBright)),
              ],
            )
                : ChakulaChapButton(
              label: canPlace
                  ? '🔥 Place Order · Tsh ${cart?.total.toInt() ?? 0}'
                  : 'Select Payment Method',
              onPressed: canPlace && cart != null
                  ? () => context.read<CheckoutBloc>().add(PlaceOrderEvent(cart: cart))
                  : null,
            ),
          );
        },
      );
    },
  );
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  Color get _accentColor {
    return switch (method) {
      PaymentMethod.mpesa => AppColors.mpesa,
      PaymentMethod.MixYas => AppColors.tigoPesa,
      PaymentMethod.airtelMoney => AppColors.airtelMoney,
      PaymentMethod.azamPesa => AppColors.azamPesa,
      PaymentMethod.selcom => AppColors.selcom,
      PaymentMethod.cashOnDelivery => AppColors.cashOnDelivery,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor.withValues(alpha: 0.12) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? _accentColor : AppColors.navyAccent,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(method.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(method.label,
                      style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(method.subtitle,
                      style: AppTextStyles.caption.copyWith(fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}