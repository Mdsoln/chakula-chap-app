import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';

class FeaturedBanner extends StatefulWidget {
  final List<MenuItemEntity> items;
  const FeaturedBanner({super.key, required this.items});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  int _current = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    // Auto-scroll every 4s
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    final next = (_current + 1) % widget.items.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.items.length,
            itemBuilder: (_, i) => _BannerCard(item: widget.items[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _current ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _current ? AppColors.goldBright : AppColors.navyAccent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final MenuItemEntity item;
  const _BannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2044), Color(0xFF1A3461)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.goldGlow, width: 1),
      ),
      child: Stack(
        children: [
          // Gold glow accent
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: AppColors.goldGlowGradient,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.tag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldGlow,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: AppColors.goldBright.withOpacity(0.4)),
                          ),
                          child: Text(
                            item.tag!,
                            style: AppTextStyles.caption.copyWith(color: AppColors.goldBright, letterSpacing: 0.5),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          item.name,
                          style: AppTextStyles.h2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tsh ${item.price.toInt()}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
                Text(item.emoji, style: const TextStyle(fontSize: 64)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}