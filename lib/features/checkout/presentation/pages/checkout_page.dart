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

// ── Section enum ──────────────────────────────────────────────────────────────
enum _Section { address, summary, notes, payment }

// ── Page entry ────────────────────────────────────────────────────────────────
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CheckoutBloc>()),
        BlocProvider(create: (_) => getIt<CartBloc>()..add(LoadCartEvent())),
        BlocProvider(
            create: (_) =>
            getIt<RegistrationBloc>()..add(FetchLocationEvent())),
      ],
      child: const _CheckoutView(),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────────────────

class _CheckoutView extends StatefulWidget {
  const _CheckoutView();

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  // Payment is expanded by default; address & summary are collapsed
  _Section _expanded = _Section.payment;

  void _toggle(_Section section) {
    setState(() {
      _expanded = _expanded == section ? _Section.payment : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutOrderPlacedState) {
          context.read<CartBloc>().add(ClearCartEvent());
          context.go(
            '/order/tracking/${state.order.id}',
            extra: state.order,
          );
        }
        if (state is CheckoutErrorState) {
          showChakulaChapSnackbar(
            context,
            message: state.message,
            isError: true,
          );
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      // ── Free delivery banner (conditional) ───────────
                      //_FreeDeliveryBanner(),
                      const SizedBox(height: 12),

                      // ── Address (collapsed by default) ────────────────
                      _AccordionSection(
                        section: _Section.address,
                        expanded: _expanded,
                        onTap: () => _toggle(_Section.address),
                        collapsedChild: _AddressCollapsed(),
                        expandedChild: _AddressExpanded(),
                      ),
                      const SizedBox(height: 10),

                      // ── Order summary (collapsed by default) ──────────
                      _AccordionSection(
                        section: _Section.summary,
                        expanded: _expanded,
                        onTap: () => _toggle(_Section.summary),
                        collapsedChild: _SummaryCollapsed(),
                        expandedChild: _SummaryExpanded(),
                      ),
                      const SizedBox(height: 10),

                      // ── Payment (expanded by default) ─────────────────
                      _AccordionSection(
                        section: _Section.payment,
                        expanded: _expanded,
                        onTap: () => _toggle(_Section.payment),
                        collapsedChild: _PaymentCollapsed(),
                        expandedChild: const _PaymentExpanded(),
                      ),
                      const SizedBox(height: 10),

                      // ── Notes (collapsed by default) ──────────────────
                      _AccordionSection(
                        section: _Section.notes,
                        expanded: _expanded,
                        onTap: () => _toggle(_Section.notes),
                        collapsedChild: _NotesCollapsed(),
                        expandedChild: _NotesExpanded(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Place Order — always visible ──────────────────────────
              _PlaceOrderBar(),
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
              borderRadius:
              BorderRadius.circular(AppDimensions.radiusMd),
              border:
              Border.all(color: AppColors.navyAccent, width: 0.5),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        const Text('Checkout', style: AppTextStyles.h2),
      ],
    ),
  );
}

// ── Accordion Section wrapper ─────────────────────────────────────────────────

class _AccordionSection extends StatelessWidget {
  final _Section section;
  final _Section expanded;
  final VoidCallback onTap;
  final Widget collapsedChild;
  final Widget expandedChild;

  const _AccordionSection({
    required this.section,
    required this.expanded,
    required this.onTap,
    required this.collapsedChild,
    required this.expandedChild,
  });

  bool get _isExpanded => expanded == section;

  String get _label {
    return switch (section) {
      _Section.address => '📍 Delivery Address',
      _Section.summary => '📋 Order Summary',
      _Section.payment => '💳 Payment Method',
      _Section.notes   => '📝 Special Instructions',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: _isExpanded
              ? AppColors.goldBright.withValues(alpha: 0.4)
              : AppColors.navyAccent,
          width: _isExpanded ? 1.2 : 0.5,
        ),
      ),
      child: Column(
        children: [
          // ── Header row (always visible) ───────────────────────────────
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(_label, style: AppTextStyles.h4),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsed preview ─────────────────────────────────────────
          if (!_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: collapsedChild,
            ),

          // ── Expanded content ──────────────────────────────────────────
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.navyAccent, height: 1),
                  const SizedBox(height: 14),
                  expandedChild,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Address ───────────────────────────────────────────────────────────────────

class _AddressCollapsed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final locationText = switch (state) {
          LocationFetchedState(location: final loc) => loc.displayName,
          LocationLoadingState() => 'Detecting location...',
          _ => 'Location not set',
        };
        return Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 14, color: AppColors.goldBright),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                locationText,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddressExpanded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.goldGlow,
                    borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: AppColors.goldBright, size: 22),
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
                      if (state is LocationFetchedState)
                        Text(
                          state.location.displayName,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textSecondary,
                              fontSize: 13),
                        )
                      else if (state is LocationLoadingState)
                        const Text('Detecting your location...',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted))
                      else
                        const Text('Location not set',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context
                      .read<RegistrationBloc>()
                      .add(FetchLocationEvent()),
                  child: Text('Refresh',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.goldBright)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ── Order Summary ─────────────────────────────────────────────────────────────

class _SummaryCollapsed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final cart = switch (state) {
          CartLoadedState s => s.cart,
          _ => null,
        };
        if (cart == null || cart.isEmpty) {
          return Text('No items',
              style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted));
        }

        // Show first 2 items then "+N more"
        final preview = cart.items.take(2).toList();
        final remaining = cart.items.length - preview.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...preview.map(
                  (i) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Text('${i.menuItem.emoji} ', style: const TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        '${i.quantity}× ${i.menuItem.name}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Tsh ${i.lineTotal.toInt()}',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            if (remaining > 0)
              Text(
                '+$remaining more item${remaining > 1 ? 's' : ''}',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.goldBright),
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textMuted),
                ),
                Text(
                  'Tsh ${cart.total.toInt()}',
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SummaryExpanded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final cart = switch (state) {
          CartLoadedState s => s.cart,
          _ => null,
        };
        if (cart == null) return const SizedBox.shrink();

        return Column(
          children: [
            ...cart.items.map(
                  (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(i.menuItem.emoji,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.menuItem.name,
                              style: AppTextStyles.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (i.selectedVariant != null)
                            Text(i.selectedVariant!.label,
                                style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Text('${i.quantity}×',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    Text('Tsh ${i.lineTotal.toInt()}',
                        style: AppTextStyles.labelMedium),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.navyAccent),
            _SummaryRow(
                label: 'Subtotal',
                value: 'Tsh ${cart.subtotal.toInt()}'),
            const SizedBox(height: 4),
            _SummaryRow(
              label: 'Delivery',
              value: cart.deliveryFee == 0
                  ? 'FREE'
                  : 'Tsh ${cart.deliveryFee.toInt()}',
              valueColor: cart.deliveryFee == 0 ? AppColors.success : null,
            ),
            if (cart.discount > 0) ...[
              const SizedBox(height: 4),
              _SummaryRow(
                label: 'Discount',
                value: '-Tsh ${cart.discount.toInt()}',
                valueColor: AppColors.success,
              ),
            ],
            const Divider(color: AppColors.navyAccent),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: AppTextStyles.h4),
                Text('Tsh ${cart.total.toInt()}',
                    style: AppTextStyles.priceLarge),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTextStyles.bodyMedium),
      Text(
        value,
        style: AppTextStyles.labelLarge
            .copyWith(color: valueColor ?? AppColors.textPrimary),
      ),
    ],
  );
}

// ── Payment ───────────────────────────────────────────────────────────────────

class _PaymentCollapsed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final method =
        state is CheckoutReadyState ? state.selectedMethod : null;
        if (method == null) {
          return Text(
            'Tap to select payment',
            style:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          );
        }
        return Row(
          children: [
            Text(method.emoji,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              method.label,
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                '✓ Selected',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.success),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PaymentExpanded extends StatelessWidget {
  const _PaymentExpanded();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final selected =
        state is CheckoutReadyState ? state.selectedMethod : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Payment grid ──────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
              children: PaymentMethod.values.map((m) {
                return _PaymentMethodTile(
                  method: m,
                  isSelected: selected == m,
                  onTap: () => context
                      .read<CheckoutBloc>()
                      .add(SelectPaymentMethodEvent(m)),
                );
              }).toList(),
            ),

            // ── Phone input (only for mobile money) ───────────────────
            if (selected != null && selected.requiresPhone) ...[
              const SizedBox(height: 16),
              _PhoneInput(method: selected),
            ],
          ],
        );
      },
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final PaymentMethod method;
  const _PhoneInput({required this.method});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${method.emoji} ${method.label} Number',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                borderRadius:
                BorderRadius.circular(AppDimensions.radiusMd),
                border:
                Border.all(color: AppColors.navyAccent, width: 0.8),
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
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                onChanged: (v) => context
                    .read<CheckoutBloc>()
                    .add(SetPaymentPhoneEvent(v)),
                style:
                AppTextStyles.h4.copyWith(letterSpacing: 2),
                decoration:
                const InputDecoration(hintText: '7XX XXX XXX'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.goldGlow,
            borderRadius:
            BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Text(
            'You will receive a PIN prompt on your phone to confirm payment',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.goldBright),
          ),
        ),
      ],
    );
  }
}

// ── Notes ─────────────────────────────────────────────────────────────────────

class _NotesCollapsed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final notes =
        state is CheckoutReadyState ? state.notes : '';
        return Text(
          notes.isEmpty ? 'Optional — tap to add instructions' : notes,
          style: AppTextStyles.bodySmall.copyWith(
            color: notes.isEmpty
                ? AppColors.textMuted
                : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

class _NotesExpanded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => TextFormField(
        maxLines: 3,
        autofocus: true,
        onChanged: (v) =>
            context.read<CheckoutBloc>().add(SetNotesEvent(v)),
        decoration: const InputDecoration(
          hintText: 'Allergies, gate code, extra spice...',
        ),
        style: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

// ── Free delivery banner ──────────────────────────────────────────────────────

class _FreeDeliveryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final cart = switch (state) {
          CartLoadedState s => s.cart,
          _ => null,
        };
        if (cart == null) return const SizedBox.shrink();

        if (cart.deliveryFee == 0) {
          // Free delivery unlocked
          return Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius:
              BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎉 Free delivery unlocked! You saved Tsh 3,000.',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
          );
        }

        // Show how much more to get free delivery
        final remaining =
            AppConstants.freeDeliveryThreshold - cart.subtotal.toInt();
        if (remaining > 0) {
          return Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.goldGlow,
              borderRadius:
              BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                  color: AppColors.goldBright.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🛵', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Add Tsh $remaining more for free delivery',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.goldBright),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ── Place Order bar (always visible) ─────────────────────────────────────────

class _PlaceOrderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, checkoutState) {
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            final cart = switch (cartState) {
              CartLoadedState s => s.cart,
              _ => null,
            };
            final ready = checkoutState is CheckoutReadyState;
            final canPlace = ready && checkoutState.canPlaceOrder;
            final isPlacing =
            checkoutState is CheckoutPlacingOrderState;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: const Border(
                    top: BorderSide(
                        color: AppColors.navyAccent, width: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: isPlacing
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(AppConstants.lottieLoading,
                      width: 60, height: 60),
                  const SizedBox(height: 4),
                  Text(
                    'Placing your order...',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.goldBright),
                  ),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Hint when button is disabled ──────────────
                  if (!canPlace && ready) ...[
                    _buildDisabledHint(checkoutState),
                    const SizedBox(height: 8),
                  ],
                  ChakulaChapButton(
                    label: canPlace
                        ? '🔥 Place Order · Tsh ${cart?.total.toInt() ?? 0}'
                        : 'Select Payment Method',
                    onPressed: canPlace && cart != null
                        ? () => context
                        .read<CheckoutBloc>()
                        .add(PlaceOrderEvent(cart: cart))
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDisabledHint(CheckoutReadyState state) {
    if (state.selectedMethod == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            'Choose a payment method above to continue',
            style:
            AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      );
    }
    if (state.selectedMethod!.requiresPhone &&
        state.paymentPhone.length < 9) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_outlined,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            'Enter your ${state.selectedMethod!.label} number',
            style:
            AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Payment method tile ───────────────────────────────────────────────────────

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  Color get _accentColor => switch (method) {
    PaymentMethod.mpesa => AppColors.mpesa,
    PaymentMethod.MixYas => AppColors.MixYas,
    PaymentMethod.airtelMoney => AppColors.airtelMoney,
    PaymentMethod.azamPesa => AppColors.azamPesa,
    PaymentMethod.selcom => AppColors.selcom,
    PaymentMethod.cashOnDelivery => AppColors.cashOnDelivery,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withValues(alpha: 0.12)
              : AppColors.navyMedium,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? _accentColor : AppColors.navyAccent,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(method.emoji,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    method.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    method.subtitle,
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  size: 16, color: _accentColor),
          ],
        ),
      ),
    );
  }
}