import 'package:animate_do/animate_do.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_button.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';

class MenuItemDetailPage extends StatelessWidget {
  final String itemId;
  final MenuItemEntity? item;

  const MenuItemDetailPage({super.key, required this.itemId, this.item});

  @override
  Widget build(BuildContext context) => _MenuItemDetailView(item: item);
}

class _MenuItemDetailView extends StatefulWidget {
  final MenuItemEntity? item;
  const _MenuItemDetailView({this.item});

  @override
  State<_MenuItemDetailView> createState() => _MenuItemDetailViewState();
}

class _MenuItemDetailViewState extends State<_MenuItemDetailView> {
  int _qty = 0;
  int? _selectedVariantIndex;
  final Set<int> _selectedExtras = {};

  MenuItemEntity? get _item => widget.item;

  double get _unitPrice {
    if (_item == null) return 0;

    final variantMod = (_item!.variants.isNotEmpty && _selectedVariantIndex != null)
        ? _item!.variants[_selectedVariantIndex!].priceModifier
        : 0.0;

    final extrasTotal = _selectedExtras.fold<double>(
        0, (sum, i) => sum + _item!.extras[i].price);

    return _item!.price + variantMod + extrasTotal;
  }

  double get _total => _unitPrice * _qty;

  void _addToCart() {
    if (_item == null || _qty <= 0) return;
    context.read<CartBloc>().add(AddToCartEvent(
      menuItem: _item!,
      quantity: _qty,
      variant: _item!.variants.isNotEmpty
          ? _item!.variants[_selectedVariantIndex!]
          : null,
      extras: _selectedExtras.map((i) => _item!.extras[i]).toList(),
    ));
    context.pop();
    showChakulaChapSnackbar(
      context,
      message: '${_item!.emoji} ${_item!.name} added to cart!',
      isSuccess: true,
    );
  }

  String _formatPrice(int amount) {
    if (amount >= 1000) {
      final k = amount / 1000;
      return k == k.truncateToDouble()
          ? '${k.toInt()}K'
          : '${k.toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.goldBright)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHero(),
              SliverToBoxAdapter(
                child: FadeInUp(
                  duration: AppConstants.animMedium,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleRow(),
                        const SizedBox(height: AppDimensions.spaceMd),
                        _buildStats(),
                        const SizedBox(height: AppDimensions.spaceMd),
                        _buildDescription(),
                        if (_item!.variants.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.spaceLg),
                          _buildVariants(),
                        ],
                        if (_item!.extras.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.spaceLg),
                          _buildExtras(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SliverAppBar(
      expandedHeight: 260,
      backgroundColor: AppColors.navyMedium,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.navyDeep.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navyAccent, width: 0.5),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.navyDeep.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navyAccent, width: 0.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.navyMedium,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gold glow
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  gradient: AppColors.goldGlowGradient,
                  shape: BoxShape.circle,
                ),
              ),
              Text(_item!.emoji, style: const TextStyle(fontSize: 110)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_item!.tag != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldGlow,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.goldBright.withValues(alpha: 0.4)),
                    ),
                    child: Text(_item!.tag!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.goldBright)),
                  ),
                Text(_item!.name, style: AppTextStyles.h1),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 4),
              Text('Tsh ${_item!.price.toInt()}', style: AppTextStyles.priceLarge),
              const Text('base price', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      ('⭐', '${_item!.rating}', '(${_item!.reviewCount})'),
      ('⏱', '${_item!.prepTimeMinutes} min', 'prep'),
      ('🔥', '${_item!.calories}', 'cal'),
    ];

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.navyAccent, width: 0.5),
              ),
              child: Column(
                children: [
                  Text(stats[i].$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(stats[i].$2, style: AppTextStyles.labelLarge),
                  Text(stats[i].$3, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
          if (i < stats.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: AppTextStyles.h4),
        const SizedBox(height: 8),
        Text(_item!.description, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildVariants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Choose Size', style: AppTextStyles.h4),
            const SizedBox(width: 8),
            if (_selectedVariantIndex == null)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius:
                  BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  'Required',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.warning),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_item!.variants.length, (i) {
            final v = _item!.variants[i];
            final sel = _selectedVariantIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedVariantIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                      right: i < _item!.variants.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.goldGlow : AppColors.surfaceCard,
                    borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                      color: sel
                          ? AppColors.goldBright
                          : AppColors.navyAccent,
                      width: sel ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        v.label,
                        style: AppTextStyles.labelLarge.copyWith(
                            color: sel
                                ? AppColors.goldBright
                                : AppColors.textSecondary),
                      ),
                      if (v.priceModifier != 0)
                        Text(
                          '${v.priceModifier > 0 ? '+' : ''}Tsh ${v.priceModifier.toInt()}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildExtras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Extras', style: AppTextStyles.h4),
        const SizedBox(height: 10),
        ..._item!.extras.asMap().entries.map((entry) {
          final i = entry.key;
          final extra = entry.value;
          final sel = _selectedExtras.contains(i);
          return GestureDetector(
            onTap: () => setState(() {
              if (sel) {
                _selectedExtras.remove(i);
              } else {
                _selectedExtras.add(i);
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: sel ? AppColors.goldGlow : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: sel ? AppColors.goldBright : AppColors.navyAccent,
                  width: sel ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(extra.name, style: AppTextStyles.labelLarge)),
                  Text('+Tsh ${extra.price.toInt()}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.goldBright : AppColors.navyMedium,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded, color: AppColors.navyDeep, size: 14)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final cart = switch (state) {
            CartLoadedState s => s.cart,
            CartItemAddedState s => s.cart,
            _ => null,
          };
          final hasItems = cart != null && !cart.isEmpty;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: const Border(top: BorderSide(color: AppColors.navyAccent, width: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasItems) ...[
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.cart),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldBright.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.navyDeep.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyDeep),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'View Cart',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyDeep),
                            ),
                          ),
                          Text(
                            'Tsh ${cart.subtotal.toInt()}',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyDeep),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Add to Cart row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.navyMedium,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: AppColors.navyAccent, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _qty = (_qty - 1).clamp(0, 99)),
                            icon: const Icon(Icons.remove_rounded, size: 18, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          Text('$_qty', style: AppTextStyles.h3),
                          IconButton(
                            onPressed: () => setState(() => _qty++),
                            icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.goldBright),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChakulaChapButton(
                        label: 'Add to Cart  •  Tsh ${_formatPrice(_total.toInt())}',
                        onPressed: (
                            _item!.available && _qty > 0 &&
                            (_item!.variants.isEmpty || _selectedVariantIndex != null
                            )
                        )
                        ? _addToCart
                        : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}