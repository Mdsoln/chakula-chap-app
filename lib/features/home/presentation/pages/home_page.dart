import 'package:animate_do/animate_do.dart';
import 'package:chakula_chap/core/widgets/chakula_chap_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../../menu/presentation/bloc/menu_bloc.dart';
import '../../../menu/presentation/widgets/menu_item_card.dart';
import '../../../menu/presentation/widgets/menu_item_shimmer.dart';
import '../widgets/category_chip.dart';
import '../widgets/featured_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<MenuBloc>()..add(const LoadMenuEvent())),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();
  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final s = context.read<MenuBloc>().state;
      if (s is MenuLoadedState && !s.isLoadingMore) {
        context.read<MenuBloc>().add(LoadMoreMenuItemsEvent(categoryId: s.selectedCategoryId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _appBar(),
              _searchBar(),
              _featuredBanner(),
              _categoryRow(),
              _menuHeader(),
              _menuGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _floatingCart(),
          _bottomNav(),
        ],
      ),
    );
  }

  SliverAppBar _appBar() => SliverAppBar(
    floating: true,
    backgroundColor: AppColors.navyDeep,
    expandedHeight: 80,
    flexibleSpace: FlexibleSpaceBar(
      background: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: [
              // Logo mark
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('C',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDeep)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.goldBright),
                      const SizedBox(width: 3),
                      Text('Delivering to', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    ]),
                    const Row(children: [
                      Text('Kagera,Magomeni', style: AppTextStyles.labelLarge),
                      Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.goldBright, size: 18),
                    ]),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.navyAccent, width: 0.5),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: AppColors.goldBright, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  SliverToBoxAdapter _searchBar() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (q) => context.read<MenuBloc>().add(SearchMenuEvent(query: q)),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search dishes, ingredients...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
            onTap: () {
              _searchController.clear();
              context.read<MenuBloc>().add(ClearSearchEvent());
            },
            child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
          )
              : null,
        ),
      ),
    ),
  );

  SliverToBoxAdapter _featuredBanner() => SliverToBoxAdapter(
    child: BlocBuilder<MenuBloc, MenuState>(
      buildWhen: (p, c) => c is MenuLoadedState || c is MenuLoadingState,
      builder: (_, state) {
        if (state is MenuLoadedState && state.featuredItems.isNotEmpty) {
          return FadeInUp(
            duration: AppConstants.animSlow,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: FeaturedBanner(items: state.featuredItems),
            ),
          );
        }
        return const SizedBox(height: 8);
      },
    ),
  );

  SliverToBoxAdapter _categoryRow() => SliverToBoxAdapter(
    child: BlocBuilder<MenuBloc, MenuState>(
      buildWhen: (p, c) => c is MenuLoadedState || c is MenuLoadingState,
      builder: (_, state) {
        if (state is! MenuLoadedState) {
          return const SizedBox(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.goldBright, strokeWidth: 2),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text('Categories', style: AppTextStyles.h3),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  CategoryChip(
                    label: 'All',
                    emoji: '🍽️',
                    isSelected: state.selectedCategoryId == null,
                    onTap: () => context.read<MenuBloc>().add(const SelectCategoryEvent(categoryId: null)),
                  ),
                  const SizedBox(width: 8),
                  ...state.categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: cat.name,
                      emoji: cat.emoji,
                      isSelected: state.selectedCategoryId == cat.id,
                      onTap: () => context
                          .read<MenuBloc>()
                          .add(SelectCategoryEvent(categoryId: cat.id)),
                    ),
                  )),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  SliverToBoxAdapter _menuHeader() => SliverToBoxAdapter(
    child: BlocBuilder<MenuBloc, MenuState>(
      buildWhen: (p, c) => c is MenuLoadedState,
      builder: (_, state) {
        final label = state is MenuLoadedState && state.selectedCategoryId != null
            ? state.categories
            .firstWhere(
              (c) => c.id == state.selectedCategoryId,
          orElse: () => const CategoryEntity(id: '', name: 'Menu', emoji: '', itemCount: 0),
        )
            .name
            : 'All Dishes';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.h2),
              if (state is MenuLoadedState)
                Text('${state.items.length} items',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldBright)),
            ],
          ),
        );
      },
    ),
  );

  SliverPadding _menuGrid() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    sliver: BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is MenuLoadingState) {
          return SliverGrid(
            delegate: SliverChildBuilderDelegate((_, __) => const MenuItemShimmer(), childCount: 6),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.76, mainAxisSpacing: 14, crossAxisSpacing: 14,
            ),
          );
        }
        if (state is MenuErrorState) {
          return SliverToBoxAdapter(
            child: ChakulaChapErrorState(
              message: state.message,
              onRetry: () => context.read<MenuBloc>().add(const LoadMenuEvent()),
            ),
          );
        }
        if (state is MenuLoadedState) {
          if (state.items.isEmpty) {
            return SliverToBoxAdapter(
              child: ChakulaChapEmptyState(
                title: 'Nothing found',
                subtitle: 'Try a different search or browse all categories.',
                lottieAsset: AppConstants.lottieEmptyCart,
                actionLabel: 'Clear',
                onAction: () => context.read<MenuBloc>().add(ClearSearchEvent()),
              ),
            );
          }
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                if (i == state.items.length) {
                  return state.isLoadingMore
                      ? const Center(child: CircularProgressIndicator(color: AppColors.goldBright, strokeWidth: 2))
                      : const SizedBox.shrink();
                }
                final item = state.items[i];
                return FadeInUp(
                  delay: Duration(milliseconds: (i % 6) * 60),
                  duration: AppConstants.animMedium,
                  child: MenuItemCard(
                    item: item,
                    onTap: () => context.push('/menu/item/${item.id}', extra: item),
                    onAddToCart: () {
                      context.read<CartBloc>().add(AddToCartEvent(menuItem: item, quantity: 1));
                      showChakulaChapSnackbar(context, message: '${item.emoji} Added to cart', isSuccess: true);
                    },
                  ),
                );
              },
              childCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.76, mainAxisSpacing: 14, crossAxisSpacing: 14,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    ),
  );

  Widget _floatingCart() => Positioned(
    bottom: AppDimensions.bottomNavHeight + 12,
    left: 20,
    right: 20,
    child: BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final cart = switch (state) {
          CartLoadedState s => s.cart,
          CartItemAddedState s => s.cart,
          _ => null,
        };
        if (cart == null || cart.isEmpty) return const SizedBox.shrink();
        return FadeInUp(
          duration: AppConstants.animMedium,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.cart),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                boxShadow: [BoxShadow(color: AppColors.goldBright.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navyDeep.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text('${cart.itemCount}', style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyDeep)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('View Cart', style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyDeep))),
                  Text(
                    'Tsh ${cart.subtotal.toInt()}',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyDeep),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _bottomNav() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      height: AppDimensions.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: const Border(top: BorderSide(color: AppColors.navyAccent, width: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: true, onTap: () {}),
          _NavItem(icon: Icons.explore_rounded, label: 'Explore', onTap: () {}),
          _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders', onTap: () {}),
          _NavItem(icon: Icons.person_rounded, label: 'Profile', onTap: () {}),
        ],
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.goldBright : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
            if (isActive) ...[
              const SizedBox(height: 3),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.goldBright, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}